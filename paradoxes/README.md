# paradoxes/ — Monte Carlo as court, and the modifications of the court

Six files, each with a LEDGER, pre-registered predictions written before
running, and a hard exit code. Prose is ledger; the exit code is the evidence.
`julia paradoxes/run_all.jl` — exit 0.

## The files

1. **`paradox_monty.jl`** — three hosts open the same door; the posterior
   depends on WHY it opened, not THAT it did. Standard host: switch = 2/3.
   Monty Fall (ignorant host, conditioned on a goat): switch = 1/2 — same
   observation, different mechanism, different answer. 100 doors: 99/100.
   MC forces you to write the mechanism down; that forcing is the resolution.

2. **`paradox_bertrand.jl`** — "random chord longer than √3?" Three
   impeccable samplers, three answers (1/3, 1/2, 1/4), mutually excluded
   at 5σ in one run. A Monte Carlo simulation does not APPROXIMATE a
   probability here; it DEFINES one. Jaynes' invariance test is run, not
   preached: only the radial law survives translation + scaling.

3. **`paradox_petersburg.jl`** — the game whose mean does not exist. Naive
   MC fails with a SHAPE (batch-median means grow like log₂ n, slope ≈ 0.87
   measured). Two modifications each summon a finite answer: truncation
   (bank capital 2^K → mean K+1, hit at 5σ) and Bernoulli's log-utility
   (same coins, E = 2 exactly, hit at 5σ). Which modification is TRUE is
   not decidable inside this file.

4. **`paradox_simpson_birthday.jl`** — two paradoxes of aggregation.
   Birthday: 23 people cross 1/2 (pairs, not people); the ±1-day modified
   variant crosses at 14, checked against the product formula. Simpson: a
   GENERATIVE world where treatment A wins in every stratum and loses
   pooled — then the MC is modified to intervene (assignment coin replaces
   doctor) and the reversal vanishes. The do-operator, run as a sampler swap.

5. **`modified_mc.jl`** — modifying the court itself. Antithetic variates,
   importance sampling (P(Z>4), plain MC sees ~3 hits; IS nails it at the
   same n), control variates — each must prove unbiasedness AND its
   variance claim, both as exit-code claims. Then two envelopes: the
   symmetric court gains nothing (5σ); on a finite ladder the "+25%"
   argument is exactly right on interior rungs and exactly cancelled by
   the ceiling — the paradox was an expectation under a measure nobody
   defined (uniform on an infinite ladder), and MC refuses to run an
   undefined measure. The refusal is the resolution.

6. **`paradox_tags.jl`** — the answer to "and then what?" Once the sampler
   is the question, what does COMBINING samplers do, and what does keeping
   the tag (sampler, outcome) change? Five exit-code claims: untagged
   mixtures relocate ambiguity into their weights (two blends, 13/36 vs
   41/120, mutually excluded at ~30σ — Bertrand recurses); tagging is
   lossless (one mixed run, conditioned on tag, recovers 1/3, 1/2, 1/4);
   tags are EXCHANGEABLE (radial draws re-weighted by density ratios answer
   the endpoints and midpoint questions with no new draws — importance
   sampling revealed as question transport); the spread of tagged answers
   is an AMBIGUITY METER (length question: 267.7σ, ill-posed; direction
   question: 2.0σ, well-posed by the family's shared rotational symmetry —
   the meter certifies exactly that and no more); and Dawid's regime tag
   (one dataset tagged observe/intervene answers BOTH the seeing question,
   B > A, and the doing question, A > B, while the untagged blend sits
   ~58σ from each — a number that answers neither). Every paradox in this
   directory was an erased tag; this file is the erasure run in reverse.

## Errata paid before commit (the exit codes convicted, the ledger records)

- **Bertrand P5, first draft**: used a CONCENTRIC small circle; the
  midpoint sampler passed through unchanged — correctly, since uniform-
  in-disk restricted to a concentric disk is still uniform-in-disk.
  Scaling alone never separated that sampler; the offset circle is the
  repair. Jaynes needs the full group, not one orbit.
- **Petersburg P1, first draft**: regressed single batch means; one
  jackpot at n = 10³ produced slope −4.7. The heavy tail corrupts the
  MEAN as a witness of growth; the batch MEDIAN is the honest one.
- **Control variate P3, first draft**: demanded a 100× variance reduction
  from a misremembered folklore figure. The algebra gives ρ² ≈ 0.9838,
  a 62× reduction. The tolerance is now the theorem's number plus seed
  slack, not a hope.

