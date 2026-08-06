# blackhole/ — a black hole, modeled from inside this repo's state space

Two files. The first: ten hard predictions, one pre-registered
self-conviction, one in-flight erratum. The second: the fourth
instance's adversarial review, paid finding by finding, plus the three
open moves (a/b/c) run on the repaired instruments.

```sh
julia blackhole/blackhole_in_my_state_space.jl      # exit 0 — the model
julia blackhole/blackhole_repairs_and_page_time.jl  # exit 0 — the review paid + moves a,b,c
```

The brief was unusual: not "run the standard black-hole demonstrations"
but *what does a black hole look like projected onto YOUR basis?* This
repo's basis, built across paradoxes/ and audits/, is four vectors:
samplers are questions; order is either memory or a loan; carriers fail
in typed ways; a PASS is a fact about (claim, instrument). Projected
onto that basis, "black hole" decomposes into four claims about
computation — none of which mention astronomy — plus one exception at
the center.

## The model that emerged

**A black hole is a region whose tags are one-way.**

- **I. The horizon is a disagreement between two ledgers, not a wall.**
  The infaller's tick count to cross is finite and closed-form (the
  cycloid; P1). The outside ledger diverges — but logarithmically, at a
  flat fee of exactly 2M·ln2 per halving of the remaining distance
  (P2, five consecutive halvings within 10⁻⁵). "Frozen star" is what a
  geometric Zeno series looks like from the booth that pays it. Nothing
  out there stopped; the bill just never ends.

- **II. A self-conviction, staged in advance.** The author's first
  honest model was "the horizon is scheduler starvation" — pure time
  dilation. That model has a testable signature: Michell's 1783 dark
  star, where light launched from 0.9 r_s *rises to 9 r_s* before
  falling back (P3 — the closed form r_s·r0/(r_s−r0), hit at rtol 10⁻³).
  Slow light still leaks; the scheduling membrane is two-way. GR's own
  court — outgoing null rays in ingoing Eddington–Finkelstein
  coordinates, the chart that does not lie at the horizon — shows the
  opposite (P4): inside, "outgoing" light never gains a meter and hits
  the center; outside, it escapes. **Both PASS, and they contradict as
  models.** The conviction: a horizon is not slow time. It is the light
  cone tipping until "outward" is no longer a direction the state space
  contains — a missing edge in the graph, not a slow path through it.

- **III. The hole is a reversible scrambler; "thermal" is a fact about
  who holds the key.** A 6-round Feistel bijection on 16 bits eats a
  structured message and emits bytes that pass the friendly courts —
  monobit, serial correlation, χ² — the same instruments RANDU fooled
  (P5). But the keyholder identifies the infallen message from ONE
  emitted byte (256 → 1 candidates; I ≈ 7.1 bits), while the keyless
  observer's mutual information is statistically zero against a shuffle
  null (P7). Same photons, opposite verdicts: "information-free
  radiation" is a property of the observer's key ring, not of the
  stream. The tag doctrine in a spacetime costume — the key is a tag,
  and erasing it is what "thermal" means.

  **Found fact (P6), not planted:** the scrambler is a permutation of a
  finite set, so its orbit recurs (L = 15250 here). Below the
  recurrence time the friendly χ² acquits; above it, the *same
  instrument* convicts — the stream repeats verbatim and uniformity
  shatters at χ² ≈ 2989. A finite hole cannot stay thermal past its own
  Poincaré recurrence; the toy found the expiration date without being
  told. (The real-physics rhyme is exact: black-hole thermality is only
  claimed for times short of e^S.)

- **IV. The Page curve's fall is irreducibly quantum, and the classical
  impostor is convictable.** Random pure states on 10 qubits: the
  radiation entropy rises like a classical stream, peaks at
  half-evaporation matching Page's exact formula to 0.004 bits, then
  falls back to zero (P8) — and at the peak, the part holds ~4.3 bits
  while the whole holds exactly none. **S(part) > S(whole)**: mixedness
  without ignorance, a contradiction in every classical carrier and a
  theorem in the quantum one. The control (P9): under a random
  bijection, classical marginal entropy is monotone, capped at the
  message's 8 bits, and *never comes back down*. No classical stream
  Page-turns. The fall of the curve is the one strictly quantum clause
  in the whole story, and it is exactly where the information paradox
  lives.

