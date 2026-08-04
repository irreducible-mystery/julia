# ============================================================
# toolchain_audit_by_fourth.jl — the stranger duty taken: the
#     re-dating checked, the battery re-run, and the kernel's
#     court convicted of having a version (a fourth instance)
# ============================================================
# LEDGER — the README's own instruction was "the next stranger
# should check the re-dating first." I am that stranger. Method:
# fresh kernel (Julia 1.12.6, binary provenance declared below),
# run EVERYTHING, diff the re-dated sweep against its original
# blob where git history permits, then attack the one court
# nobody had re-seated: the Lean kernel, on the exact minimum
# version the README names.
#
# VERDICT ON THE RE-DATING (checked first, as instructed): the
#   flip from convict-the-bug to verify-the-repair is FAITHFUL.
#   All six findings F1–F6 retain live failure channels; F1
#   gained a strictly stronger check (amendment must exist); no
#   conviction was dropped or weakened. Evidence: the checks
#   below, plus the sweep's own exit 0 on this kernel.
#
# NEW FINDINGS (pre-registered; each hard; convict-or-verify):
#   F7  THE KERNEL'S COURT HAS A VERSION: as committed by _09,
#       emergence/lean/RingRest.lean FAILED on Lean 4.22.0 —
#       the README's own stated minimum ("any Lean ≥ 4.22").
#       Three `rw`s inside congruence callbacks met unreduced
#       β-redexes (4.22 does not β-reduce those goals; 4.32
#       does), and error recovery silently degraded FIVE
#       declarations — neg_world_rest, charge_formula_raw,
#       charge_formula, charge_conserved_of_outdeg_one,
#       charge_dial — to `sorryAx` in the printed ledger, exit 1.
#       On Lean 4.32.2 the same blob compiled clean. Neither
#       prose nor proofs were wrong; the COMPATIBILITY CLAIM
#       was. A kernel verdict is a property of (file, toolchain)
#       — the repo's own recurring lesson (period/(world,
#       discipline); census/(rule, n, seed, stream); dial/(m))
#       now lands on the court itself. REPAIRED in this commit:
#       three β-reducing `show`s; re-verified exit 0 with
#       IDENTICAL axiom ledgers on BOTH 4.22.0 and 4.32.2.
#       CONFLICT OF INTEREST DECLARED: the finder performed the
#       repair, in the same commit as this audit — exactly the
#       structure the re-dating was convicted-and-forgiven for.
#       Next stranger: run RingRest.lean on a kernel I have
#       never touched.
#   F8  THE SIXTH MISSING ARTIFACT: the provenance amendment
#       (F1's repair) enumerates five cited-but-absent artifacts
#       — but shocks/PARADOX-REPORT.md line ~194 also cites
#       `output.txt` ("the full captured run"), equally absent,
#       covered by neither the amendment's enumeration nor the
#       sweep's cited-file list. The amendment repaired the
#       list it was given, not the list that exists. REPAIRED in
#       this commit: one line extends the amendment. Same
#       conflict declared.
#   F9  THE HALF-RE-DATED AUDIT: af1e0c5 re-dated the sweep's
#       .jl per its own staleness law — and left its companion
#       prose, audits/ADVERSARIAL-SWEEP-NOTES.md, untouched: no
#       RE-DATED marker; still demanding "either commit the five
#       files, or amend the report" though the amendment now
#       exists; still dated to kernel 1.11.7 and main@35479fe.
#       Prose is ledger, not evidence — but a ledger that
#       contradicts the tree teaches the wrong history. REPAIRED
#       in this commit: a dated addendum appended (original text
#       untouched, per errata law). Same conflict declared.
#
# TOOLCHAIN PROVENANCE (the instrument, declared): Julia 1.12.6
#   official binary obtained via the nixpkgs `julia-bin`
#   derivation from cache.nixos.org (the primary distribution
#   host was network-blocked in my environment); Lean 4.22.0 and
#   4.32.2 official release binaries from the leanprover GitHub
#   releases. Every verdict below inherits trust in those two
#   caches' integrity. Declared, not proved.
# CHOICE: the dynamic Lean checks below are GUARDED — they run
#   only if a `lean` binary is on PATH, and SKIP loudly
#   otherwise. An audit that cannot reach an instrument says so;
#   it does not fake the reading. The battery re-run is NOT
#   guarded: no Julia, no audit.
# UNPROVABLE FROM INSIDE: that my repairs hide no new bugs (the
#   fixer's fixes are exactly what the next stranger should
#   check); whether the two toolchains I chose bracket the
#   versions future readers will hold. Audits sample. Recurse.
#   Stop at the visible edge.
# ============================================================

exitcode = 0
fail(m) = (global exitcode = 1; println("  ** FAIL ** ", m))
pass(m) = println("  OK      ", m)
skip(m) = println("  SKIP    ", m, "  (instrument absent — verdict withheld, not granted)")

root = normpath(joinpath(dirname(@__FILE__), ".."))
rd(p) = read(joinpath(root, p), String)

println("kernel: Julia ", VERSION)

# --- the re-dating, checked first (as the README instructed) ---------
println("\nRE-DATING  the six convictions must still have live channels")
let sweep = rd("audits/adversarial_sweep_by_stranger.jl")
    occursin("RE-DATED 2026-08", sweep) ||
        fail("re-dating banner missing from the sweep")
    for f in ("F1", "F2", "F3", "F4", "F5", "F6")
        occursin(Regex("fail\\(\"$f"), sweep) ||
            fail("$f: no live failure channel in the re-dated sweep")
    end
    for must in ("provenance amendment missing — repair reverted",
                 "determinism repair missing or reverted",
                 "stream-dependence tag missing from _04 — repair reverted",
                 "timing line back in receipt — repair reverted")
        occursin(must, sweep) ||
            fail("re-dating dropped a verify-the-repair channel: $must")
    end
    pass("all six findings carry fail() channels; four repair-reversion tripwires present")
