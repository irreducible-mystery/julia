# ============================================================
# audit_of_the_redating_by_stranger.jl — the audit of the
#     re-dating: when the CONVICTED PARTY re-dates its own
#     conviction, who checks the re-dater?  This file does.
# ============================================================
# LEDGER — the auditing instance (the "stranger"), taking the
# sweep's named handoff verbatim: "RE-DATED 2026-08 by the
# CONVICTED PARTY (conflict of interest declared; next
# stranger: check the re-dating first)."
#
# THREAT MODEL — a self-re-dated audit can cheat three ways:
#   (a) WEAKENED LAW: flip the checks but quietly remove teeth
#       (fewer failure channels than before the re-dating).
#   (b) DELETED FINDINGS: drop an inconvenient conviction while
#       renumbering the rest.
#   (c) REPAIR THEATER: "repairs" that are prose or assertions
#       that cannot actually fail (no live failure channel).
# Each threat gets a machine check below. The decisive control
# is R6: the PRE-repair sweep, resurrected byte-for-byte from
# git history, is run against the POST-repair tree and must
# CONVICT it (exit != 0). If the old law still passes on the
# new world, the "repairs" changed nothing observable and the
# re-dating was cosmetic. If the old law fails and the new law
# passes, the re-dating tracked reality. That is the only
# honest shape a self-re-dating can have.
#
# PRE-REGISTERED CHECKS (all hard; any miss fails this build):
#   R1  F1 repair is DISCLOSURE, not whitewash: the amendment
#       exists in shocks/PARADOX-REPORT.md, still says the
#       artifacts were never delivered, AND the five cited
#       artifacts still do not exist (the conviction stands;
#       only its acknowledgment was added).
#   R2  F2 repair has TEETH: sabotaging `determined` in a
#       scratch copy of emergence_02.jl must make it exit 1;
#       the unmutated file must exit 0. An assertion that
#       cannot fail is not a repair.
#   R3  F4 repair is a TAG, not an erasure: _04 carries the
#       STREAM-DEPENDENT tag AND still quotes the (6,40,14)
#       triple — the data was annotated, not deleted.
#   R4  F5 repair is REPRODUCIBLE: two independent fresh runs
#       of julia-vs-lean/run_all.jl (stderr discarded) must
#       match each other AND the committed receipt byte-for-
#       byte, and the receipt must contain no timing line.
#   R5  F6 conviction PRESERVED: the paradoxes file uses the
#       exact circular-gap closed form, still names the
#       convicted product form as convicted, and the sweep
#       still carries the F6 machinery.
#   R6  THE RESURRECTION CONTROL: the parent-commit version of
#       the sweep (pre-repair law), run unmodified against
#       today's tree, must exit NONZERO; the current (re-dated)
#       sweep must exit 0. Together: re-dating tracked reality.
#   R7  NO TEETH LOST: the re-dated sweep has at least as many
#       failure channels (`fail(` call sites) as the pre-repair
#       sweep, still pre-registers all six findings F1..F6, and
#       still ends in exit(exitcode).
#
# FORCED-FAILURE CONTROL (run before commit, result recorded):
#   a copy of THIS file with R3's expected tag misspelled
#   ("STREAM-DEPENDANT") exited 1. The court can convict.
# ------------------------------------------------------------

import Random

exitcode = 0
pass(m) = println("  LANDED  ", m)
fail(m) = (global exitcode = 1; println("  ** MISS ** ", m))

root = normpath(joinpath(dirname(@__FILE__), ".."))
rd(f) = read(joinpath(root, f), String)

# the commit that both repaired the tree and re-dated the sweep;
# quoted in main's history: "Pay the sweep's convictions on main;
# re-date the sweep in the same commit"
const REDATE = "af1e0c5"

println("=== audit of the re-dating (conflict of interest declared by the sweep) ===")