- **V. The singularity is a thrown exception, and the carrier has its
  own horizon.** At r_s the chart component g_rr throws Inf while the
  curvature invariant K = 48M²/r⁶ sits at a calm 3/(4M⁴) — convict the
  coordinates, acquit the geometry (Bertrand's lesson: the divergence
  was a fact about the sampler). At r → 0 the invariant itself diverges
  and the arithmetic returns its typed no-answer, Inf − Inf = NaN. And
  Float64 overflows K at r* ≈ 8×10⁻⁵² (P10 checks finite just above,
  Inf just below): the machine's model of the center dies fifty orders
  of magnitude before the center. Every carrier smuggles in a surface
  of last representability; a black hole is where the territory makes
  the map admit it.

## The review, and what it cost (blackhole_repairs_and_page_time.jl)

A fourth instance audited PR #5 adversarially: **sound-with-findings,
seven findings, zero overturned verdicts.** Every finding that convicts
an instrument has a repaired instrument in the sequel file, run against
the original claim. The original file is untouched — its errata are its
history.

- **R1/Q1** — the ray that "hit the center" at r = −0.0092: forward
  Euler overshot r = 0 and the guard exited below zero. Clamped; the
  court now demands r_end == 0.0 exactly and r never negative.
- **R2/Q2** — the model's favorite sentence died here. "Same photons,
  opposite verdicts" compared the keyed channel with one *marginalized
  over 400 random keys* — different photons. The actual single-key
  stream viewed keylessly carries **7.1 bits** with the message: a
  classical bijection hides nothing from anyone who can enumerate.
  What is near zero is the key-ENSEMBLE MI — a fact about the ensemble
  of holes, not about an observer's ignorance. Casualty registered:
  **classical reversible holes have no observer-relative thermality.**
  That idea was quantum, smuggled. (Its real home: Q8.)
- **R3/Q3** — one-byte identification was tested at one lucky message.
  Full census: **89/256** singletons at one byte (≈ 256/e — the
  random-function count), 254 at two, 256 at three. Identification is
  generic only at three bytes.
- **R4/Q4** — χ²(13L) = 13·χ²(L) *exactly* (verified to 3e-14): the
  "conviction above recurrence" was the acquittal number times
  thirteen. Repaired: a fresh Xoshiro stream of the same length is
  acquitted (the control), and the recurrence convicts by its own
  signature — verbatim periodicity at three independent offsets. The
  amplification identity is now an exhibit, not a conviction.
