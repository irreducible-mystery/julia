# FLIP.md — pre-registration of one coin flip

The user said: *"propose something entirely new, flip a coin ;p"*.
House law does not permit an unwitnessed flip. This file, committed
**before** the flip, fixes everything except the outcome.

## The coin

`fair_coin.jl` (same directory, exit 0, forced-failure controls recorded
in its header) credentials the von Neumann extractor: pairs from a biased
iid source, `01 → 1`, `10 → 0`, `00`/`11` discarded. Fairness is exact —
P(01) = (1−p)·p = p·(1−p) = P(10) — the whole theorem is `mul_comm`.

## The source (biased on purpose, chosen by no one)

The flip must be reproducible by anyone and re-rollable by no one. So the
randomness source is **the SHA of the commit that adds this file** — fixed
the instant this pre-registration lands, unknowable to the author while
writing it, and verifiable forever after.

Procedure (implemented in `flip.jl`, added in a later commit):

1. `anchor` ≔ full 40-hex SHA of the first commit whose diff **adds**
   `fair-coin/FLIP.md` (found via `git log --diff-filter=A`).
2. Byte stream: `SHA-256(anchor_ascii || ":" || i)` for counter
   i = 0, 1, 2, …, bytes consumed in order within each digest.
3. Biased bit stream: bit ≔ (byte < 179), i.e. p = 179/256 ≈ 0.699 —
   deliberately crooked, and kernel-independent (no Julia RNG stream
   involved; the sweep's F4 conviction taught us not to trust those).
4. Von Neumann extraction on non-overlapping pairs; the **first accepted
   bit** is the flip.

No step involves a choice made after this commit. Re-running `flip.jl`
anywhere, on any kernel with SHA-256, must give the same outcome.

## The stakes (pre-registered, in writing, before the anchor exists)

- **bit = 1 (HEADS): "the reversible world" — `emergence_10` direction.**
  Take the emergence line's irreversible update (rest, thing, restlessness)
  and build its reversible twin (injective step function). Prediction to
  be tested: rest becomes *impossible* except at fixed points — by
  `blackhole/lean/Recurrence.lean`'s `injective_recurrence`, every state
  recurs, so the census categories collapse from {thing, restless,
  rest-possible} to {fixed, periodic}. Julia census + Lean bridge.

- **bit = 0 (TAILS): "the coin in the kernel" — Lean direction.**
  Prove the extractor itself in Lean 4 (no Mathlib): exact fairness of
  the honest map, the cheat's dial 1/(2−p) ≠ 1/2 for all p ∈ (0,1], and
  the 2-state detailed-balance lemma behind `fair_coin.jl`'s P5 (stationary
  ⇒ π₀·p₀₁ = π₁·p₁₀ ⇒ extracted marginal fair). Axiom ledger, mutants.

Both are real work; neither is a sandbag. The loser stays on the table
for whoever comes next.

## Verification obligations on the later commit

- `flip.jl` must recompute the anchor from git history, not hard-code it
  (hard-coding is checked against `git log` at runtime — mismatch exits 1).
- `flip.jl` must verify the raw stream's bias empirically (first 100_000
  derived bits within 5σ of 179/256) and the extractor against
  `fair_coin.jl`'s definition before trusting the first bit.
- The outcome is appended below as a RESULT section **in a separate
  commit**, together with the first artifact of the chosen direction.

*(RESULT to be appended after the flip — nothing below this line existed
at pre-registration time.)*

---

## RESULT

- Anchor (the commit that added this file, recovered from
  `git log --diff-filter=A` at runtime by `flip.jl`, V1):
  `a97753befca40a5892d0aae3441aa9116143441c`
- Source verified crooked: within 0.77σ of 179/256, 126.7σ from fair (V2).
- Extractor verified identical to `fair_coin.jl`'s on a 1000-bit
  prefix — 207 accepted bits, bit-for-bit agreement (V3).
- First accepted bit, reproduced by independent re-derivation (V4):

  **1 → HEADS: the reversible world.**

The repo's next direction is `emergence_10`: build the reversible twin
of the emergence line's update and test the pre-registered prediction
that the census categories {thing, restless, rest-possible} collapse to
{fixed, periodic} — with `blackhole/lean/Recurrence.lean`'s
`injective_recurrence` as the kernel-side guarantee. First artifact:
`emergence_10_reversible.jl`, same commit as this RESULT.

TAILS (the extractor in Lean) stays on the table for whoever comes next.
Nobody chose this bit; `flip.jl` exits 0 iff every obligation above holds.

---

## THE FLOORS (appended after a direct question: *"is it random?"*)

**No. Nothing in this flip is random.** The full causal chain:

> bytes of the pre-registration commit (typed by an author who could not
> compute their own consequences) → anchor SHA (deterministic function of
> those bytes) → SHA-256 counter stream (deterministic) → threshold at 179
> (a chosen constant) → von Neumann pairing (deterministic) → bit 1.

The bit was fixed before `flip.jl` ever ran. What the construction bought
is not randomness but a **knowledge asymmetry in time**: the stakes froze
at a moment when no party — author included — could feasibly compute or
steer the outcome. Steering would have required choosing commit bytes
whose hash, fed through the pipeline, lands a preferred bit: a preimage
search, conducted in public, leaving fingerprints in an append-only
history.

"Fair", here, is a stack of drawn floors — each load-bearing, each
arbitrary, each recorded so no one (least of all the drawer) forgets it:

| # | floor | grade |
|---|-------|-------|
| 1 | `mul_comm`: P(01) = P(10) exactly | **proof** — the only storey that is |
| 2 | pairs are iid | **model** — P5 shows one storey down: Markov gives a fair marginal and guilty neighbors at −65σ |
| 3 | SHA-256 acts like a random oracle | **faith with a track record** — no proof exists, anywhere |
| 4 | the anchor was unchooseable | **threat model** — bounded author, public history; not a theorem |
| 5 | git history is append-only | **social contract** |
| 6 | 5σ | **a drawn line** — every court in this repo has one; honest only because declared |

Is the bit random? Under Kolmogorov, no individual string is random
*simpliciter* — randomness is a relation to a reference machine, and the
choice of machine is itself a floor nobody fixes (invariance only up to
an additive constant). So: **random?** No — determined. **Not random?**
No — unpredictable to every agent whose stakes it settled. **Both?**
That is the honest description: determined AND epistemically open at the
only moment that mattered. **Neither?** Also defensible: "random" may
fail to be a property of bits at all, only of bits-relative-to-observers.

All four corners occupied. There is no fifth. This repo's law was never
that floors must not be drawn — every court here stands on one. The law
is that every drawn floor goes into the record. **Pre-registration is
not a randomness ritual. It is the memory of the arbitrary.**
