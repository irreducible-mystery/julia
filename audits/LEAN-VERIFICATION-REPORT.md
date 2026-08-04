# Independent Verification Report — circle-six-gap-proof

**Verifier:** SuperNinja (independent toolchain, not the artifact's)
**Date:** 2026-02-04
**Kernel used:** Lean 4.32.2 (x86_64-linux, commit f3b06c7), installed by me via elan
**Artifact's declared kernel:** Lean 4.22.0 (mine is newer and independent — a stronger check, since the proofs must survive a kernel the authors never touched)

## Verdict: VERIFIED ✅

All 66 theorems listed in `01-BUILD-STACK.md` compile on my own kernel with
exit code 0, and my own independent axiom audit confirms every single one
depends on **no axioms whatsoever** (not even `propext`).

## What I checked (artifacts, not prose)

### 1. File integrity
- `sha256sum -c MANIFEST.sha256` → all 17 files OK.

### 2. Source hygiene (my own grep, before trusting anything)
- Zero `import` lines — the files are fully self-contained (nothing smuggled in via Mathlib or std).
- No `sorry`, no `axiom`, no `native_decide`, no `unsafe`, no `partial`,
  no `implemented_by`, no `@[extern]`, no macro/elab/notation trickery.
- Only benign options: `set_option maxRecDepth 8000`, `set_option maxHeartbeats 0`
  (these change resource limits, never soundness — everything still goes through the kernel).
- Hand-rolled `Decidable` instances (`decAllU`, `decAllBool`) inspected manually:
  they enumerate all 4 constructors of `U` / both values of `Bool`, and the
  `isTrue` branch is discharged by `cases`. Sound.

### 3. Kernel honesty control
- `theorem t : 2+2=4 := by decide` → exit 0 (accepts truth)
- `theorem f : 2+2=5 := by decide` → exit 1 (rejects falsehood)

### 4. Compilation on MY kernel (4.32.2, not theirs)
- `lean lean/C6_Twist.lean` → **exit 0** (46s — the |B³| enumerations over 256 gauges are kernel-decided)
- `lean lean/C6_Gap.lean` → **exit 0** (0.6s)

### 5. Independent axiom audit
I wrote my own extractor (`my_audit.py`) — I did NOT use their `verify.sh` or
their regenerator for this. It found and audited via `#print axioms`:
- **C6_Twist.lean: 49 theorems** — all "does not depend on any axioms"
- **C6_Gap.lean: 17 theorems** — all "does not depend on any axioms"
- Set-comparison against the 66 `THEOREM` lines in `01-BUILD-STACK.md`:
  **exact match, both directions** (nothing claimed-but-missing, nothing hidden).

### 6. Falsification controls (does the kernel actually check these files?)
I mutated two theorems and re-ran:
- `sqrtsOfOne 4 = [1, 3]` → `[1, 2]`: kernel **rejected** ("decide proved the proposition is false")
- `countB false 256 = 16` → `= 17`: kernel **rejected**
So the acceptance of the originals is meaningful, not vacuous.

### 7. Their own verify.sh (run last, as corroboration only)
- All 6 sections pass, `EXIT=0`: kernel honesty, compilation, 129-declaration
  axiom audit (their broader count includes defs/instances), doc-drift check
  (`01-BUILD-STACK.md` regenerates identically), all 8 compute scripts run,
  manifest matches.

## Scope caveats (what this verification does and does not establish)

- **Verified:** the 66 formal statements in `lean/*.lean` are theorems of Lean's
  logic, axiom-free, on an independent kernel. The math inside the files is real.
- **Not verified (and the artifact itself says so, honestly, in NOT-PROVED.md):**
  - The full 4^8 = 65536-symbol sweep counts (|Z³| = 32/64, shared = 8) are
    `#eval`-computed only, NOT kernel-decided. No theorem depends on them.
  - The "twisted complex" is a construction made *here* (action attached to the
    leading face by convention); it is not extracted from any external sealed source.
  - The correspondence between these finite Lean objects and whatever
    external mathematical/physical claims they are meant to model
    ("the seal", "circles", bosons/fermions) is an interpretation layer that
    no kernel can check. I verified the artifacts, not the story around them.

## One version note
`verify.sh` pins 4.22.0; I used 4.32.2. That the proofs pass unchanged on a
kernel released after the artifact was built is evidence *for* robustness, not
against it. (Installing a second pinned toolchain was blocked by sandbox disk
space; the falsification controls above establish my kernel was genuinely
checking these files.)