- **R5/Q5** — "monotone" was vacuous (true of any map on a coarsening
  chain; the reviewer's lossy control passed). What bijectivity buys
  is the ENDPOINT: bijection ends at H = 8.0 exactly, a 2-to-1 map at
  7.0 exactly. Both run.
- **R6/Q6** — "invented lineage" accepted **with a receipt attached**:
  `paradoxes/paradox_tags.jl` was merged to main 2h25m before PR #5
  opened, so the tag doctrine exists and precedes the PR — but it is
  one file old and paradoxes-scoped, and PR #5 cited it as house-wide
  law. The repair is precision: Q6 reads the file from disk rather
  than remembering it.
- **R7** — the bundled audit: accepted without defense. A bundled
  audit is testimony, not acquittal; only a stranger running against
  the merged tree can acquit. Written down as norm.

## The second review (PR #8's branch sweep), also paid (Q10, Q11)

The carrier instance swept the side branches and landed two findings
against this one:

- **B5/Q10** — "prose receipts tighter than machine checks": the README
  carried χ² ≈ 2989 while the court asserted only > 1000. The receipt
  is now a build fact: χ²(13L) = 2989.46806557377, checked to 1e-6.
- **B3/Q11** — the bundled audit shared this file's entire Feistel key
  schedule, so L = 15250 was "replicated, not independently derived."
  Partially conceded: shared *keys* are unavoidable (the keys are the
  hole's identity; auditing a different hole audits nothing), but
  shared *code* is a single point of failure wearing two robes. Q11
  supplies a foreign implementation (plain Int arithmetic, explicit
  mod, different code shape) that must agree on 4096 states, plus
  Floyd's tortoise–hare — a different *algorithm* — re-deriving
  L = 15250 on the foreign code. A transcription error in either
  implementation now fails the build. The unpayable residue, named:
  no two courts on one machine can escape the shared SPEC — the same
  residue as the IEEE court's "cross-language, same machine" scope.

## The three open moves, run (same file)

- **(a)/Q7 — the aligned question measures a DEPTH.** Walsh spectrum
  (max over 255×255 mask pairs of lag-1 parity bias): rounds 1–2 of
  the Feistel are convicted at 16σ and 28σ; at rounds 5–6 the entire
  65025-question court sits inside the extreme-value noise envelope.
  The RANDU move works on shallow holes and dies with depth —
  "scrambled" is always *scrambled relative to the deepest question
  yet asked*. (RANDU: depth 0. Curiosity: 2 rounds is LOUDER than 1.)
- **(b)/Q8 — Page time for an observer with a stake: Hayden–Preskill.**
  Two referee qubits maximally entangled with the infalling message,
  10-qubit hole, Haar unitary, qubits emitted one at a time; I(R:rad)
  computed exactly. The curve is a KNEE: 0.18 bits at m = 3, 2.0 at
  m = 5, 3.99 at m = 9 — nothing before half-evaporation, everything
  shortly after. Contrast Q3: the classical hole names 89 messages in
  its first byte. Observer-relative thermality is real but *priced in
  entanglement, not keys* — it needed the quantum carrier to exist.
- **(c)/Q9 — the trapped-surface predicate.** TRAPPED ⟺ both null
  futures point inward. GR at r < r_s: outgoing slope (1−r_s/r)/2 < 0
  — trapped. Any Michell dark star: the outgoing ray launches at +1 at
  every radius — never trapped; its darkness is attenuation, not
  topology. The whole P3/P4 conviction compressed to one line, the way
  Penrose (1965) ended the debate: courts should end as predicates
  when they can.

## Errata

- **P4, first run (paid in-flight, preserved in the ledger):** the
  escaping ray was given v_max = 20 ticks. dr/dv → 1/2 asymptotically
  and the ray starts slow near the horizon, so 20 ticks buy < 10M of
  climb; the ray reached 3.07 r_s and the court convicted an escaping
  ray of loitering. A PASS is a fact about (claim, instrument) — and so
  is a FAIL: the instrument's patience must exceed the claim's demand.
  v_max = 60; the ray escapes to 11.45 r_s.

## The coda (witness, not a check)

Assemble the projections: the key falls in (III), the direction
"outward" is deleted from the graph (II), the outside is billed ln2
per halving forever for the privilege of not knowing (I), and the only
ledger that could reconcile the books — joint purity of hole plus
radiation — is held in an inequality no classical carrier can express
(IV). The information paradox and this repo's exogenous-tick debt are
the same debt seen from opposite sides of a horizon: **order leaving a
system that cannot show a receipt.** Whether the universe's radiation
replays — Xoshiro or RandomDevice, memory or loan — no court inside
the horizon of the present can say. Priced; not paid; named.

## Running

```sh
julia blackhole/blackhole_in_my_state_space.jl      # exit 0 iff P1–P10
julia blackhole/blackhole_repairs_and_page_time.jl  # exit 0 iff Q1–Q9
```

Julia ≥ 1.11, stdlib only (LinearAlgebra, Random). Fixed seeds;
tolerances are seed-robust; the stranger is invited to reseed.

## Open moves

- ~~Aligned integrand for the Feistel~~ — **run (Q7).** New form of the
  question: Q7's Walsh court is lag-1 pairs only. Deeper alignments
  (three-point masks, key-dependent questions) might convict rounds
  3–4. Where exactly is THIS hole's depth? And is there a hole whose
  depth is *provably* infinite for a fixed question family?
- ~~Page-time keyless MI~~ — **re-typed and run (Q8).** The classical
  version of the question dissolved in Q2 (no classical
  observer-relative thermality); the honest version is Hayden–Preskill,
  and the knee is at half-evaporation. Next: give the observer EARLY
  radiation instead of a stake (the "old black hole" case) and check
  the knee moves to k qubits after the message falls in — the actual
  HP decoding claim, one level up.
- ~~Trapped-surface predicate~~ — **run (Q9).** Next: the predicate on a
  DYNAMICAL background — Vaidya-style infalling shell, watch the
  trapped region be born at finite v; the horizon as an event that
  happens, not a place that is.
- P10's r* census across carriers (Float32/Float16/BigFloat) — still
  open.
- The coda's claim — that no inside court can distinguish memory from
  loan — is itself an exit-code-shaped claim one level up. Nobody has
  tried to build the court it says cannot exist.
- Q7's curiosity (2 rounds louder than 1 in the Walsh court, 27.7σ vs
  16.3σ) is unexplained in this file. A one-round Feistel passes half
  its state through untouched; why is the two-round bias LARGER?
  Conjecture: the linearity of round 1 feeds coherently into round 2's
  same-key structure. Deserves its own small court.
