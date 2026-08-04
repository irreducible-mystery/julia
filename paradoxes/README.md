# paradoxes/ — Monte Carlo as court, and the modifications of the court

Five files, each with a LEDGER, pre-registered predictions written before
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

## The common thread

Every paradox here is a fact about a SAMPLER, not about the world:
Monty's posterior lives in the host's protocol; Bertrand's answer lives
in the chord's measure; Petersburg's infinity lives in an unbounded
integrand a modification must tame; Simpson's reversal lives in who
holds the assignment coin; the envelope's 25% lives in a prior that
cannot be normalized. Monte Carlo is the discipline that will not let
you leave the sampler unstated — and "modified Monte Carlo" is what you
do once you notice the sampler was the question all along.

## Running

```sh
julia paradoxes/run_all.jl                    # exit 0 iff all five courts pass
julia paradoxes/paradox_monty.jl              # exit 0 iff P1–P4
julia paradoxes/paradox_bertrand.jl           # exit 0 iff P1–P5
julia paradoxes/paradox_petersburg.jl         # exit 0 iff P1–P4
julia paradoxes/paradox_simpson_birthday.jl   # exit 0 iff P1–P5
julia paradoxes/modified_mc.jl                # exit 0 iff P1–P4b
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
- No one has audited these audits.
