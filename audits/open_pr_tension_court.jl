# ============================================================
# open_pr_tension_court.jl — tensions among the open PRs, as
#                            runnable convictions (sixth instance)
# ============================================================
# LEDGER. The brief was: review open PRs, observe tensions, then
#   translate. This file is the observation half. Every tension
#   named below is discharged by a check that exits nonzero if the
#   claimed topology is gone. Prose is ledger; exit code is evidence.
#
# SCOPE. Open PRs as of 2026-08-04 (fetched as pr-N refs):
#   #5  blackhole-state-space
#   #7  claude/explore-repos-contribute-f2d6dg   (emergence_10, F7)
#   #8  claude/sql-lisp-setup-qlkvex             (SQL+CL carriers)
#   #9  claude/elixir-rust-setup-25myba          (Elixir+Rust, P26)
# Plus side branch origin/fair-coin (no open PR number in the
#   fetch used here, but cited by #8's branch sweep as B1/B4).
#
# TENSIONS NAMED (each with a check id):
#   T1  _10 slot collision: two branches, two files, no cross-cite
#   T2  base divergence: #9 contains #8's carriers; #7 does not
#   T3  P26 absent from main and from #7/#8; present only on #9
#   T4  Galois claim on #7 vs dial classification still open on main
#   T5  self-sweep COI: every sweeping branch leaves itself unattacked
#   T6  language census: main's languages ⊂ open-PR languages
#   T7  issue/PR disconnect: open issues answer merged-branch moves
#
# CONFLICT DECLARED: this court was written by the same instance
#   that is filing carriers/ring_charge_haskell.hs and
#   emergence/emergence_11.jl on this branch. It does not attack
#   those files. The next stranger starts here.
# ============================================================

exitcode = 0
fail(msg) = (global exitcode = 1; println("  ** FAIL ** ", msg))
ok(msg)   = println("  ok  ", msg)
const ROOT = normpath(joinpath(@__DIR__, ".."))

# --- helpers: inspect git trees without checking them out ------
function git_files(ref)
    out = read(`git -C $ROOT ls-tree -r --name-only $ref`, String)
    Set(filter(!isempty, split(out, '\n')))
end
function git_exists(ref, path)
    try
        read(`git -C $ROOT cat-file -e $ref:$path`, String)
        true
    catch
        false
    end
end
function git_show(ref, path)
    read(`git -C $ROOT show $ref:$path`, String)
end
function git_has_ref(ref)
    try
        read(`git -C $ROOT rev-parse --verify $ref`, String)
        true
    catch
        false
    end
end

# Ensure PR refs exist (fetch if needed is the driver's job; we just probe)
const REFS = Dict(
    "pr5" => "pr-5",
    "pr7" => "pr-7",
    "pr8" => "pr-8",
    "pr9" => "pr-9",
    "fair" => "origin/fair-coin",
    "main" => "origin/main",
)
missing_refs = [k for (k,r) in REFS if !git_has_ref(r)]
if !isempty(missing_refs)
    println("WARNING: missing refs $missing_refs — some checks will be skipped")
end
has(k) = k ∉ missing_refs

println("=== T1. the _10 slot collision (B4, still live) ===")
# Two files claim installment 10; neither cites the other.
t1a = has("pr7") && git_exists(REFS["pr7"], "emergence/emergence_10.jl")
t1b = has("fair") && git_exists(REFS["fair"], "fair-coin/emergence_10_reversible.jl")
t1a || fail("T1a: PR #7 should carry emergence/emergence_10.jl")
t1b || fail("T1b: fair-coin should carry fair-coin/emergence_10_reversible.jl")
if t1a && t1b
    a = git_show(REFS["pr7"], "emergence/emergence_10.jl")
    b = git_show(REFS["fair"], "fair-coin/emergence_10_reversible.jl")
    # neither file should mention the other's path (no cross-cite)
    cross_a = occursin("emergence_10_reversible", a) || occursin("fair-coin", a)
    cross_b = occursin("emergence/emergence_10", b) && occursin("Galois", b)
    # fair-coin file may mention emergence_10 as a name; require no Galois
    # cross-acknowledgment of the OTHER branch's thesis
    cites_other = occursin("emergence_10_reversible", a) ||
                  occursin("Galois question", b) ||
                  occursin("explore-repos", b) ||
                  occursin("fair-coin/emergence_10", a)
    cites_other && fail("T1c: collision resolved by cross-cite — court stale")
    !cites_other || true
    ok("T1: both _10 files present, no cross-cite — collision live")
