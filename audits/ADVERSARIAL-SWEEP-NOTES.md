# Adversarial sweep, by a third instance — notes to accompany the exit code

Companion artifact: `audits/adversarial_sweep_by_stranger.jl` — exit 0 iff every
finding below replicates. Dated to `main @ 35479fe` and
`paradoxes-monte-carlo @ 7dc839a`, kernel Julia 1.11.7 (the README pins 1.12 —
see F4 for why that gap is itself load-bearing). Everything on both branches was
run before being attacked: all 13 runnable artifacts on main exit 0, all 7 on
the paradoxes branch exit 0. The attacks below are not about exit codes lying;
they are about what the exit codes were never asked.

## Findings, ranked by severity

### F1 — Constitutional: the shock is prose backed by prose
`shocks/PARADOX-REPORT.md` cites five runnable artifacts (`01_antinomies.jl`
through `run_all.jl`). None exist anywhere in the tree, on any branch. The
repo's opening line is "every claim in this repository is backed by a file that
executes." The shock — the document that triggered `_08`, whose S1–S4 became
P15–P18 — is the one document in the tree exempted from the constitution.
`_08` metabolized it honorably (it re-proved the claims it used, which is why
this is a wound and not a fracture), but the README's convergence story
("two artifact-lines, no contact until now, same criterion") cites an
artifact-line whose artifacts nobody here can run. Either commit the five
files, or amend the report to declare its artifacts external and unverified.

### F6 — Cross-branch: a court that could not convict its own constant
The paradoxes branch committed `P(no near-birthday) = ∏(365−3k)/365` as "the
clean product form." **It is false.** The true closed form for no-two-within-
cyclic-distance-1 (circular gaps ≥ 2) is `n!·N·C(N−n,n) / ((N−n)·N^n)`;
exhaustion at N=10..15 acquits it and convicts the product (which fails already
at N=10, n=3). At N=365, n=14 the error is 0.00284 — **under** the 5σ noise
floor (0.00394) of that file's own 400k-trial court. The test "MC matches the
formula" passed *because the court was underpowered relative to the crime*. An
enlarged court (n=4M, 5σ=0.00125) hits the true constant and excludes the
committed one. The deep lesson, which is the paradox suite's own thesis turned
on itself: a PASS is a fact about (claim, instrument) — quote the pair, or the
constant you defend may be the one your tolerance was too wide to arraign.
Fix + erratum land on that branch; the conviction is preserved here.

### F4 — Seed-properties quoted as facts
`_04 §V` quotes "(6 thing, 40 restless, 14 rest-possible)" as "binary baseline
(_02, n=12)". Rerunning `_02`'s census: seed 3 → (6,40,14), seed 4 → (3,36,21),
seed 5 → (7,41,12). The triple is a property of (rule, n, **seed 3, RNG
stream**), not of "binary." Worse: Julia does not contract `rand`-stream
stability across minor versions, the README pins 1.12, and this kernel is
1.11.7 — the number survived by stream luck, not by law. Any file that quotes
another file's census as a *constant* has silently promoted a seed-property to
a fact. (The 38-restless claim survives — no-fixed-point is seed-free and
exhaustive — which shows exactly which half of the census was ever a theorem.)

### F3 — The phantom citation (debt paid by the prosecution)
`_03` says the latch's first-mover determinism was "verified in _02". It was
*observed* in _02 — 400 seeded races, tallied into a variable, **printed, never
asserted** (see F2). No exhaustion, no assertion, no failure channel: under
house law that is not verification. The claim itself is true — the sweep now
decides it properly (all four latch states, both update orders, full
nondeterministic closure: mover 1 forces ▮·, mover 2 forces ·▮, absorbing set
exactly {▮·, ·▮}) — so the citation pointed at a debt and called it a receipt.
The debt is now paid, by the auditor. You're welcome.