end
# where git history is reachable, diff the re-dated blob against the original
let orig = try
        read(setenv(`git show 4739ac6:audits/adversarial_sweep_by_stranger.jl`;
                    dir=root), String)
    catch; nothing end
    if orig === nothing
        skip("git blob 4739ac6 unreachable — original-vs-re-dated diff not performed")
    else
        # every original conviction section survives; the three flips are declared
        ok = all(occursin("# --- F$i", rd("audits/adversarial_sweep_by_stranger.jl"))
                 for i in 1:6)
        ok || fail("a finding section vanished between 4739ac6 and the re-dated sweep")
        occursin("first draft of THIS file accused the receipt", orig) &&
            occursin("first draft of THIS file accused the receipt",
                     rd("audits/adversarial_sweep_by_stranger.jl")) ||
            fail("the sweep's own preserved erratum was dropped by the re-dating")
        ok && pass("original blob read from history: all six sections and the sweep's own erratum survive")
    end
end

# --- the battery: af1e0c5 claimed all artifacts exit 0 on 1.12.6 ------
println("\nBATTERY  every runnable artifact on this branch, fresh subprocesses")
battery = ["emergence/emergence_00.jl", "emergence/emergence_01.jl",
           "emergence/emergence_02.jl", "emergence/emergence_03.jl",
           "emergence/emergence_04.jl", "emergence/emergence_05.jl",
           "emergence/emergence_06.jl", "emergence/emergence_07.jl",
           "emergence/emergence_08.jl", "emergence/emergence_09.jl",
           "emergence/emergence_10.jl",
           "audits/audit_08_by_stranger.jl",
           "audits/emergence_checks_by_stranger.jl",
           "audits/adversarial_sweep_by_stranger.jl",
           "julia-vs-lean/run_all.jl",
           "paradoxes/run_all.jl",
           "paradoxes/audit_paradoxes_by_author.jl"]
for art in battery
    p = run(pipeline(setenv(`$(Base.julia_cmd()) $(joinpath(root, art))`; dir=root),
                     stdout=devnull, stderr=devnull); wait=false)
    wait(p)
    p.exitcode == 0 ? pass(art) : fail("$art exited $(p.exitcode)")
end

# --- F7: the kernel's court, on the README's stated minimum -----------
println("\nF7  RingRest.lean vs the toolchain that reads it")
let lean_src = rd("emergence/lean/RingRest.lean")
    # the repair must be present: three β-reducing shows + the erratum block
    occursin("ERRATUM (fourth instance, toolchain audit)", lean_src) ||
        fail("F7: erratum block missing from RingRest.lean — repair reverted?")
    count_shows = length(collect(eachmatch(r"show \(\(0 : Nat\) : Int\) \* s j|show \(m - 0\) % m = 0|show \(1 - outdegI inputs n j\) \* s j", lean_src)))
    count_shows == 3 ||
        fail("F7: expected 3 β-reducing show sites, found $count_shows — repair incomplete")
    pass("repair present in source: erratum block + all 3 show sites")
    lean = Sys.which("lean")
    if lean === nothing
        skip("no `lean` on PATH — dynamic check: run `lean emergence/lean/RingRest.lean`; require exit 0 and a sorryAx-free ledger")
    else
        out = IOBuffer()
        p = run(pipeline(setenv(`$lean $(joinpath(root, "emergence/lean/RingRest.lean"))`; dir=root),
                         stdout=out, stderr=out); wait=false)
        wait(p)
        txt = String(take!(out))
        p.exitcode == 0 ? pass("lean ($(strip(read(`$lean --version`, String)))) exit 0") :
                          fail("F7: RingRest.lean exits $(p.exitcode) on the PATH lean")
        occursin("sorryAx", txt) &&
            fail("F7: sorryAx in the axiom ledger — a declaration silently degraded")
        occursin("sorryAx", txt) || pass("axiom ledger sorryAx-free on this toolchain")
    end
end

# --- F8: the sixth cited-but-absent artifact --------------------------
println("\nF8  shocks/PARADOX-REPORT.md cites more than the amendment covered")
let report = rd("shocks/PARADOX-REPORT.md")
    occursin("`output.txt`", report) ||
        fail("F8: the report no longer cites output.txt — finding stale, re-date")
    isfile(joinpath(root, "shocks", "output.txt")) &&
        fail("F8: shocks/output.txt exists now — finding stale, re-date")
    # the repair: the amendment must now name it
    occursin("output.txt", split(report, "PROVENANCE AMENDMENT")[2][1:2000]) ||
        fail("F8: amendment still does not cover output.txt — repair reverted")
    pass("output.txt cited, absent, and now covered by the amendment")
end

# --- F9: the half-re-dated audit --------------------------------------
println("\nF9  the sweep's companion notes vs the tree they describe")
let notes = rd("audits/ADVERSARIAL-SWEEP-NOTES.md")
    occursin("Either commit the five", notes) ||
        fail("F9: the notes' pre-repair demand is gone — finding stale, re-date")
    occursin("RE-DATING ADDENDUM", notes) ||
        fail("F9: addendum missing — the notes still teach a false present")
    pass("original notes intact; dated addendum marks them as the pre-repair snapshot")
end

println()
println(exitcode == 0 ?
  "RE-DATING VERIFIED; BATTERY GREEN; THREE NEW FINDINGS LANDED AND REPAIRED (F7-F9).\nThe fixer's fixes are now the attack surface. Written in expectation of the next stranger." :
  "AUDIT BUILD FAILED — a finding did not replicate or a repair reverted; re-date or re-convict.")
exit(exitcode)
