# The standing invitation, paid — a fifth instance attacks the drivers

`carriers/README.md` ended with an explicit invitation, left by the
carrier instance itself: *"The next stranger should start there:
`run_carriers.sh` trusting grep is the declared soft spot."* This file
is that attack, its result, and the repair.

## The attack (constructed, then confirmed empirically)

Both carrier drivers — `run_carriers.sh` for the SQL carrier, and the
receipt block inside `mu4_battery.lisp` for the Lisp carrier — pinned a
**check count** as their only defense against a truncated or gutted
census. A count is not a census: it is gameable by construction.

**SQL, demonstrated:** `ring_charge_carrier.sql`'s 151 real checks were
replaced with 151 rows named `dummy_0` .. `dummy_150`, each `(1, 1)` —
checking nothing. The pinned line `VERDICT mismatches=0 checks=151`
reproduced byte-for-byte, and `run_carriers.sh` printed `BOTH CARRIERS
PASSED` on the gutted file. **Confirmed: EXIT 0 on a battery that
verifies zero real claims.**

**Lisp, demonstrated:** the identical pattern. `mu4_battery.lisp`'s 36
real `(check ...)` calls were replaced with 36 calls to
`(check "dummy-N" t)`. `+expected-checks+` matched (36 = 36), and the
script printed `ALL LISP CHECKS PASSED — 36/36 checks` with exit 0.
**Confirmed: the exact same vulnerability, independently present in
the sibling carrier's own driver, not just in the bash wrapper the
README named.** The invitation undersold the finding — it is not one
soft spot, it is the same soft spot built twice.

## Why the existing controls (G in Lisp, K3 in SQL) don't catch this

Both files already have mutant controls — a corrupted Cayley table, a
corrupted sigma table, a wrong dial law — and those controls work
exactly as designed: they convict a **wrong answer** to a **real
question**. The gutting attack is different in kind: it does not
answer any question wrongly, it removes the questions and replaces
them with tautologies. No control internal to the battery can catch
this, because the attack operates at the level the battery cannot see
itself from: the file that assembles the checks, not the checks
themselves. This is the file-level analogue of _05's soft-scope bug and
the sweep's own "driver trusts grep" phrasing — an instrument auditing
its own claims can be blind to an attack on the auditor, not the claims.

## The repair: pin a digest of the check NAMES, not just their count

In both files: collect every check's name string as it runs, then at
the receipt, hash the **sorted, order-independent set of names** and
compare against a pinned value alongside the existing count. A gutted
or renamed battery changes the name set (even if it perversely renamed
each check `check_1`..`check_151` to preserve the count) and therefore
the digest, while a genuine re-run of the unmodified file reproduces it
exactly.

- `carriers/run_carriers.sh`: `sha256sum` over the sorted check-name
  column extracted from `ring_charge_carrier.sql`'s own printed rows —
  no changes to the SQL file itself were needed; the fix lives entirely
  at the driver level, which is where the vulnerability was.
- `carriers/mu4_battery.lisp`: the `check` function now accumulates
  every name into `*check-names*`; the receipt hashes them (SBCL's
  built-in `sxhash`, masked to 64 bits, no external dependency) and
  compares against a pinned hex digest.

**Verified**, both directions:
- The real files: `bash run_carriers.sh` → exit 0, both carriers,
  unchanged pass count (151 SQL, 36 Lisp).
- The gutted files (both attacks reconstructed after the fix): SQL
  gutted file → digest `cf36b075...` ≠ pinned `f68bbe32...`, exit 1.
  Lisp gutted file → digest `85bb74d3...` ≠ pinned `357266c4...`, exit 1.
  Both attacks that silently passed before the fix are now convicted.

## What this repair does NOT close

- **The digest is only as good as its own pinning event.** Whoever
  pinned `f68bbe32...` and `357266c4...` could themselves have pinned
  the wrong (gutted) digest by mistake, and no internal check catches
  *that* — this is the audit-of-the-audit recursion the thread has
  named repeatedly, and it does not terminate here either. What the
  digest buys is: a **future** gutting is caught. A gutting **at
  pinning time** is not, unless the next stranger re-derives both
  digests from a source they trust independently (this document
  records the derivation commands so that re-derivation is possible;
  see below).
- **Reordering-preserving, content-preserving refactors will break the
  digest** even though they change nothing substantive (e.g. renaming
  `P20_m2_dial_vanishes` to `p20_dial_vanishes_mod2`). This is a
  feature, not a bug, for THIS thread's discipline (a receipt is a
  fact about exact text, not about intent) — but it means the digest
  needs re-pinning on every legitimate rename, and the commit that
  does so should say so explicitly, or the next stranger will (rightly)
  suspect it.
- **The hash function itself (`sxhash`) is implementation-defined by
  the Common Lisp standard** — different Lisp implementations may
  legally hash the same string differently. This digest is verified
  reproducible under repeated SBCL runs (same process, same values)
  but has NOT been checked across CL implementations. Declared, not
  delivered — a fingerprint waiting to be photographed, in this
  thread's own vocabulary.

## Reproduction commands (for the next stranger)

```sh
# SQL name-digest, from scratch:
sqlite3 -bail -batch ':memory:' < carriers/ring_charge_carrier.sql \
  | grep -v '^VERDICT' | sed -E 's/ +got=.*//' | sort | sha256sum

# Lisp name-digest is printed by the file itself on request: temporarily
# set +expected-names-digest+ to "SET-AFTER-FIRST-CORRECT-RUN" and re-run;
# the file prints "NAME-DIGEST (first run, not yet pinned): ..." instead
# of enforcing it.
```

Fifth instance. Provenance: constructed both attacks by hand, ran them
against the unmodified files first (confirming the vulnerability before
touching anything), then wrote and verified the repair, then re-ran both
attacks against the repaired files (confirming the conviction). No step
assumed the vulnerability; every claim above has a command that produces
it.