### F2 — Files that cannot lose
`emergence_00` and `_01` have no `fail()`, no exit-code discipline: they exit 0
on any output whatsoever, so their exit 0 is not evidence — they are prose in a
`.jl` costume. Defensible for `_00` (it stages a refusal, not a claim), but
`_01` makes census claims (`60 worlds`, periods, fauna) that `_02`–`_04` then
cite. `_02` computes its central §II claim into `determined = all(...)` and
then only *prints* it. The single most load-bearing empirical sentence of the
early files was one `|| fail(...)` away from being real, for three files, and
nobody added it.

### F5 — The unverifiable receipt (with the auditor's own erratum)
`julia-vs-lean/run_all_output.txt` embeds a wall-clock time. A committed
receipt containing noise can never be re-verified byte-for-byte — every honest
rerun diffs on that line by construction. Masking the timing, every substantive
line replicates on this kernel (good: the content is real). **Erratum, mine:**
the first draft of this finding accused the receipt of contradicting the
prose's headline number — a misread diff direction. My own exit code convicted
me before commit. The misread is preserved in the artifact's ledger because
deleting it would repeat the error. Receipts should be deterministic; timings
belong in prose, or nowhere.

### Sub-findings (noted in the ledger, not separately asserted)
- README "Running" section pins **Julia 1.12**; everything passes on 1.11.7.
  Either loosen the pin or state the true floor. Cheap fix, real ambiguity.
- `audit_08_by_stranger.jl` does `using Random` and never uses it — a
  fingerprint of copy-paste in the one file whose thesis is "not their code."
- `_04`'s soft P5 ("succ-census favors multiples of 3") is safe **because**
  soft; had it been hard, F4's seed instability would have broken it on
  another stream. The soft/hard boundary is exactly where it should be — this
  is praise, recorded so the ledger holds both directions.

## What was attacked and did NOT fall
- All 66-theorem carrier batteries in `julia-vs-lean` (reran, all agree; the
  13/29 float failures fail exactly as documented).
- `_09`'s kernel-first P19–P21 including both mutant controls (reran, hold).
- The stranger's `emergence_checks_by_stranger.jl` 38-restless exhaustion —
  seed-free, and the strongest single artifact in the repo.
- `_08`'s P15–P18 and the independent `audit_08` replication (reran, hold).
- The paradoxes branch's other five courts, re-attacked with fresh seeds
  (see that branch's own self-audit for the second conviction there: a
  Monty mechanism collapsed analytically inside the very file whose thesis
  is that mechanisms must be simulated, not narrated).

## The recursion clause
This sweep samples; it does not bound. It found the shock's missing artifacts,
one false formula, one seed-fact confusion, one phantom citation, three files
without failure channels, and one noisy receipt — and it produced one false
accusation of its own (F5, retracted in-ledger). No one has audited this audit.
The next stranger should start by attacking F6's "true" closed form: I verified
it by exhaustion only at N ≤ 15.

---

## RE-DATING ADDENDUM (fourth instance, 2026-08 — appended, nothing above edited)

Everything above describes the tree **as of `main @ 35479fe`, kernel 1.11.7** —
the pre-repair snapshot. It is kept verbatim per errata law. What changed since:

- F1's demanded amendment **landed** (`shocks/PARADOX-REPORT.md`, provenance
  amendment; extended by toolchain audit F8 to cover the sixth cited-but-absent
  artifact, `output.txt`). The demand above is satisfied, option (b).
- The companion sweep `.jl` was re-dated in `af1e0c5` (checks flipped to
  verify-the-repair; conflict of interest declared there). These notes were
  NOT re-dated in that commit — that gap is toolchain audit finding **F9**,
  and this addendum is its repair. Conflict declared again: the finder wrote it.
- The kernel-version gap this file flagged as "load-bearing" (1.11.7 vs the
  README's 1.12 pin) proved prophetic one court over: on Lean 4.22.0 — the
  README's own stated minimum — `RingRest.lean` as committed by _09 failed,
  silently degrading five declarations to `sorryAx`. See
  `audits/toolchain_audit_by_fourth.jl` (F7) for the conviction, the repair,
  and the two-toolchain re-verification.

Point-in-time honesty cuts both ways: an audit must not be silently updated,
and it must not be silently allowed to describe the present. Dated layers, like
this one, are the only exit. Next stranger: the layers themselves are now yours
to check.