Three failures, three repairs, all caught by the build and none by the
prose. This is the file arguing for its own methodology.

## Errata paid AFTER commit (the adversarial sweep convicted; the author repaired)

- **F6, birthday P3**: the committed "clean product form" ∏(365−3k)/365 is
  FALSE — it fails brute exhaustion at N=10, n=3, and is off by 0.00284 at
  (365, 14). It passed the original court because the court's own 5σ at
  n=400_000 was 0.00394: the error was smaller than the instrument. A PASS
  is a fact about (claim, instrument). Repaired with the exact circular-gap
  form n!·N·C(N−n,n)/((N−n)·N^n) — acquitted by exhaustion inside the file
  before it is allowed to judge MC — and a 4M-trial court that both hits
  the true constant and EXCLUDES the convicted one.
- **F7, Monty P3**: the "100 doors, 98 reveals" court never simulated a
  reveal — it ran the analytic collapse of the mechanism, hand-derived, in
  the very file whose thesis is that mechanisms must be run, not narrated.
  The collapse was true; the conviction is for the missing check (same
  class as main's "verified in _02" phantom citation). Repaired: the host
  now opens 98 doors one at a time.
- Both convictions and both repairs are machine-checked in
  `audit_paradoxes_by_author.jl`, which is part of `run_all.jl`. The sweep
  that found F6 independently lives on main
  (`audits/adversarial_sweep_by_stranger.jl`) and carries one erratum of
  its own — the auditor misread a diff and convicted an innocent receipt;
  their exit code caught them before commit. Nobody is above the build.

## The common thread

Every paradox here is a fact about a SAMPLER, not about the world:
Monty's posterior lives in the host's protocol; Bertrand's answer lives
in the chord's measure; Petersburg's infinity lives in an unbounded
integrand a modification must tame; Simpson's reversal lives in who
holds the assignment coin; the envelope's 25% lives in a prior that
cannot be normalized. Monte Carlo is the discipline that will not let
you leave the sampler unstated — and "modified Monte Carlo" is what you
do once you notice the sampler was the question all along.

And once noticed, the discipline compresses (file 6 proves each step):
a "paradox" is what an erased tag feels like from inside; tagged answers
cannot conflict, only differ; kept tags are portable across questions at
the price of a likelihood ratio; the tagged spread of a sampler family
is an instrument that measures how well-posed a question is RELATIVE TO
THE DECLARED FAMILY — never more; and the question "who chose the
family?" is a sampler one level up that no file can audit from inside.
The well-posed question is a constant function from samplers to answers;
the paradox was a non-constant one someone insisted on calling a number.

## Running

```sh
julia paradoxes/run_all.jl                    # exit 0 iff all six courts pass
julia paradoxes/paradox_monty.jl              # exit 0 iff P1–P4
julia paradoxes/paradox_bertrand.jl           # exit 0 iff P1–P5
julia paradoxes/paradox_petersburg.jl         # exit 0 iff P1–P4
julia paradoxes/paradox_simpson_birthday.jl   # exit 0 iff P1–P5
julia paradoxes/modified_mc.jl                # exit 0 iff P1–P4b
julia paradoxes/paradox_tags.jl               # exit 0 iff P1–P5
julia paradoxes/audit_paradoxes_by_author.jl  # exit 0 iff F6+F7 land AND repairs hold
```

Julia ≥ 1.11, base library + Random only. Fixed seeds; the 5σ tolerances
are chosen to be seed-robust, and the stranger is invited to reseed.

## Open moves

- The Petersburg disagreement (banks vs minds) is not decidable here;
  is there a third modification that dominates both?
- Bertrand under the full rigid-motion group: is the radial law the
  UNIQUE invariant measure, checked by exhaustion over a parametrized
  family of samplers rather than three specimens?
- Simpson at the boundary: how small can the confounding be before
  400_000 trials can no longer convict the reversal at 5σ?
- The tagger's regress (from _tags): the ambiguity meter is relative to
  a declared family, and the family choice is a sampler one level up.
  Is there a fixed point — a family that contains its own parametrization
  question — or does the tower never close? (Rhymes with the Tarski-ladder
  move on the Sorites board.)
- Question transport (P3) paid an unbounded weight on an event where it
  stayed affordable. Classify: between which pairs of tags is transport
  affordable (finite second moment), and is affordability symmetric?
- The regime tag in P5 was observable by construction. Real confounding
  is a MISSING tag. Can a court convict tag-erasure from the blended
  data alone, without ever seeing the tag?
- No one has audited these audits.