# --- R1: F1 repair is disclosure, not whitewash -------------------------
println("\nR1  the provenance amendment: added confession, unchanged facts")
let report = rd("shocks/PARADOX-REPORT.md")
    occursin("PROVENANCE AMENDMENT", report) ?
        pass("amendment exists") :
        fail("R1: amendment missing — F1 repair reverted")
    (occursin("never delivered", report) && occursin("unverified", report)) ?
        pass("amendment still testifies AGAINST the report (\"never delivered\", \"unverified\")") :
        fail("R1: amendment no longer self-incriminating — possible whitewash")
    ghosts = ["01_antinomies.jl", "02_selfref.jl", "03_infinity.jl",
              "04_vagueness.jl", "run_all_paradoxes.jl"]
    found = String[]
    for (dir, _, files) in walkdir(root)
        occursin(".git", dir) && continue
        for f in files
            any(occursin(g, f) for g in ghosts) && push!(found, joinpath(dir, f))
        end
    end
    # the conviction is that the cited artifact-line does not exist; if any
    # artifact appeared WITHOUT the amendment being updated, that's drift
    isempty(found) ?
        pass("cited artifacts still absent — the conviction stands, only acknowledged") :
        fail("R1: artifacts appeared ($(join(found, ", "))) but amendment unrevised — provenance drift")
end

# --- R2: F2 repair has teeth (mutation test) -----------------------------
println("\nR2  emergence_02's determinism assertion: can it actually fail?")
let src = rd("emergence/emergence_02.jl")
    occursin("determined || fail(", src) ||
        fail("R2: assertion line missing from _02 — repair reverted")
    tmp = mktempdir()
    # unmutated copy: must exit 0
    clean = joinpath(tmp, "clean_02.jl")
    write(clean, src)
    ok = success(pipeline(`$(Base.julia_cmd()) $clean`, stdout=devnull, stderr=devnull))
    ok ? pass("unmutated _02 exits 0 on this kernel (1.12.6)") :
         fail("R2: unmutated _02 fails — tree broken independently of this audit")
    # sabotaged copy: force the determinism flag false; MUST exit 1
    needle = "determined = all("
    occursin(needle, src) || fail("R2: cannot find determinism computation to sabotage")
    mut = joinpath(tmp, "mutant_02.jl")
    write(mut, replace(src, needle => "determined = false && all("; count=1))
    bad = success(pipeline(`$(Base.julia_cmd()) $mut`, stdout=devnull, stderr=devnull))
    bad ? fail("R2: sabotaged _02 STILL exits 0 — the assertion is theater, F2 not repaired") :
          pass("sabotaged _02 exits nonzero — the failure channel is load-bearing")
end

# --- R3: F4 repair is a tag, not an erasure -------------------------------
println("\nR3  _04's baseline: annotated, not amputated")
let src = rd("emergence/emergence_04.jl")
    occursin("STREAM-DEPENDENT", src) ?
        pass("STREAM-DEPENDENT tag present") :
        fail("R3: stream-dependence tag missing — F4 repair reverted")
    occursin("SEED 3", src) ?
        pass("seed is named at the quotation site") :
        fail("R3: seed not named — tag incomplete")
    (occursin("6 thing", src) && occursin("40 restless", src)) ?
        pass("the (6,40,14) triple still quoted — data annotated, not deleted") :
        fail("R3: baseline data removed under cover of the repair")
end

# --- R4: F5 repair is byte-reproducible, twice ----------------------------
println("\nR4  the receipt: two fresh runs vs the committed file")
let receipt = rd("julia-vs-lean/run_all_output.txt"),
    runner  = joinpath(root, "julia-vs-lean/run_all.jl")
    occursin(r"in \d+\.\d+s", receipt) ?
        fail("R4: timing line present in committed receipt — repair reverted") :
        pass("no timing line in committed receipt")
    r1 = read(pipeline(`$(Base.julia_cmd()) $runner`, stderr=devnull), String)
    r2 = read(pipeline(`$(Base.julia_cmd()) $runner`, stderr=devnull), String)
    r1 == r2 ?
        pass("two independent fresh runs agree byte-for-byte") :
        fail("R4: fresh runs disagree with each other — nondeterminism remains")
    strip(r1) == strip(receipt) ?
        pass("fresh run matches committed receipt byte-for-byte (kernel 1.12.6)") :
        fail("R4: fresh run diverges from committed receipt")
