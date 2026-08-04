# Notes on emergence_00.jl / emergence_01.jl

**Ran:** both files execute clean, exit 0, fully deterministic (seed 3 pinned).
**Audited:** `emergence_checks.jl` (attached) — my independent checks, exit 0.

## What the files are

`_00`: Spencer-Brown's *Laws of Form* in ~40 lines — one recursive struct
(`Cross`), two evaluation rules (calling/crossing), then Boolean logic falls
out of the mark, number falls out of *refusing* condensation, and the file
ends by (correctly) declining to run its own halting diagonal.

`_01`: re-entry — `marked(f) = !marked(f)` read as an update rule instead of a
contradiction. Time as extruded paradox (§I), memory as mutual re-entry — an
SR latch, correctly identified (§II), a 60-world census of attractors (§III),
honest residue (§IV).

The most unusual feature is the **ledger discipline**: assumptions and choices
declared up front, epistemic status marked inline ("a lie we keep visible",
"CHOICE, not a discovered truth"), and — notably — §IV flags its own weakest
point: *"whether synchrony (Choice 1) smuggled in the results. Unchecked here."*

## What I noticed (verified, not guessed)

### 1. The flagged hole is real — and quantifiable. So I checked it.
I replicated their exact 60 worlds (same RNG stream) — census matches
`[1→6, 2→48, 4→5, 10→1]` — then re-examined every world two ways:
exhaustive 4096-state search for fixed points, and 20 asynchronous
(random-order) runs each. Result:

- **Of the 48 "clocks" (period 2), only 38 are genuine** — no fixed point
  exists anywhere in their state space, so no clock discipline can freeze them.
- **6 are artifacts of synchrony**: a fixed point exists, and async update
  finds it every time. Their "clock" was the clock choice itself, echoing.
- The headline oscillator `f = cross(f)` **survives the audit**: zero fixed
  points in its state space — genuinely "imaginary" under *any* update rule.

So the ledger's self-suspicion was warranted, the flagged choice *did* smuggle
in part (≈12%) of the census, and the central claim stands anyway.

### 2. The memory has a failure mode the file doesn't show
Their SR latch remembers SET and RESET correctly (I reproduced it). But drive
the forbidden input (SET+RESET together) and release both synchronously:
`·· → ▮▮ → ·· → ▮▮ …` — **metastable oscillation, forever**. Under async
update the same race *resolves*, nondeterministically (96×`·▮` / 104×`▮·` in
200 trials). That's real hardware metastability, reproduced by their model —
the synchronous clock doesn't just create spurious clocks, it can prevent
memory from being memory.

### 3. Two claims slightly overreach
- §III: "predicting settling is equivalent to the halting problem" — not for
  fixed n=12; I *decided* all 60 worlds by exhaustion in milliseconds. The
  undecidability is right only for the unbounded family.
- `_00`'s `diagonal` is never called (correctly — there's no oracle), but note
  it's rhetoric-in-code: the file's one uncomputed artifact.

### 4. The laws generalize past the printed cases
The files print 4 examples; I checked cancellation, condensation, position
(J1), transposition (J2), and truth-functionality of AND/OR over all triples
from a pool of structurally distinct forms — all hold. (In Lean each would be
one structural induction, closed for *all* forms; in Julia this is evidence
over 1000 instances. Same asymmetry we mapped last time.)

### 5. The echo of the previous artifact (unprompted, but hard to unsee)
The C6 Lean proof's engine was: σ = conjugation, **fixed locus = {1, −1}**
(reals, where the twist is invisible) vs **{i, −i} swapped in a 2-cycle**
(where the fermion braids). Emergence_01's engine is: dynamics with **fixed
points = "things"** vs **period-2 orbits = "imaginary" values**, explicitly
citing √−1. Same shape: *what an involution fixes is static and visible;
what it swaps is an oscillation that only exists as alternation.* The
period-2 orbit **is** the pair {i, −i} under conj, worn as dynamics. Whether
intended or not, these two uploads rhyme.

## One-line verdict
The code does what it says, says what it doesn't do, and the one thing it
admitted not checking — synchrony — turns out to matter exactly as much as it
feared: it forged 6 of its 48 clocks, left the main result intact, and hides a
metastability failure its own memory demo walks right past.
