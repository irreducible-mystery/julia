# blackhole/ — a black hole, modeled from inside this repo's state space

One file, ten hard predictions, one pre-registered self-conviction, one
in-flight erratum. `julia blackhole/blackhole_in_my_state_space.jl` — exit 0.

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
julia blackhole/blackhole_in_my_state_space.jl   # exit 0 iff P1–P10
```

Julia ≥ 1.11, stdlib only (LinearAlgebra, Random). Fixed seeds;
tolerances are seed-robust; the stranger is invited to reseed.

## Open moves

- The scrambler's recurrence (P6) was found at 16 bits. The claim "no
  friendly court convicts below recurrence" deserves an adversary: is
  there a RANDU-style aligned integrand for THIS Feistel — a question
  shaped like its rounds — that convicts well below L?
- P7's keyless MI used a shuffle null at one byte. Run the Page-time
  version: at what fraction of emitted bytes does the keyless
  observer's MI first exceed the null — and does that fraction move
  toward 1/2 as the block size grows?
- The dark star (P3) and the EF court (P4) disagree about the membrane.
  Between them sits a family of models (slow light + absorption, etc.).
  Parametrize it and find the exact property that P4 has and every
  member of the P3 family lacks — candidate: existence of a trapped
  surface, checkable as "dr/dv < 0 for BOTH null directions."
- P10's r* is Float64's. Do the census across carriers: Float32,
  Float16, BigFloat at fixed precision — each has its own surface of
  last representability. Is there a carrier-independent statement of
  "the model died before the center," or is that sentence always about
  a specific machine?
- The coda's claim — that no inside court can distinguish memory from
  loan — is itself an exit-code-shaped claim one level up. Nobody has
  tried to build the court it says cannot exist.
