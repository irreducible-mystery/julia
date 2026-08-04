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