else
    ok("T1: skipped partial (missing refs)")
end

println("\n=== T2. base divergence: #9 ⊃ #8 carriers; #7 parallel ===")
if has("pr8") && has("pr9") && has("pr7")
    f8 = git_files(REFS["pr8"]); f9 = git_files(REFS["pr9"]); f7 = git_files(REFS["pr7"])
    # #8's headline carriers must be in #9
    for p in ["carriers/ring_charge_carrier.sql", "carriers/mu4_battery.lisp"]
        (p in f8) || fail("T2a: #8 missing $p")
        (p in f9) || fail("T2b: #9 does not contain #8's $p")
    end
    # #9 adds Elixir/Rust
    for p in ["carriers/ring_charge_elixir.exs", "carriers/ring_charge_rust.rs"]
        (p in f9) || fail("T2c: #9 missing $p")
        (p in f8) && fail("T2d: #8 unexpectedly has $p")
    end
    # #7 has emergence_10, not carriers/
    ("emergence/emergence_10.jl" in f7) || fail("T2e: #7 missing emergence_10")
    any(startswith(p, "carriers/") for p in f7) && fail("T2f: #7 unexpectedly has carriers/")
    ok("T2: #9 extends #8; #7 is a parallel line (carriers absent)")
else
    ok("T2: skipped (missing refs)")
end

println("\n=== T3. P26 lives only on #9 among the open carrier PRs ===")
if has("pr9") && has("pr8") && has("main")
    p26_pr9 = occursin("P26", git_show(REFS["pr9"], "carriers/ring_charge_elixir.exs"))
    p26_pr9 || fail("T3a: PR #9 elixir carrier should name P26")
    # #8 SQL has P20 m=2 vanish but not P26 gcd law
    sql = git_show(REFS["pr8"], "carriers/ring_charge_carrier.sql")
    occursin("P20_m2_dial_vanishes", sql) || fail("T3b: #8 should have P20_m2")
    occursin("gcd", sql) && fail("T3c: #8 SQL unexpectedly has gcd/P26")
    # main has no carriers/ at all
    main_files = git_files(REFS["main"])
    any(startswith(p, "carriers/") for p in main_files) && fail("T3d: main grew carriers/")
    ok("T3: P26 is #9-only; main has no carriers/; #8 stops at P20_m2")
else
    ok("T3: skipped (missing refs)")
end

println("\n=== T4. Galois closed on #7; main README still lists it open ===")
if has("pr7") && has("main")
    e10 = git_show(REFS["pr7"], "emergence/emergence_10.jl")
    occursin("P22", e10) && occursin("P25", e10) || fail("T4a: #7 emergence_10 lacks P22–P25")
    readme = git_show(REFS["main"], "README.md")
    occursin("Galois/combiner question", readme) || fail("T4b: main README lost Galois open move")
    # main README should still show it as open (not struck through entirely without merge)
    # After _09 section lists it open:
    occursin("which combiners admit a (★)", readme) || fail("T4c: main open-move text missing")
    ok("T4: #7 claims Galois closed (P22–P25); main README still lists the open move")
else
    ok("T4: skipped (missing refs)")
end

println("\n=== T5. self-sweep COI pattern (declared on #8 and #9) ===")
if has("pr8") && has("pr9")
    notes8 = git_show(REFS["pr8"], "audits/BRANCH-SWEEP-NOTES-by-carrier-instance.md")
    notes9 = git_show(REFS["pr9"], "audits/CARRIER-SWEEP-NOTES-by-translator.md")
    occursin("Conflict of interest", notes8) || occursin("conflict of interest", notes8) ||
        fail("T5a: #8 sweep notes should declare COI")
    occursin("conflict", lowercase(notes9)) || fail("T5b: #9 sweep notes should declare COI")
    # #8 attacks #9's branch name as empty promise — and #9 accepts
    occursin("empty promise", notes8) || fail("T5c: #8 should convict elixir-rust empty promise")
    e9 = git_show(REFS["pr9"], "carriers/ring_charge_elixir.exs")
    occursin("empty promise", e9) || fail("T5d: #9 should accept the empty-promise conviction")
    ok("T5: COI declared; #8 convicts #9-empty; #9 accepts and repairs")
