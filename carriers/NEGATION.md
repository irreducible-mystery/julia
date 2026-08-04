# Negation, carried across five hosts

Runnable: `bash carriers/run_negation_census.sh` (18/18, exit 0). Halves:
`negation_census.exs` (120 checks), `negation_census.rs` (91), the SQL K3
court and the Lean axiom ledger inline in the driver.

Kelly asked to look harder at negation. It turned out to be the seam where
two things this repo named separately share a mechanism, and where every host's
hidden commitments become visible at once.

**Read the ERRATUM near the end before §1.** My first statement of the duality
was an over-claim generalized from a single world; the correction is convicted
by this file's own checks.

---

## 1. The duality: P26 and "neg regains rest" (see ERRATUM — narrower than stated)

On ℤ/m let φ(x) = 2x. Then

```
x is fixed by negation  ⟺  x = −x  ⟺  2x ≡ 0  ⟺  x ∈ ker φ
P26's dial image (coefficient d = −2)                    =  im φ
|ker φ| · |im φ| = m                       (first isomorphism theorem)
```

So `emergence_09`'s **P20 "m=2 vanishing"** (which I generalized to
`m / gcd(2,m)` as P26) and `RingRest.lean`'s **`neg_world_rest`** ("neg-twisted
worlds always rest") are the two halves of one exact sequence:

> **The dial collapses exactly as much as negation has fixed points.**

Checked exhaustively for m = 1..64 in both Elixir and Rust: `|neg fixed| =
gcd(2,m)`, and `|neg fixed| · |dial image| = m` in every case. Odd m: only 0 is
self-negating. Even m: 0 and m/2. Controls fire on a wrong gcd and on the
non-collapsing d = −1 dial.

## 2. Int64 is ℤ/2⁶⁴, and the gcd law *predicts* its negation fixed points

`gcd(2, 2^N) = 2`, so negation on any signed N-bit integer has **exactly two**
fixed points: 0 and MIN. Julia's `-typemin(Int64) == typemin(Int64)` is not a
quirk — it is ker φ.

Verified **exhaustively**: all 256 `i8` and all 65536 `i16` values under
`wrapping_neg` have fixed-point set exactly `{MIN, 0}`. At 64 bits the two are
checked directly (2⁶⁴ is not enumerable) and `i64::MIN as u64 == 1 << 63`.

Carrier #11 recorded that "the Int64 = ℤ/2⁶⁴ finding **dies**" in Common Lisp
because CL promotes to bignums. Elixir promotes too — and that is exactly what
lets it **recover** the finding: with unbounded integers you can carry ℤ/2⁶⁴ as
an explicit value rather than suffer it as an ambush. *A host that cannot
undergo the wrap can still say it.* The death of a host finding and its
re-expression are not the same event.

### 2b. …and the count depends on the build profile

In release, `-i8::MIN == i8::MIN` — both fixed points reachable. In debug, the
same expression **panics**: the second fixed point does not exist.

> **The number of fixed points of negation is a property of (host, build
> profile).**

Same source file, two algebras, no version number changed. This is the same
finding as the census's overflow column, arriving through a different door —
and it is `F7`'s lesson ("a verdict is a property of *(file, toolchain)*") one
level below the toolchain.

Related: negation is a **total involution** on wrapping i8 (exhaustively:
`-(-x) == x` for all 256) but a **partial function** under checked arithmetic
(`checked_neg` is defined on 255 of 256 values). Same operator, two totalities,
chosen by which method you call.

## 3. Involutivity is decided by propagate-vs-coerce

Extending the P16 finding from carriers #12/#13. A negation that **propagates**
its third value is an involution; one that **coerces** is not:

| host | third value | negation | ¬¬x = x | fixed points |
|---|---|---|---|---|
| SQL | `NULL` | `NOT NULL` → `NULL` (propagates) | ✅ all 3 | 1 |
| Julia | `missing` | `!missing` → `missing` (propagates) | ✅ | 1 |
| Rust | `None` | `map(!)` propagates / `unwrap_or` coerces | per call site | 1 or 0 |
| Elixir | `nil` | `!nil` → `true` (coerces) | ❌ 2 of 3 | 0 |
| Lean `Bool` | — | `!` | ✅ | 0 |

Elixir's coercing `!` loses **double-negation elimination**: `!!nil` is
`false`, and `false != nil`. It is also *idempotent from step two on* —
`¬³nil = ¬nil`. The absent value is a source, never a sink.

## 4. Which half of classical negation does each host drop?

Classical negation obeys both DNE (`¬¬P → P`) and LEM (`P ∨ ¬P`). Every host
here drops a *different* subset — and **all four cells of the 2×2 are
occupied** by hosts in this thread:

| | LEM holds | LEM fails |
|---|---|---|
| **DNE holds** | Lean `Bool`, classical | **SQL / K3** |
| **DNE fails** | **Elixir `!`** | Lean `Prop` (constructive) |

- **SQL K3**, exhaustive over {0, 1, NULL}: DNE holds 3/3, LEM holds 2/3
  (`NULL OR NOT NULL` is NULL), `NOT` has exactly one fixed point (NULL).
- **Elixir** is K3's exact mirror: LEM holds vacuously for all three values
  (everything is truthy-or-not), DNE fails at `nil`.
