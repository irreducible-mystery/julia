# CLAUDE.md — irreducible-mystery/julia

Project memory for sessions working in this repository. It describes what is
here, how to run it, and the conventions the existing files already follow.

## What this repository is

A long-running investigation conducted in **runnable artifacts** rather than
prose. The main thread starts from Spencer-Brown's calculus of indications and
builds outward — logic and number from one primitive, re-entry, time and memory,
a rest/restless dichotomy, a conserved "charge" on wirings, and the paradoxes
that fall out of it. Around that thread sit three supporting tracks: a Lean 4
kernel track, a cross-language carrier track, and an audit track.

The house rule is stated in `README.md` and enforced by every file:

> Every claim in this repository is backed by a file that executes;
> read exit codes, not prose. Prose is ledger, not evidence.

## Layout

| Path | Contents |
|---|---|
| `emergence/` | The main thread: `emergence_00.jl` … `emergence_10.jl`, each a numbered installment with its own ledger and predictions |
| `emergence/lean/RingRest.lean` | The kernel side of the thread — the closed, quantified half of what the Julia files can only exhaust |
| `audits/` | Reviews of the other files, written by whichever participant was not the author; `*.md` notes plus runnable `*.jl`/`*.sh`/`*.py` checks |
| `paradoxes/` | Monte Carlo as court: Monty Hall, Bertrand, St Petersburg, Simpson/birthday, and modifications of the method itself |
| `julia-vs-lean/` | The same formal object (μ₄ with conjugation twist) rebuilt in nine Julia carriers and compared against the Lean build; `run_all_output.txt` is a byte-reproducible receipt |
| `carriers/` | Re-carryings of this repo's objects into non-Julia languages — SQL, Lisp, Elixir, Rust, Lean — with a ledger of what each gains and loses |
| `blackhole/` | The repo's own vocabulary applied to stellar collapse / the information paradox, plus the review that repaired it |
| `shocks/` | Material injected from outside the thread; `PARADOX-REPORT.md` carries a provenance amendment marking it testimony, not evidence |

There is no `.github/` directory, no CI, no package manifest.

## Toolchain

- **Julia 1.12**, **base library only**. No `Project.toml`, no `Manifest.toml`,
  no packages. A file that needs a dependency does not belong in `emergence/`,
  `paradoxes/`, or `julia-vs-lean/`.
- **Lean ≥ 4.22**, core only — no Mathlib. The `.lean` files are standalone and
  run with `lean <file>`; they print their own axiom ledger.
- Only `carriers/` needs anything else: SQLite ≥ 3.39 (for `IS NOT DISTINCT
  FROM`), SBCL, Elixir, Rust. Nothing outside that directory depends on them.

## Running

`README.md` keeps the authoritative list. The common ones:

```sh
julia emergence/emergence_00.jl …  emergence_10.jl   # each exits 0 iff its predictions hold
julia paradoxes/run_all.jl                            # the five courts
julia julia-vs-lean/run_all.jl                        # nine-carrier agreement
lean  emergence/lean/RingRest.lean                    # kernel; prints the axiom ledger
bash  carriers/run_carriers.sh                        # SQL + Lisp carriers
julia audits/emergence_checks_by_stranger.jl          # an audit of the thread
```

Each of these computes a verdict and ends in `exit(exitcode)`; a non-zero exit
is a failed claim, not a crashed script. The two exceptions are `_00` and `_01`,
which predate the discipline and are left without a failure channel on purpose.

## Conventions

1. **The exit code is the claim.** Each runnable file computes a verdict and
   exits on it. Printing a result is not asserting it — route anything you want
   to be load-bearing through the failure channel.
2. **Every `.jl` opens with a `LEDGER` comment block** carrying forward what is
   owed, what was closed, and what the file itself cannot prove from inside.
3. **Predictions are pre-registered.** They are numbered consecutively across
   the thread (`P1` … `P25`), written and argued before the sweep that tests
   them. A result found but not predicted is reported as unpredicted.
4. **Falsification controls are mandatory.** Claims ship with mutants that must
   fail — a check that cannot fail is treated here as a bug in the instrument.
5. **Errata stay visible.** When a later file overturns an earlier claim, the
   correction is recorded as an erratum; earlier files are not silently patched.
   `_00`/`_01` are deliberately left without failure channels as the fossil
   record of the discipline's absence.
6. **Audits are signed and separate.** Reviews live in their own file, named for
   the reviewing role (`*_by_stranger.jl`, `*_by_author.jl`, `*_by_fourth.jl`,
   `*_by_carrier_instance.jl`, `*_by_translator.sh`), and are not folded into
   the file they review. Where the reviewed party performed the repair, the
   conflict of interest is declared in the notes.
7. **Lean files publish their axiom ledger** at the end of a build: no `sorry`,
   no `axiom` declarations, and the choice-free status of each theorem recorded.
8. **`README.md` is the index.** A new runnable file gets a line under
   *Running* with its exit condition; a file that advances the thread gets a
   numbered entry under *The thread so far*.

## If you are changing things here

- Run what you touch. The exit codes are the test suite.
- Add to the record rather than rewriting it: other participants authored most
  of `audits/`, `carriers/`, and `shocks/`, and provenance is part of the
  content.
- Keep the no-dependency constraint; it is what makes the files reproducible
  across the participants' different environments.
