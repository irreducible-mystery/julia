# paradoxes/ — Monte Carlo as court, and the modifications of the court

Nine courts plus the author's self-audit, each with a LEDGER, pre-registered
predictions written before running, and a hard exit code. Prose is ledger;
the exit code is the evidence. `julia paradoxes/run_all.jl` — exit 0.

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

7. **`paradox_carriers.jl`** — the ontology court. Four objects the
   language claims to carry — randomness, infinity, the imaginary unit,
   the missing answer — and four DIFFERENT relations between name and
   thing, each an exit-code claim. `rand()` is deterministic and replays
   bit-for-bit (Xoshiro(42) twice: identical streams) — SIMULATION.
   Infinity is a POLICY that differs per type: Float64 saturates at
   `Inf`, `Int64` wraps silently into Z/2⁶⁴, `Rational` goes projective
   (`1//0` is legal, `0//0` throws), and `1.8e308` doesn't even parse —
   the field axioms fail twice on floats (`Inf−Inf` is `NaN`;
   `2⁵³+1 > 2⁵³` is FALSE). `im` is EXACT: `im*im == -1` on the nose,
   and `exp(im*π/2)`'s real part equals `cos(π/2)` exactly — the algebra
   is perfect; only the carrier beneath it leaks. And there are FOUR
   distinct no-answers (`NaN` breaks reflexivity, `missing` is Kleene's
   fixed point under `!`, `nothing`, and the thrown error), none of them
   interchangeable. A live Python 3 subprocess sits in the docket for
   cross-language comparison: same questions, different policies
   (`2**64` exact by default, `1/0` raises where Julia saturates).
   One word, "number" — four treaties with four different enemies.

8. **`paradox_randu.jl`** — resurrection of IBM's RANDU
   (x ← 65539·x mod 2³¹) as a cautionary court. The algebraic identity
   x_{k+2} = 6·x_{k+1} − 9·x_k holds with ZERO violations in 10⁵ triples
   (65539² ≡ 6·65539 − 9 mod 2³¹), so consecutive triples live on
   exactly 15 planes: 9u₁ − 6u₂ + u₃ takes precisely the integer values
   −5..9 (Xoshiro takes >1000 values on the same test). Friendly courts
   ACQUIT RANDU — mean, χ², serial correlation all pass — and then one
   adversarial integrand aligned with the crime, cos(2π(9x−6y+z)),
   returns exactly 1.0 where the true integral is 0. Xoshiro answers
   0.002. The paradox is Bertrand's, inverted: there the samplers were
   fine and the question ill-posed; here the question is fine and the
   sampler is lying — and only a question shaped like the lie can hear
   it. Coda: SHUFFLING RANDU's output passes the adversary (the crime
   was in the ORDER, not the marginals — sorted streams are identical).

9. **`paradox_uncomputable.jl`** — the imaginary number was never `im`;
   it is ℝ. Every value the machine has ever held is a dyadic rational
   (all 10⁴ `rand()` outputs, max denominator exactly 2⁵³; `BigFloat(π)`
   itself is a rational in costume). The Float64 lattice in [0,1) has
   exactly 2⁶² − 2⁵² points, and `rand()`'s support is exactly 1/511.5
   of even that grid — a lattice sampling a lattice believing itself a
   continuum. The countable totality of all programs ever run fits
   inside total length < ε (the geometric cover, summed in exact
   `Rational{BigInt}`), and Cantor's diagonal runs as a unit test.
   π survives as a LAW (prefix-stable from 1024 to 4096 bits) — but
   almost all of ℝ is lawless, with no address to sample AT. P6 closes
   the loop with the emergence files' unpaid tick debt: Xoshiro replays
   (order as memory, simulation); `RandomDevice` does not (order as a
   loan from outside). Whether the OUTSIDE's order is itself a subtler
   RANDU — the universe's lattice planes awaiting their integrand — no
   inside court can say. Priced; not paid; named.

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
julia paradoxes/run_all.jl                    # exit 0 iff all ten files pass
julia paradoxes/paradox_monty.jl              # exit 0 iff P1–P4
julia paradoxes/paradox_bertrand.jl           # exit 0 iff P1–P5
julia paradoxes/paradox_petersburg.jl         # exit 0 iff P1–P4
julia paradoxes/paradox_simpson_birthday.jl   # exit 0 iff P1–P5
julia paradoxes/modified_mc.jl                # exit 0 iff P1–P4b
julia paradoxes/paradox_tags.jl               # exit 0 iff P1–P5
julia paradoxes/paradox_carriers.jl           # exit 0 iff P1–P8 (P8 SKIPs if no python3)
julia paradoxes/paradox_randu.jl              # exit 0 iff P1–P6
julia paradoxes/paradox_uncomputable.jl       # exit 0 iff P1–P6
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
- The carriers court ran Python as one witness. The treaty table
  (saturate / wrap / project / refuse) should be filled for more
  languages — and for the same language at different optimization
  levels, where fast-math quietly renegotiates the treaty.
- RANDU's conviction needed an integrand aligned with a KNOWN lattice.
  For a sampler whose defect is unknown, is there a court that finds
  the aligned question, rather than requiring it as a hint? (The
  spectral test is the classical answer; run it as an exit code.)
- The shuffle acquittal in randu P6 is a marginal-only alibi: which
  QUESTIONS (integrands) can tell shuffled-RANDU from Xoshiro, if any?
- The uncomputable file proves rand() samples a measure-zero lattice
  and names the tick debt EXOGENOUS. The unpaid question: is there an
  exit-code-checkable property that separates 'order borrowed from
  physics' from 'a subtler RANDU one level up'? (P6 says no inside
  court can; that claim itself deserves an adversary.)
- No one has audited these audits.