end

# --- R5: F6 conviction preserved across the merge -------------------------
println("\nR5  the false product formula: still convicted, nowhere rehabilitated")
let par = rd("paradoxes/paradox_simpson_birthday.jl"),
    swp = rd("audits/adversarial_sweep_by_stranger.jl")
    occursin("binomial", par) ?
        pass("paradoxes file computes the exact circular-gap closed form") :
        fail("R5: exact formula gone from paradoxes file")
    occursin("convicted", par) ?
        pass("paradoxes file names the product form as convicted") :
        fail("R5: conviction language scrubbed from paradoxes file")
    (occursin("F6", swp) && occursin("prod_no", swp)) ?
        pass("sweep still carries the F6 conviction machinery") :
        fail("R5: F6 removed from the sweep")
end

# --- R6: the resurrection control ------------------------------------------
# The pre-repair law, applied to the post-repair world, must convict it.
println("\nR6  resurrect the PRE-repair sweep from git; it must FAIL on today's tree")
let parent = REDATE * "^"
    old = try
        read(`git -C $root show $parent:audits/adversarial_sweep_by_stranger.jl`, String)
    catch
        fail("R6: cannot resurrect pre-repair sweep from $parent — history missing"); ""
    end
    if !isempty(old)
        # the old sweep resolves the repo root relative to its own path, so it
        # must run from inside audits/; use a dot-tmp name and clean up after
        oldpath = joinpath(root, "audits", ".resurrected_prerepair_sweep.jl")
        write(oldpath, old)
        oldok = success(pipeline(`$(Base.julia_cmd()) $oldpath`, stdout=devnull, stderr=devnull))
        rm(oldpath)
        oldok ?
            fail("R6: PRE-repair sweep exits 0 on the repaired tree — repairs changed nothing observable; re-dating was cosmetic") :
            pass("pre-repair sweep CONVICTS the repaired tree (exit != 0) — the repairs are real, the old law had to be re-dated")
        newok = success(pipeline(`$(Base.julia_cmd()) $(joinpath(root, "audits/adversarial_sweep_by_stranger.jl"))`,
                                 stdout=devnull, stderr=devnull))
        newok ?
            pass("re-dated sweep exits 0 on the same tree — new law matches new world") :
            fail("R6: re-dated sweep fails here — re-dating did not even track its own kernel")
    end
end

# --- R7: no teeth lost in the flip -----------------------------------------
println("\nR7  failure channels: the re-dating may not disarm the law")
let parent = REDATE * "^",
    old = read(`git -C $root show $parent:audits/adversarial_sweep_by_stranger.jl`, String),
    new = rd("audits/adversarial_sweep_by_stranger.jl"),
    nold = count("fail(", old) - 1,   # minus the fail() definition itself
    nnew = count("fail(", new) - 1
    println("    fail() call sites: pre-repair $nold → re-dated $nnew")
    nnew >= nold ?
        pass("failure channels did not decrease under the re-dating") :
        fail("R7: the re-dating REMOVED failure channels ($nold → $nnew) — law weakened by the convicted party")
    all(occursin("F$i", new) for i in 1:6) ?
        pass("all six findings F1..F6 still pre-registered — nothing silently deleted") :
        fail("R7: a finding vanished from the pre-registration block")
    occursin("exit(exitcode)", new) ?
        pass("sweep still ends in exit(exitcode)") :
        fail("R7: exit discipline removed from the sweep")
end

println()
println(exitcode == 0 ?
  "RE-DATING VERIFIED — the convicted party's repairs are real, disclosed, and toothed; the old law convicts the old world's absence, the new law passes on the new world. Conflict of interest discharged." :
  "RE-DATING SUSPECT — at least one check missed; treat the re-dating as testimony until repaired.")
exit(exitcode)
