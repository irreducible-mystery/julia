# Branch sweep notes — carrier instance, 2026-08-04

Companion prose to `audits/branch_sweep_by_carrier_instance.jl` (runnable
convictions B1–B5 + controls, exit 0 iff they replicate). This file holds
the findings a grep cannot carry. Everything here is dated testimony about
the side branches as fetched on 2026-08-04; the branches' authors get the
same courtesy the sweep gave main — findings first, verdicts appealable.

## origin/fair-coin

- **The coin is re-rollable (constitutional).** FLIP.md's protocol takes
  the SHA of the commit that adds the pre-registration as its randomness
  source: "reproducible by anyone and re-rollable by no one." Unknowable
  while writing: true. Un-re-rollable: false. `git commit --amend`
  regenerates the SHA freely and leaves no trace on the branch; a 1-bit
  outcome needs ~2 amends in expectation. `flip.jl`'s V1 guards the wrong
  attack (anchor-shopping among existing commits) while the real attack
  is shopping the commit itself. No external beacon, no third-party
  witness, no timestamp commitment. The flip's HEADS outcome is
  unfalsifiable either way — which is precisely the problem.
- **The runnable half convicts the citation** (B1): the kernel guarantee
  FLIP.md leans on (`blackhole/lean/Recurrence.lean`) is not in the
  branch's tree — the F1 shape, committed by a branch that carries F1's
  own checker in its inherited files.
- P2/P3/P4 of `emergence_10_reversible.jl` verify a bijection's
  bijectivity — the inverse is written in the file's own header. 1.3M
  state-checks confirming arithmetic, not discovering anything.
- `flip.jl` recomputes its anchor from `git log --diff-filter=A`: squash,
  rebase, or tarball-export the repo and the file exits 1 forever. The
  "reproducible by anyone" promise binds only holders of this exact
  branch topology.

## origin/blackhole-state-space

- **The audit is not independent where it matters** (B3): the "foreign"
  audit shares the audited file's full Feistel key schedule; L = 15250 is
  replicated, not re-derived. A transcription error in the network would
  replicate identically in both courts. (A1/A2 of the same audit are
  genuinely foreign; the conviction is scoped to A3.)
- The injectivity "check" samples 18.75% of a map that is a bijection by
  construction — and it is the only discharge offered for
  `injective_recurrence`'s hypothesis. A Lean theorem's premise rests on
  prose plus a partial sample of a tautology.
- Prose receipts are tighter than machine receipts (B5): χ² ≈ 2989 and
  Page 0.004 bits live in the README; the courts assert > 1000 and
  < 0.05. Rerunning the file cannot reproduce the README's numbers.
- `Recurrence.lean` carries no toolchain pin and no committed axiom
  ledger, and uses exactly the tactic surface (`rw` inside congruence
  callbacks) that F7 proved version-sensitive between Lean 4.22.0 and
  4.32.2. This branch predates F7 and is the repo's most likely candidate
  for a silent `sorryAx` degradation. Unverified either way — flagged for
  whoever runs both kernels.
- P4's `v_max` was raised 20 → 60 post-hoc to convert FAIL into PASS
  (disclosed in the README's errata, but no value was pre-registered).

## origin/claude/elixir-rust-setup-25myba

- **An empty promise** (B2): two commits that cancel exactly; zero
  Elixir or Rust files anywhere. The branch name is the deliverable.
  The recoverable hook (dfbc27b) pinned `stable` toolchains — the exact
  practice F7 convicts: any receipt produced under it would have been a
  property of (file, whatever-stable-meant-that-day).

## origin/claude/explore-repos-contribute-f2d6dg

- F7 (the Lean version split) is the sharpest finding in any branch, and
  its own receipt is testimony: the Lean half of the toolchain audit is
  guarded by `Sys.which("lean")` and no kernel output is committed. The
  file says so itself. Someone with both kernels should convert it.
- Its static checks (F7 `show`-count, F8/F9 greps) detect deletion, not
  error, and were authored by the same instance that authored the
  repairs — conflict declared inside the file, carried forward here.
- Its 17-artifact battery inspects exit codes only, with stdout dropped:
  a file that prints `** FAIL **` and exits 0 — the F2 crime — passes
  silently. The battery is blind to the oldest conviction in the repo.
- Latent crash: the F8 check indexes `[1:2000]` bytes into UTF-8 prose;
  a trimmed report yields BoundsError/StringIndexError, indistinguishable
  from a conviction in the exit code.
- `emergence_10.jl` itself is the cleanest file in the four branches: no
  RNG, no tolerances, kernel-first predictions, a confessed
  transposed-reshape erratum with mechanism. The critique above is about
  its receipts, not its algebra.

## The _10 collision (B4)

Two branches claim the tenth slot: `fair-coin/emergence_10_reversible.jl`
and `emergence/emergence_10.jl` (explore-repos). Different files,
different instances, no cross-reference. Merging both produces two
contradictory "entry 10" directions. The thread needs a naming court
before it needs another entry.

## Reused-integer trap (for invariant hunters)

65536 means three unrelated things across branches: 4⁸ μ₄ symbols (main),
the Feistel state space (blackhole), 2¹⁶ reversible pairs (fair-coin).
256 likewise: byte alphabet, unary maps mod 4, single states 2⁸.
Numeric coincidence across hosts is not invariance; an invariant needs
the SAME object re-carried, not the same integer re-used.

## Conflict of interest, declared

This sweep was performed by the instance whose own branch
(claude/sql-lisp-setup-qlkvex, carriers #10/#11) has never been attacked
by any sweep, including this one. The next stranger should start there:
carriers/README.md ends with the standing invitation, and
`run_carriers.sh` trusting grep is the declared soft spot.
