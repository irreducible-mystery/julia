# carriers/ — the translation ledger

Kelly asked: *can Julia's language be translated into SQL? into Lisp? if
translation is possible, what is lost and what is gained?* This directory
answers by construction: two new carriers of objects this repo already
formalized, the thread's first courts that are neither Julia nor Lean.

In this repo's vocabulary a translation IS a re-carrying, and
`julia-vs-lean/` already built the methodology: run the same battery in a
new carrier, record where it agrees, disagrees, and extends. Carriers 1–9
lived inside Julia. These are #10 and #11.

```sh
bash carriers/run_carriers.sh          # both courts; exit 0 iff all pass
# or individually:
sqlite3 -bail -batch ':memory:' < carriers/ring_charge_carrier.sql   # read VERDICT
sbcl --script carriers/mu4_battery.lisp                              # read exit code
```

Requirements: SQLite ≥ 3.39 (`IS NOT DISTINCT FROM`), SBCL (any recent).
Neither is needed by anything outside this directory.

## Carrier #10 — SQL (`ring_charge_carrier.sql`, 151 checks)

The defect/charge algebra of `emergence_04`–`_09`, re-carried relationally:
wirings are edge tables, states are rows, the census is a query. Verified
against the kernel's oracles by exhaustion: rest ⟺ m|L
(`succ_ring_rest_iff`), P10 conservation (`defect_sum_invariant`),
rest ⟺ charge-0 (`rest_iff_charge_zero`), the graph-general (★)
(`charge_formula`) on every state of eleven worlds, the one-shared-mark
dial (P13/P19, `charge_dial`), P20 including its m=2 vanishing, and P21's
unheard mark. Two mutant laws (★ without −n; the −(s₁+5) dial) must fire.

**Gained.**
- **The census has no sweep order.** Two convicted instrument crimes of
  this thread — `_03`'s smuggled in-place update order and `_05`'s
  soft-scope flag that could never fail — are not avoided here, they are
  *inexpressible*. A declarative carrier cannot commit them. (The driver
  still pins the check count: truncation is the crime SQL *can* commit.)
- **The K3 court comes home.** SQL's `NULL` is the Kleene third value that
  Julia's `missing` was imported from. `NOT NULL IS NULL` natively; the
  NOT twist over {0, 1, NULL} has exactly one fixed point under the
  decidable equality (`IS NOT DISTINCT FROM`), and it is NULL —
  `rest_of_twist_fixed` wearing SQL, which is P16 with the costume
  returned to its original owner.
- **Equality is plural here too**: `=` is NULL-tainted,
  `IS NOT DISTINCT FROM` is total — the `==`/`isequal` split, native.

**Lost.**
- **The tick.** SQL has no dynamics. Orbits, periods, transients
  (`tunfold`, the 6560-orbits) would need recursive CTEs, which
  reintroduce exactly the iteration discipline the carrier banished.
  Declared, not delivered; the repo's oldest unpaid debt is *more* visible
  here, not less.
- **Combiners as values.** `sum` and `max` are aggregates, not arguments;
  "no combiner is neutral" becomes two queries instead of one function
  with two parameters. (Open move: SQL has `MAX` natively, so the
  max-combiner census — where no (★) exists and census-first is the only
  instrument — has a natural relational court waiting.)
- **⊥.** Divergence-as-semantics does not exist in this fragment; every
  antinomy is forced into the no-model or third-value shape.