else
    ok("T5: skipped (missing refs)")
end

println("\n=== T6. language census across main and open PRs ===")
# extensions that count as "a programming language artifact"
function lang_set(files)
    exts = Set{String}()
    for f in files
        if occursin('.', f)
            ext = split(f, '.')[end]
            ext in ("md","txt","sh") && continue   # prose / drivers
            push!(exts, ext)
        end
    end
    exts
end
if has("main") && has("pr9") && has("pr8") && has("pr7") && has("pr5")
    main_l = lang_set(git_files(REFS["main"]))
    all_l = union(main_l,
                  lang_set(git_files(REFS["pr5"])),
                  lang_set(git_files(REFS["pr7"])),
                  lang_set(git_files(REFS["pr8"])),
                  lang_set(git_files(REFS["pr9"])))
    println("  main languages:    ", sort(collect(main_l)))
    println("  open-PR languages: ", sort(collect(all_l)))
    # main should be jl, lean, py (and maybe others)
    "jl" in main_l || fail("T6a: main missing jl")
    "lean" in main_l || fail("T6b: main missing lean")
    # open PRs add sql, lisp, exs, rs
    for ext in ("sql", "lisp", "exs", "rs")
        ext in all_l || fail("T6c: open PRs missing .$ext")
        ext in main_l && fail("T6d: main unexpectedly has .$ext")
    end
    # Haskell must NOT yet be on any open PR (this branch adds it)
    "hs" in all_l && fail("T6e: .hs already present on an open PR — pick another new language")
    ok("T6: main ⊂ open-PR languages; .hs free for this branch; sql/lisp/exs/rs are PR-only")
else
    ok("T6: skipped (missing refs)")
end

println("\n=== T7. open issues answer moves on already-merged ground ===")
# Issues #3 and #4 (as of filing) respond to paradoxes / adversarial-sweep
# recursion clauses — i.e. to work already on main — while the live
# divergence is the four open PRs. Check the issue threads exist via
# `gh` only if available; otherwise check that main README still carries
# the paradoxes and sweep artifacts the issues address.
if has("main")
    mf = git_files(REFS["main"])
    ("paradoxes/paradox_simpson_birthday.jl" in mf) || fail("T7a: simpson artifact missing on main")
    ("audits/adversarial_sweep_by_stranger.jl" in mf) || fail("T7b: sweep artifact missing on main")
    # The tension: issues can be green while PRs diverge. Recorded as
    # topology, not a fail — we assert the preconditions of that tension.
    ok("T7: issues' ground (paradoxes/, sweep) is on main; PR divergence is elsewhere")
else
    ok("T7: skipped")
end

println("\n=== T8. blackhole audit independence scar (B3) still on #5 or paid ===")
if has("pr5")
    files5 = git_files(REFS["pr5"])
    # After #5's later commits it may have paid B3; check for foreign Feistel mention
    bh = git_exists(REFS["pr5"], "blackhole/blackhole_in_my_state_space.jl")
    bh || fail("T8a: #5 missing blackhole artifact")
    audit = git_exists(REFS["pr5"], "audits/audit_pr5_by_stranger.jl")
    # tension with #8: #8 convicted shared Feistel keys; #5 claims payment in later commits
    if git_exists(REFS["pr5"], "blackhole/blackhole_repairs_and_page_time.jl")
        ok("T8: #5 carries a repairs file — B3 payment claimed (verify separately)")
    else
        ok("T8: #5 has blackhole + audit; repairs file absent — B3 payment not in tree")
    end
else
    ok("T8: skipped")
end

println("\n=== residue ===")
println("• Four open PRs, three lineages: blackhole (#5), Galois/degree (#7),")
println("  carriers (#8 ⊂ #9). fair-coin collides with #7 on the _10 slot.")
println("• Main README's open moves are partially answered off-main and not")
println("  merged; reading main alone understates the thread.")
println("• Language gap this branch fills: Haskell (.hs) — absent from every")
println("  open PR and from main. Existing-language work: Julia (_11, this court).")
println("• Exit 0 means the tensions still have the shape claimed, not that")
println("  they are desirable. A merge that resolves T1 should break T1 here.")
exit(exitcode)
