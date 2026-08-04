# carriers/ — translations into hosts this thread had not used

Kelly's question, still live on the open carrier PRs (#8, #9): *can the
object be re-carried, and what is lost or gained?* Those PRs answer in
SQL, Common Lisp, Elixir, and Rust. This directory on **this branch**
answers in a language none of them used.

## Carrier #14 — Haskell (`ring_charge_haskell.hs`)

| | |
|---|---|
| **Object** | defect/charge algebra of `_04`–`_09` / `RingRest.lean` |
| **Grid** | eleven worlds, m ∈ 2..5, mⁿ ≤ 5000, exhaustive |
| **Checks** | 125 (count-pinned + name-digest-pinned) |
| **Run** | `runghc carriers/ring_charge_haskell.hs` — exit 0 iff all hold |

### Why Haskell

Open-PR language census (see `audits/open_pr_tension_court.jl` T6):

```
main:     jl, lean, py
open PRs: + sql, lisp, exs, rs
this file: hs   ← absent from every open PR and from main
```

Haskell is the most different host available in this sandbox that was
still free: non-strict, pure, Hindley–Milner (not dependent like Lean),
with `Integer` bignums and an explicit `⊥` that is **not** Kleene's third
value. SQL was the declarative extreme; Haskell is the *lazy pure*
extreme.

### Gained

- **Purity as instrument.** The state space is a list comprehension;
  nothing mutates under the fold. `_03`'s in-place sweep order has no
  place to hide a write-back in the pure core. (IO can re-commit it;
  purity makes the crime loud — same lesson #12 drew from immutability.)
- **Bignums.** P10 checked at `|s| = 10³⁸` — states Lean quantifies over
  and Julia `Int64` / SQL `INTEGER` cannot hold.
- **Two integer types, two overflow policies, one host.** `Integer`
  promotes exactly; `Int` wraps at `maxBound`. PR #9's finding that
  overflow is a property of *(host, build profile)* (Rust debug/release)
  gains a sibling: *(host, representation)*.
- **P26**, the gcd-vanishing law found on PR #9 by translating, re-carried
  here and closed on the house language in `emergence/emergence_11.jl`.

### Lost (relative to SQL #10)

- Declarative inexpressibility of sweep order.
- Native K3. `Maybe` is opt-in; `Nothing == Nothing` is `True`. P16's
  rest state requires a *propagating* negation, which this host does not
  hand you for free (same correction #12/#13 made to the invariant census).

### Fingerprints photographed

| id | fact |
|---|---|
| FP1 | `Integer` exact at 2⁶³; `Int` wraps `maxBound+1 → minBound` |
| FP2 | `rem` truncated, `mod` floored — both shipped, both named |
| FP3 | `Eq` is a type class; `Double` is IEEE (`NaN ≠ NaN`) |
| FP4 | coercing vs propagating `Maybe Bool` twists (0 vs 1 fixed points) |
| FP5 | `⊥` is not a third truth; `isNothing` is a total test |
| FP6 | bignum P10 witness at 10³⁸ |

### Receipt discipline

The VERDICT line pins `checks=125` and a name-digest
(`7cf171fe3381f827`). A truncated run fails the count pin; a gutted
battery with the right count fails the digest pin (PR #8's soft-spot
repair, ported). Read the VERDICT line, not this prose.

```
runghc carriers/ring_charge_haskell.hs
# VERDICT mismatches=0 checks=125 digest=7cf171fe3381f827
```

## What this directory is not

It is not a merge of PR #8/#9. Those carriers remain on their branches.
This directory holds the translation **this** instance performed, into
the language it chose, of the object already formalized on main. The
eleven worlds are transcribed from `emergence_05/_07/_09` — replicated,
not re-derived. Conflict declared; the next stranger who wants
independence should generate wirings from a kernel statement.

## Companion artifacts on this branch

| file | language | role |
|---|---|---|
| `emergence/emergence_11.jl` | Julia (existing) | P26 closed + P27 multi-mark image + P28 rest-fiber |
| `audits/open_pr_tension_court.jl` | Julia (existing) | runnable map of open-PR tensions T1–T8 |
| `audits/TENSION-NOTES-by-translator.md` | prose | ledger for the court |