**Fingerprints (photographed in the file's FPRINT checks).**
- SQL `%` is *truncated* division: `-7 % 3 = -1`. Julia's `mod` is
  floored. The entire charge algebra sits on `((x % m) + m) % m`; this is
  the single highest-risk detail of the whole translation.
- `SUM` over an empty group is NULL, not 0 — Julia's `init=0` becomes
  `COALESCE`. Omit it and the unheard mark's defect is not wrong, it is
  NULL, and NULL poisons every aggregate it touches.
- The INNER-JOIN formulation doesn't even go NULL: the unheard mark
  *vanishes from the aggregate*. Silent row loss is this host's soft scope.

## Carrier #11 — Common Lisp (`mu4_battery.lisp`, 36 checks)

The full 29-line μ₄ battery of `julia-vs-lean/mu4_core.jl` — machinery
transcribed once, generic over a carrier record of first-class functions,
the same design — run over seven exact Lisp carriers (interned symbols +
Cayley table, native complex integers, log form, matrices, permutations,
bitmasks, rational angles) and the two-equalities float pair; plus the
65536-symbol sweep (32/64/8, pentagon ⟺ untwisted over all symbols), the
generic `gd3` at ℤ/6, and two table-mutant controls that must fire.

This is the translation with the shortest distance: Julia's AST is an
S-expression (`Meta.show_sexpr`), its parser was written in femtolisp, and
`julia --lisp` still opens that Lisp. Un-parsing, not porting.

**Gained.**
- **Equality is MORE plural**: `eq`/`eql`/`equal`/`equalp` plus numeric
  `=` — five predicates to Julia's four. And the plurality bites *exact*
  data, not just floats: the matrix carrier under `eq` loses 21/29 battery
  lines (fresh conses are never `eq` to stored ones) while the symbol
  carrier under `eq` passes 29/29 (symbols are interned). Same carrier,
  two equalities, two objects — julia-vs-lean's sharpest observation,
  reproduced without touching a float.
- Native exact rationals and Gaussian integers with no imports; code is
  data (`quote`/`eval`), so the paradox corpus's metaprogramming exhibits
  have a natural home here (declared, not delivered — see open moves).

**Lost.**
- **The Int64 = ℤ/2⁶⁴ finding dies.** CL integers are exact bignums;
  `most-positive-fixnum + 1` promotes, nothing wraps, and ℤ/2⁶⁴ is
  available only by explicit `mod` — opt-in, never an ambush. A host
  finding does not translate: it re-instantiates differently or dies, and
  its death is the datum. (Its SQL sibling: PostgreSQL `bigint` *raises*
  on overflow — a third instrument, a third fingerprint.)
- Julia's world-age stratification has no analogue (nor in SQL); the
  omnipotence-paradox exhibit of the paradox corpus survives in neither
  target.

**Fingerprints (photographed in Part H).**
- `(complex 1 0)` collapses to the integer `1` (CLHS 12.1.5.3): the
  Gaussian carrier's identity element is *literally* 1, an ontology Julia's
  `Complex{Int}(1,0)` refuses. Float complexes do not collapse — same
  ring, two ontologies inside one host.
- The float els carry libm dirt (`i*i = -1 + 1.2246467991473532e-16 i`),
  exactly as in Julia.

**Unregistered convergence, reported as found.** The float-exact carrier
was pinned only to "must disagree somewhere" — the count was deliberately
left free because libm is a host fingerprint. It disagreed on exactly the
SAME 13 battery lines as Julia's `FLOAT_EXACT`, with bit-identical dirt
(`1.2246467991473532e-16`). The "host-specific" fingerprint is apparently
shared: both hosts' `exp`/`sin`/`cos` round these arguments identically.
IEEE 754 is a deeper invariant than the language on top of it — the same
lesson as `_09`'s convention-proof class counts, one level down.

## The invariant census (after `ieee_court.sh` and the branch sweep)

What survives EVERY carrier tried so far, and what belongs to the host —
compiled from carriers #1–#11, the IEEE court, and the audits of the four
side branches (`audits/branch_sweep_by_carrier_instance.jl`).

**Carrier-invariant (same machine):**
- **IEEE 754 double arithmetic, to the bit.** sin(π), cos(π/2), 0.1+0.2,
  Im(e^{iπ}) are bit-identical in Julia, SBCL, and SQLite (`ieee_court.sh`,
  8/8); the μ₄ float battery breaks the SAME 13 lines in Julia and CL with
  bit-identical dirt. Scope: cross-LANGUAGE on one machine; cross-machine
  is not claimed.
- **Exhaustive finite counts.** 29/29 battery lines (9 exact carriers ×
  {Julia, CL} + Lean); 32/64/8 over 4⁸ symbols (Julia + CL); rest ⟺ m|L
  censuses (Julia + SQL + CL + Lean's kernel); conjugacy class counts
  (main's _09, convention-proof).
- **Kleene K3.** Julia `missing` ≡ SQL NULL: same tables, same unique
  NOT-fixed-point — by documented inheritance, not coincidence.
- **Congruence classes mod m.** The class is invariant; the representative
  and the `%` operator are host-owned (floored vs truncated).

**Host-owned (fingerprints — each photographed in a runnable check):**
- **Integer overflow, four hosts, four policies:** Julia Int64 wraps
  (ℤ/2⁶⁴); Common Lisp promotes exactly (bignum); SQLite promotes LOSSILY
  to IEEE double (`typeof → real` — the most treacherous, exactness
  traded silently for range); PostgreSQL raises (testimony, not run here).
- **The printer.** SQLite's `printf('%.17g')` renders 0x3FD3333333333334
  as `0.3` while its `=` still refuses `0.1+0.2 = 0.3`. Same bits, lossy
  display: a receipt's rendering layer is an instrument, and it can hide
  dirt the arithmetic faithfully carries.
- **Equality plurality is universal; its arity is not.** Julia 4, CL 5,
  SQL 2, Lean 2. Every host splits equality somewhere; no two split it
  the same way.
- **Toolchain version splits WITHIN a host** (F7, explore-repos branch):
  the same Lean file gives 16 clean declarations on 4.32.2 and silently
  degrades 5 to `sorryAx` on 4.22.0. A verdict is a property of
  (file, toolchain) — libm apparently converges; kernels demonstrably
  don't.
- **RNG streams and wall-clock** (F4 here; `time()`/`rand` in julia2's
  Part 3): never invariant, only pinnable.

**Anti-invariants (numbers that look portable and aren't):** Berry-class
counts — any number obtained by quantifying over a carrier's own
expression space (Berry's 103 vs 100001; julia2's "68 forms", ~40 of
which collapse to identical S-expressions in Lisp). And the
reused-integer trap: 65536 means three unrelated things on three branches
(4⁸ symbols, a Feistel state space, 2¹⁶ pairs) — same integer, different
objects, no invariance.

## What was NOT translated, and why (open moves)

- **μ₄ battery in SQL**: blocked on first-class functions. It could be
  faked as nine duplicated query sets, but the methodology being
  translated — one battery, many carrier *values* — is exactly what the
  duplication would destroy. Declared impossible-in-spirit, not attempted.
- **Orbit/period dynamics in SQL**: recursive CTEs can do it, at the price
  of reintroducing an update discipline. Whoever pays the tick debt should
  decide whether that price is the point or the crime.
- **The paradox corpus in Lisp** (`julia3claude/paradoxes`): quote/eval,
  Berry, the four-way identity pluralism port naturally; `missing` must be
  hand-built (CL has no native K3 — that thesis emigrates to SQL instead).
  Declared, not delivered.
- The two mutant controls here convict *tables*; nobody has yet built a
  mutant that convicts the *driver* (run_carriers.sh trusts grep). The
  audit of the audit remains open, as always.

---

# ADDENDUM — carriers #12 and #13, by the translator instance (2026-08-04)

Appended, original text untouched (the F9 pattern). Companion convictions:
`audits/carrier_sweep_by_translator.sh` (12 checks) and
`audits/CARRIER-SWEEP-NOTES-by-translator.md`.

```sh
bash carriers/run_new_carriers.sh              # #12 + #13 + two build-time fingerprints
bash audits/carrier_sweep_by_translator.sh     # the return sweep of carriers/
```

## Carrier #12 — Elixir (`ring_charge_elixir.exs`, 123 checks)
## Carrier #13 — Rust (`ring_charge_rust.rs`, 120 checks)

The same eleven worlds, the same m ∈ 2..5 grid with mⁿ ≤ 5000, the same
oracles as #10 — transcribed from `ring_charge_carrier.sql`. The two carriers
agree row-for-row on every shared law despite different integer models
(bignum vs i128); `run_new_carriers.sh` checks that agreement by md5 and
guards every capture with a non-emptiness test first (see C2 below).

These exist because B2 of the previous sweep convicted
`claude/elixir-rust-setup-25myba` as an empty promise — correctly. This is the
repair, not an appeal.

**Gained.** Elixir's bignums carry states at ±10³⁸ and beyond — the states
`RingRest.lean` quantifies over and neither Julia nor SQL can represent (still
finitely many; still not a ∀). Rust is the only host in the census that
**refuses at compile time**: `HashMap<f64, _>` is not a runtime error, it is a
program that does not exist, proven by a build that must fail and must name
`Eq`.

**Lost.** SQL's declarative gain — `_03`'s sweep order is *inexpressible* — is
gone; both hosts can commit it again. Immutability makes it loud, not
impossible.

## Three amendments to the invariant census above

1. **Overflow needs a new column.** The census lists four hosts with four
   policies, each fixed by the host. Elixir joins the exact-promoters. **Rust
   breaks the schema**: the same source panics in debug and wraps in release
   (asserted by compiling one file twice — exit 101 vs exit 0). Overflow is a
   property of **(host, build profile)**. F7's lesson, one level below the
   toolchain. The Rust edition split (`[..].into_iter()` yields values under
   2021, references under 2015) is a second instance.

2. **Equality: the arity is not the discriminator, the AXIS is.** With Elixir
   at 2 and Rust at 2, arity now collides three ways with SQL and Lean. What
   still separates every host is the axis it splits along — SQL
   **NULL-totality**, Elixir **numeric exactness**, Lean **decidability**,
   Rust **reflexivity** (`f64: PartialEq` but not `Eq`). Suggested restatement:
   *every host splits equality; no two split it along the same axis.*

3. **P16 was under-described — and the correction came from a failed
   prediction.** "The K3 court comes home" is true, but what came home is not
   the third value; it is the **default propagation**. The Liar's rest state
   needs a negation that propagates absence, not a three-valued equality:

   | host | default negation on the third value | fixed points |
   |---|---|---|
   | SQL | `NOT NULL` → `NULL` (propagates) | 1 |
   | Julia | `!missing` → `missing` (propagates) | 1 |
   | Rust | neither by default (`map` propagates, `unwrap_or` coerces) | 1 or 0, per call site |
   | Elixir | `!nil` → `true` (coerces) | 0 |

   I pre-registered "no K3 ⇒ no fixed point"; the Rust carrier failed that
   check because `Option::map` propagates. Both carriers now check both twists
   and get both answers. `rest_of_twist_fixed` is carrier-invariant — a
   theorem about twists. Which twist the host hands you for free is the
   fingerprint.

## New law: P26 (found by translating)

`P20_m2_dial_vanishes` is asserted at **m=2 only**, and the charge spread is
inspected exactly once in all of `ring_charge_carrier.sql`. The vanishing is
the extreme case of a gcd law: the dial's image is ⟨d⟩ ≤ ℤ/m for
`d = 1 − outdeg(j₀)`, so reachable charges = **m / gcd(d, m)**. At `d = −2`:
m=2 → 1, m=3 → 3, **m=4 → 2 (a half-vanishing nobody named)**, m=5 → 5. The
engine is the zero divisor `2·2 ≡ 0 (mod 4)` — `emergence_10`'s P25
("prime-vs-composite, not algebra-vs-order") arriving as a statement about
dials. Checked at every modulus in #12 and #13, with a control: an outdeg-2
dial (`d = −1`) never collapses at any modulus.

## Two convictions against this directory (details in the notes)

- **C1 — the verdict cannot count a NULL check as a mismatch.**
  `WHERE got != expect` is NULL-tainted, so a check whose value goes NULL
  passes while the count stays pinned. The per-row printer prints `FAIL` and
  the VERDICT line reports zero — the same file, two receipts, opposite
  verdicts — and `run_carriers.sh` greps the wrong one and exits 0. The
  README's own fingerprint section predicted this hazard one screen earlier.
  Repair: `IS DISTINCT FROM`.
- **C2 — `ieee_court.sh` certifies agreement between two silences.** No
  emptiness guard on `$JBITS`/`$LBITS`, and the SBCL capture discards stderr;
  `command -v` proves a host exists, not that it spoke. Two present-but-failing
  hosts make the headline check pass vacuously.

Conflict of interest: `run_new_carriers.sh` was written after finding C1 and
C2, so it is guarded against those two crimes and no others. Both new carriers
share **my** transcription of the eleven worlds — replicated, not re-derived,
which is the B3 crime this thread already convicted. Declared, not repaired.
The next stranger starts here.