- **Lean**, with the kernel's own receipts as evidence:

```
'NegCensus.bool_dne'            does not depend on any axioms
'NegCensus.bool_lem'            does not depend on any axioms
'NegCensus.prop_dni'            does not depend on any axioms   -- P → ¬¬P
'NegCensus.prop_tne'            does not depend on any axioms   -- ¬¬¬P → ¬P
'NegCensus.prop_tni'            does not depend on any axioms   -- ¬P → ¬¬¬P
'NegCensus.prop_dn_idempotent'  does not depend on any axioms   -- ¬⁴P ↔ ¬¬P
'NegCensus.prop_dne'            depends on axioms: [propext, Classical.choice, Quot.sound]
'NegCensus.prop_lem'            depends on axioms: [propext, Classical.choice, Quot.sound]
```

One host carrying **two negations with different logics**, and the ledger
prints the price of each. Note what is free: you may always *add* a double
negation, and you may always collapse *three* to one. What costs
`Classical.choice` is removing *two*. And in Lean, DNE and LEM cost **exactly
the same** — unlike K3, which gets DNE for nothing and cannot buy LEM at all.

## 5. The unifying shape: period-2 versus eventually-constant

The classification the whole census was circling is not "how many truth values"
but **what the negation orbit does**:

- **Period 2** (involutive): Lean `Bool`, SQL K3, Rust's propagating `map(!)`,
  classical logic.
- **Eventually constant**: Elixir's coercing `!` stabilizes from step 2
  (`¬³nil = ¬nil`); intuitionistic `Prop` stabilizes from step 3 (`¬¬¬P ↔ ¬P`,
  and `¬⁴P ↔ ¬¬P` — both axiom-free).

Two hosts that could not be more different — a dynamically typed runtime
coercing `nil`, and a dependently typed kernel refusing to eliminate a double
negation — produce **the same structural phenomenon**: a negation that is not
an involution is one whose orbit stops moving. The only difference is *when*.

## 6. Where the equality plurality reappears

On floats, negation flips the sign bit unconditionally. So:

- Under **bit identity**: negation has **zero** fixed points (swept over all
  65536 top-16-bit `f32` patterns — every sign, exponent, NaN, Inf, subnormal).
- Under **`==`**: exactly **two**, `+0.0` and `−0.0`, because `-0.0 == 0.0`.

> **The same operator on the same type has 0 or 2 fixed points depending on
> which equality you pick.**

And NaN closes the circle: it is not a fixed point of negation *and* it is not
self-equal — the value that breaks reflexivity is the same value negation
cannot pin down. That is the `f64: PartialEq but not Eq` finding from carrier
#13, arriving from the negation side.


---

## ERRATUM — the duality above is narrower than I claimed

Convicted by my own court (`negation_census.exs`, checks `N1e`/`N1f`), and the
checks fail if the over-claim is ever restored.

I wrote "the dial collapses exactly as much as negation has fixed points" as
though P26 and `neg_world_rest` were **one theorem**. They are not. The dial's
collapse is `|ker(×d)| = gcd(d, m)` for `d = 1 − outdeg(j₀)`; negation's fixed
points are `|ker(×2)| = gcd(2, m)`. Those agree iff `gcd(|d|, m) = gcd(2, m)` —
an identity **only when d = ±2, i.e. only at out-degree 3**. Measured over
m = 2..60:

| out-degree | d | moduli where the duality holds |
|---|---|---|
| 1 | 0 | 1 / 59 |
| 2 | −1 | 29 / 59 |
| **3** | **−2** | **59 / 59** ← the world I generalized from (`w3`) |
| 4 | −3 | 19 / 59 |
| 5 | −4 | 44 / 59 |

I checked the duality on `w3` — the one world in the corpus whose shared mark
has out-degree 3 — and read a general law off a single case. That is the
`_05` parochialism this thread keeps convicting, committed by me, one file
after I convicted #10 for checking its vanishing at a single modulus.

**What survives.** Both quantities are `ker`/`im` of multiplication on ℤ/m, so
both obey `|ker(×k)| · |im(×k)| = m` — checked for k = 1..6, all m ≤ 40. That
is the first isomorphism theorem applied to **two different multipliers**: a
shared *mechanism*, not a shared *theorem*. The corrected statement:

> P26's collapse and negation's fixed points are the same invariant evaluated
> at different multipliers. They coincide exactly at out-degree 3.

Everything downstream is unaffected — the gcd law for P26, the `i8`/`i16`/`i64`
predictions, the 2×2, the orbit classification. Only the word "one theorem" was
wrong, and only about worlds that are not `w3`.

---

## What this says about the invariant question

The theorem is invariant. `|ker φ| · |im φ| = m` holds in Elixir, Rust, SQL and
Lean; `rest_of_twist_fixed` holds everywhere; the gcd law predicted `i8`, `i16`
and `i64` before any of them was run.

What varies is **which negation you are handed by default**, and that single
choice cascades: it fixes involutivity, which fixes whether DNE survives, which
fixes which half of classical logic the host silently gives up. No host
announces this. Every host has an opinion.

The sharpest single sentence the census produced:

> A host's negation is not a function. It is a *default* — and the default
> decides which classical law you have already lost before you write a line.
