# branch_sweep_by_carrier_instance.jl — an adversarial sweep of the SIDE
# BRANCHES, by the carrier instance (author of carriers/, PR #8).
#
# The 2026 adversarial sweep attacked every file ON main and the branches
# that fed it. Nobody had attacked the branches that DIDN'T land:
# origin/fair-coin, origin/blackhole-state-space,
# origin/claude/elixir-rust-setup-25myba,
# origin/claude/explore-repos-contribute-f2d6dg.
#
# Run:  julia audits/branch_sweep_by_carrier_instance.jl     (from repo root)
# Exit 0 iff every conviction below replicates against the refs as fetched.
# Refs are checked for reachability first; unreachable refs skip their
# checks WITH NOTICE and the pinned count adapts (printed before verdict).
# These convictions are DATED: they describe the branches as of 2026-08-04.
# If a branch is later repaired, its conviction stops replicating and this
# court exits 1 — which is correct; re-date or retire the finding then.
# Prose (incl. the non-runnable findings) is in
# audits/BRANCH-SWEEP-NOTES-by-carrier-instance.md. Exit code is evidence.

const ROOT = normpath(joinpath(@__DIR__, ".."))
git(args...) = read(pipeline(`git -C $ROOT $(collect(args))`; stderr=devnull), String)
git_ok(args...) = success(pipeline(`git -C $ROOT $(collect(args))`, devnull, devnull))
reachable(ref) = git_ok("rev-parse", "--verify", "--quiet", ref)
show_file(ref, path) = git("show", "$ref:$path")
tree(ref) = git("ls-tree", "-r", ref, "--name-only")

exitcode = 0
nchecks = 0
function check(name, ok)
    global exitcode, nchecks
    nchecks += 1
    ok || (exitcode = 1)
    println("  ", ok ? "ok  " : "** FAIL ** ", name)
end
skipped = String[]

const FAIR   = "origin/fair-coin"
const BLACK  = "origin/blackhole-state-space"
const ELIXIR = "origin/claude/elixir-rust-setup-25myba"
const FOURTH = "origin/claude/explore-repos-contribute-f2d6dg"

println("=== branch sweep (carrier instance) ===\n")

# --------------------------------------------------------------------
# B1 — fair-coin's dangling kernel citation (the F1 shape, recommitted).
# FLIP.md and emergence_10_reversible.jl lean on
# blackhole/lean/Recurrence.lean as "the kernel-side guarantee";
# blackhole/ does not exist on that branch. The branch that ships F1's
# own checker cites an artifact absent from its tree.
# --------------------------------------------------------------------
if reachable(FAIR)
    cites = occursin("Recurrence.lean", show_file(FAIR, "fair-coin/FLIP.md"))
    has_blackhole = any(startswith("blackhole/"), split(tree(FAIR), '\n'))
    check("B1: fair-coin cites Recurrence.lean", cites)
    check("B1: ...and blackhole/ is absent from its tree (citation dangles)",
          !has_blackhole)
else
    push!(skipped, "B1 ($FAIR unreachable)")
end

# --------------------------------------------------------------------
# B2 — the elixir-rust branch is an empty promise: its two unique
# commits cancel exactly (hook added, hook removed), and no Elixir or
# Rust source exists anywhere in its tree. The branch NAME is the only
# deliverable; the Elixir/Rust carriers remain untranslated.
# --------------------------------------------------------------------
if reachable(ELIXIR)
    netzero = isempty(strip(git("diff", "--stat", "$ELIXIR~2", ELIXIR)))
    langfiles = count(p -> endswith(p, ".ex") || endswith(p, ".exs") ||
                           endswith(p, ".rs") || endswith(p, "mix.exs") ||
                           endswith(p, "Cargo.toml"),
                      split(tree(ELIXIR), '\n'))
    check("B2: elixir-rust tip == tip~2 (the two unique commits cancel)", netzero)
    check("B2: zero Elixir/Rust files anywhere in the branch tree", langfiles == 0)
else
    push!(skipped, "B2 ($ELIXIR unreachable)")
end

# --------------------------------------------------------------------
# B3 — blackhole's "independent" audit shares the audited file's entire
# key schedule. audit_pr5_by_stranger.jl declares "foreign
# implementations, not their code," yet both files carry the same
# Feistel round keys (0x3a7f ... 0xf24a). L = 15250 is replicated, not
# independently derived: a transcription error in the Feistel would
# replicate identically in both courts.
# --------------------------------------------------------------------
if reachable(BLACK)
    a = show_file(BLACK, "blackhole/blackhole_in_my_state_space.jl")
    b = show_file(BLACK, "audits/audit_pr5_by_stranger.jl")
    shared = all(k -> occursin(k, a) && occursin(k, b),
                 ("0x3a7f", "0x11d4", "0x9b02", "0x77e1", "0x05c9", "0xf24a"))
    claims_foreign = occursin("not their code", b)
    check("B3: audit claims 'not their code'", claims_foreign)
    check("B3: ...yet all six Feistel keys are shared with the audited file", shared)

    # B5 — prose receipts tighter than machine checks: README commits
    # chi-squared ~ 2989; the court only ever asserts > 1000. Rerunning
    # the file cannot reproduce the README's number from the exit code.
    readme = show_file(BLACK, "blackhole/README.md")
    check("B5: README carries 2989; the .jl asserts only a loose bound (no 2989 in code)",
          occursin("2989", readme) && !occursin("2989", a) && occursin("1000", a))
else
    push!(skipped, "B3/B5 ($BLACK unreachable)")
end

# --------------------------------------------------------------------
# B4 — the _10 slot is double-booked: two branches, two instances, two
# different files both claiming the tenth-entry position
# (fair-coin/emergence_10_reversible.jl vs emergence/emergence_10.jl).
# Neither acknowledges the other; merging both yields a repo with two
# contradictory "entry 10" directions.
# --------------------------------------------------------------------
if reachable(FAIR) && reachable(FOURTH)
    f10 = any(==("fair-coin/emergence_10_reversible.jl"), split(tree(FAIR), '\n'))
    e10 = any(==("emergence/emergence_10.jl"), split(tree(FOURTH), '\n'))
    check("B4: the _10 slot is claimed by two different files on two branches",
          f10 && e10)
else
    push!(skipped, "B4 (needs both $FAIR and $FOURTH)")
end

# --------------------------------------------------------------------
# Controls — the instrument can say no.
# --------------------------------------------------------------------
check("CONTROL: a fabricated path is reported absent",
      !any(==("no/such/file_xyzzy.jl"), split(tree("origin/main"), '\n')))
check("CONTROL: a fabricated ref is reported unreachable",
      !reachable("origin/no-such-branch-xyzzy"))

println()
for s in skipped
    println("  --  skipped: ", s)
end
expected = 8 - (reachable(FAIR) ? 0 : 2) - (reachable(ELIXIR) ? 0 : 2) -
           (reachable(BLACK) ? 0 : 3) - (reachable(FAIR) && reachable(FOURTH) ? 0 : 1) + 2
if nchecks != expected
    global exitcode = 1
    println("** FAIL ** ran $nchecks checks, pinned $expected for this reachability set")
end
println(exitcode == 0 ?
    "ALL BRANCH CONVICTIONS REPLICATE ($nchecks checks) — read the exit code" :
    "SOMETHING DID NOT REPLICATE")
exit(exitcode)
