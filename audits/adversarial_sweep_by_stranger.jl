# ============================================================
# adversarial_sweep_by_stranger.jl — the audit of the audits:
#     every file in this repo, attacked; exit 0 iff the attacks
#     land. Findings are convictions, not complaints.
# ============================================================
# LEDGER — a third instance, invited to attack everything.
# Method: read every file on every branch, run every artifact
# on this kernel, then hunt for (a) claims with no failure
# channel, (b) constants quoted across files as facts that are
# actually seed-properties, (c) receipts contradicting prose,
# (d) citations to verifications that never happened, (e) courts
# whose tolerance cannot convict the very constants they defend.
# House law applies to the law itself: prose accusations are
# worthless, so every finding below is machine-checked and this
# file exits 0 iff ALL of them replicate. A finding that stops
# replicating (because someone fixed it) fails THIS file — that
# is correct behavior: audits are point-in-time; re-dating them
# is the fixer's job, not the auditor's.
#
# RE-DATED 2026-08 by the CONVICTED PARTY (conflict of interest
# declared; next stranger: check the re-dating first). Repairs
# landed on main in the same commit as this re-dating:
#   F1  shocks/PARADOX-REPORT.md carries a provenance amendment:
#       testimony, not evidence, until artifacts are delivered.
#       (Check flipped: amendment must EXIST.)
#   F2/F3  _02 grew fail() + exit(exitcode); §II determinism is
#       now ASSERTED, not printed. (Checks flipped accordingly.
#       _00/_01 stay channel-free: they predate the discipline
#       and are kept as the fossil record of it.)
#   F4  _04's baseline is tagged seed-3/stream-dependent.
#       (Check flipped: tag must exist.)
#   F5  timing moved to stderr; receipt regenerated, verified
#       byte-reproducible on kernel 1.12.6. (Checks flipped:
#       receipt must NOT contain a timing line, and reruns must
#       match byte-for-byte.)
#   F6  remains as merged from the paradoxes branch (repair
#       landed there pre-merge; conviction preserved here).
# ------------------------------------------------------------
# PRE-REGISTERED FINDINGS (each hard; any miss fails this build):
#   F1  CONSTITUTIONAL: shocks/PARADOX-REPORT.md cites at least
#       five runnable artifacts (01_antinomies.jl ... run_all.jl)
#       and NONE exist anywhere in the tree. The repo's first
#       sentence is "every claim is backed by a file that
#       executes." The shock is prose backed by prose. _08
#       metabolized S1–S4 from it honorably (it re-proved them),
#       but the CONVERGENCE claim ("two artifact-lines, no
#       contact, same criterion") cites an artifact-line whose
#       artifacts nobody can run. Checked by filesystem.
#   F2  NO FAILURE CHANNEL: emergence_00 and _01 contain no
#       fail() and no exit-code discipline — they cannot lose,
#       so under house law their exit 0 is not evidence. _02
#       computes its central §II claim into a variable named
#       `determined` and then only PRINTS it — the single most
#       load-bearing empirical claim of the early files
#       (outcome fixed by first effective mover) was never
#       asserted. Checked statically against the sources.
#   F3  THE PHANTOM CITATION: _03 line ~96 says determinism was
#       "verified in _02". It was observed in _02 (400 seeded
#       races, printed), never verified. We now DECIDE it by
#       exhaustion — all four latch states, both update orders,
#       full nondeterministic closure from the released state:
#       first effective mover 1 forces ▮·, mover 2 forces ·▮,
#       absorbing states are exactly {▮·, ·▮}. The citation was
#       false when written; the fact it cited is true and is
#       now, for the first time, machine-checked. Debt paid by
#       the prosecution.
#   F4  SEED-PROPERTIES QUOTED AS FACTS: the census triple
#       (6 thing, 40 restless, 14 rest-possible) is quoted in
#       _04 §V as "binary baseline (_02, n=12)". Replicating
#       _02's exact census on THIS kernel: seed 3 reproduces
#       (6,40,14) — but seeds 4 and 5 give different triples.
#       The baseline is a property of (rule, n, seed 3, Julia's
#       RNG stream), not of "binary". Julia does not contract
#       rand-stream stability across minor versions, and the
#       README pins 1.12 while this kernel is 1.11.7 — the
#       numbers survived by luck, not by law. Checked by rerun.
#   F5  THE UNVERIFIABLE RECEIPT: run_all_output.txt embeds a
#       wall-clock time ("swept ... in 0.13s"), so the committed
#       receipt can NEVER be re-verified byte-for-byte — any
#       fresh run diffs on that line by construction. Checked by
#       rerunning and diffing: the timing line is the sole
#       difference (every substantive line replicates), which
#       simultaneously (i) re-verifies the receipt's content on
#       a second kernel and (ii) convicts the practice of
#       committing noise into evidence. ERRATUM, paid before
#       commit: the first draft of THIS file accused the receipt
#       of contradicting the prose (0.00s vs 0.13s) — a misread
#       diff direction; my own exit code convicted me, the
#       accusation is retracted, and the misread is preserved
#       here because deleting it would repeat the error.
#   F6  CROSS-BRANCH, THE COURT THAT CANNOT CONVICT ITS OWN
#       CONSTANT: branch paradoxes-monte-carlo committed
#       P(no near-match) = ∏(365−3k)/365 as "the clean product
#       form". It is FALSE — the true closed form (circular
#       gaps ≥ 2) is  n!·N·C(N−n,n) / ((N−n)·N^n), which brute
#       exhaustion confirms at small N while the product fails
#       at N=10,n=3 already. At n=14 the two differ by 0.00284,
#       UNDER the 5σ noise floor (0.00394) of that court's own
#       n=400_000 — so the wrong constant passed. Raising the
#       court to n=4_000_000 (5σ = 0.00125): the true constant
#       is hit, the committed one is excluded. Three checks:
#       exhaustion convicts the formula, power arithmetic shows
#       the original court was blind, the enlarged court
#       convicts. (Fix lands on that branch; erratum there.)
# CHOICE (flagged): F2/F5 are static checks on committed text —
#     they conflate "the repo today" with "the repo as intended."
#     That is the point of an audit dated to a commit.
# UNPROVABLE FROM INSIDE: that this sweep found the worst bug.
#     Audits sample; only the next stranger bounds the residue.
#     No one has audited THIS audit. (Recurse. Stop at the edge.)
# ============================================================

import Random

exitcode = 0
fail(m) = (global exitcode = 1; println("  ** FAIL ** ", m))
pass(m) = println("  LANDED  ", m)

root = normpath(joinpath(dirname(@__FILE__), ".."))
rd(p) = read(joinpath(root, p), String)

println("kernel: Julia ", VERSION, "   (README pins 1.12 — noted, not failed)")

# --- F1: the shock's missing artifacts ------------------------------
println("\nF1  shocks/PARADOX-REPORT.md: cited artifacts vs the tree")
let cited = ["01_antinomies.jl","02_mathematical.jl","03_probability.jl",
             "04_vagueness_selfreference.jl","run_all.jl"],
    report = rd("shocks/PARADOX-REPORT.md")
    allcited  = all(c -> occursin(c, report), cited)
    anypresent = any(isfile(joinpath(root, "shocks", c)) for c in cited)
    allcited   || fail("F1: report no longer cites the five artifacts")
    anypresent && fail("F1: artifacts exist now — finding stale, re-date the audit")
    occursin("PROVENANCE AMENDMENT", report) ||
        fail("F1: provenance amendment missing — repair reverted, re-convict")
    (allcited && !anypresent) &&
        pass("five artifacts cited, zero present — amendment in place: testimony, not evidence")
end

# --- F2: files that cannot lose --------------------------------------
println("\nF2  failure channels in _00, _01, _02")
let s00 = rd("emergence/emergence_00.jl"), s01 = rd("emergence/emergence_01.jl"),
    s02 = rd("emergence/emergence_02.jl")
    for (n, s) in (("emergence_00", s00), ("emergence_01", s01))
        if occursin("fail(", s) || occursin("exit(exitcode", s)
            fail("F2: $n grew a failure channel — finding stale")
        else
            pass("$n has no fail()/exit discipline — its exit 0 cannot be evidence")
        end
    end
    # RE-DATED: repair landed — _02 must now ASSERT determinism
    if occursin("determined = all(", s02) && occursin("determined || fail(", s02) &&
       occursin("exit(exitcode)", s02)
        pass("_02 now asserts §II determinism with a hard failure channel (F2/F3 repair verified)")
    else
        fail("F2: _02's determinism repair missing or reverted")
    end
end

# --- F3: the phantom citation, and the debt paid by exhaustion --------
println("\nF3  '_03 says verified in _02' — decide it for real")
let s03 = rd("emergence/emergence_03.jl")
    occursin("verified in _02", s03) ||
        fail("F3: the citation is gone — finding stale")
end
# the latch of _02 §II after release: marks 1,2 live, marks 3,4 frozen false
# upd1: a ← !b ; upd2: b ← !a   (inputs [2,3],[1,4] with s3=s4=false)
let upd = ((a,b)::Tuple{Bool,Bool}, i) -> i == 1 ? (!b, b) : (a, !a)
    # absorbing = fixed under BOTH updates
    absorbing = [(a,b) for a in (false,true) for b in (false,true)
                 if upd((a,b),1) == (a,b) && upd((a,b),2) == (a,b)]
    Set(absorbing) == Set([(true,false),(false,true)]) ?
        pass("absorbing states are exactly {▮·, ·▮} (all 4 states exhausted)") :
        fail("F3: absorbing-state census wrong: $absorbing")
    # full nondeterministic closure from the released state (0,0), tagged by
    # first EFFECTIVE mover; collect every reachable absorbing outcome
    function outcomes(first_mover)
        frontier = Set{Tuple{Bool,Bool}}(); done = Set{Tuple{Bool,Bool}}()
        s1 = upd((false,false), first_mover)
        s1 == (false,false) && return Set([:ineffective])
        push!(frontier, s1)
        outs = Set{Tuple{Bool,Bool}}()
        while !isempty(frontier)
            s = pop!(frontier); push!(done, s)
            if upd(s,1) == s && upd(s,2) == s
                push!(outs, s)
            else
                for i in 1:2
                    t = upd(s, i)
                    t in done || push!(frontier, t)
                end
            end
        end
        outs
    end
    o1, o2 = outcomes(1), outcomes(2)
    (o1 == Set([(true,false)]) && o2 == Set([(false,true)])) ?
        pass("first mover ⇒ outcome, by exhaustive closure — _02's claim TRUE, now finally checked") :
        fail("F3: determinism refuted?! mover1→$o1 mover2→$o2 — _02's claim was false, worse than uncited")
end

# --- F4: the census triple is a seed-property --------------------------
println("\nF4  (6,40,14): fact about binary, or fact about seed 3?")
struct W4; inputs::Vector{Vector{Int}}; end
step4(w, s) = BitVector([isempty(w.inputs[i]) ? true : !any(s[j] for j in w.inputs[i])
                         for i in 1:length(w.inputs)])
function unfold4(w, s0; tmax=10_000)
    seen = Dict{BitVector,Int}(); s = s0
    for t in 1:tmax
        seen[s] = t; s = step4(w, s)
        haskey(seen, s) && return t + 1 - seen[s]     # cycle length
    end
    error("no closure")
end
nfp4(w) = count(code -> (s = BitVector([(code>>(i-1))&1==1 for i in 1:12]);
                         s == step4(w, s)), 0:4095)
function census(seed)
    Random.seed!(seed)
    pairs = [(W4([sort!(unique(rand(1:12, rand(1:3)))) for _ in 1:12]),
              BitVector(rand(Bool,12))) for _ in 1:60]
    thing = restless = restposs = 0
    for (w, s0) in pairs
        p = unfold4(w, s0)
        if p == 1; thing += 1
        elseif nfp4(w) == 0; restless += 1
        else; restposs += 1
        end
    end
    (thing, restless, restposs)
end
let c3 = census(3), c4 = census(4), c5 = census(5)
    println("    seed 3 → ", c3, "   seed 4 → ", c4, "   seed 5 → ", c5)
    c3 == (6,40,14) ?
        pass("seed 3 reproduces the quoted baseline on THIS kernel (1.11.7 — stream luck, not contract)") :
        fail("F4: seed 3 gives $c3 ≠ (6,40,14) — the quoted constant does not even replicate here")
    (c4 != (6,40,14) || c5 != (6,40,14)) ?
        pass("neighboring seeds break the triple — (6,40,14) is a seed-property, not a binary-property") :
        fail("F4: seeds 4 AND 5 also give (6,40,14) — triple is robust, attack missed")
    # RE-DATED: repair landed — _04 must carry the stream-dependence tag
    occursin("STREAM-DEPENDENT", rd("emergence/emergence_04.jl")) ?
        pass("_04 baseline now tagged seed-3/stream-dependent (F4 repair verified)") :
        fail("F4: stream-dependence tag missing from _04 — repair reverted")
end

# --- F5: the unverifiable receipt -----------------------------------------
println("\nF5  julia-vs-lean: a receipt that can never be re-verified")
let receipt = rd("julia-vs-lean/run_all_output.txt")
    # RE-DATED: repair landed — timing now goes to stderr, receipt must be
    # deterministic and byte-reproducible. Checks flipped accordingly.
    occursin(r"swept all 65536 symbols in \d+\.\d+s", receipt) &&
        fail("F5: timing line back in receipt — repair reverted, re-convict")
    fresh = read(pipeline(`$(Base.julia_cmd()) $(joinpath(root, "julia-vs-lean/run_all.jl"))`,
                          stderr=devnull), String)
    strip(receipt) == strip(fresh) ?
        pass("receipt is byte-reproducible (timing on stderr) — F5 repair verified on this kernel") :
        fail("F5: receipt does not replicate byte-for-byte — regenerate on this kernel or investigate")
end

# --- F6: the court that could not convict its own constant --------------
println("\nF6  paradoxes branch: near-birthday product formula is FALSE")
# true closed form for P(no pair within cyclic distance ≤1), circular gaps ≥2:
exact_no(N, n) = factorial(big(n)) * big(N) * binomial(big(N-n), big(n)) //
                 (big(N-n) * big(N)^n)
prod_no(N, n)  = prod((N - 3k) / N for k in 1:n-1)
# (a) exhaustion at small N convicts the product form and acquits the exact one
brute_no(N, n) = count(code -> begin
        days = digits(code, base=N, pad=n)
        all(begin d = abs(days[i]-days[j]); min(d, N-d) > 1 end
            for i in 1:n-1 for j in i+1:n)
    end, 0:N^n-1) / N^n
let ok_exact = true, guilty = false
    for (N, n) in ((10,3),(12,3),(14,4),(15,4))
        b = brute_no(N, n)
        ok_exact &= isapprox(b, Float64(exact_no(N, n)); atol=1e-12)
        guilty   |= !isapprox(b, prod_no(N, n); atol=1e-9)
    end
    ok_exact ? pass("exact circular-gap formula matches brute exhaustion at 4 small (N,n)") :
               fail("F6a: exact formula fails exhaustion — prosecution's own weapon corrupt")
    guilty   ? pass("product formula CONVICTED by exhaustion (fails already at N=10, n=3)") :
               fail("F6a: product formula survives exhaustion — attack missed")
end
# (b) power arithmetic: the original court was blind by construction
let truep  = 1 - Float64(exact_no(365, 14)),
    wrongp = 1 - prod_no(365, 14),
    gap = abs(wrongp - truep),
    tol400k = 5 * sqrt(truep * (1 - truep) / 400_000),
    tol4M   = 5 * sqrt(truep * (1 - truep) / 4_000_000)
    println("    true=$(round(truep,digits=6))  committed=$(round(wrongp,digits=6))  gap=$(round(gap,digits=6))")
    println("    5σ at n=400k: $(round(tol400k,digits=6))   5σ at n=4M: $(round(tol4M,digits=6))")
    gap < tol400k ? pass("gap < original court's 5σ — the wrong constant was UNCONVICTABLE at n=400k") :
                    fail("F6b: gap exceeds the 400k tolerance — the original court should have caught it")
    gap > tol4M   ? pass("gap > 5σ at n=4M — an enlarged court has jurisdiction") :
                    fail("F6b: even 4M cannot separate them — conviction below impossible")
    # (c) the enlarged court convicts
    rng = Random.MersenneTwister(20250107)
    function near_mc(rng, npeople, n)
        hits = 0; days = Vector{Int}(undef, npeople)
        for _ in 1:n
            for i in 1:npeople; days[i] = rand(rng, 0:364); end
            found = false
            for i in 1:npeople-1, j in i+1:npeople
                d = abs(days[i] - days[j])
                if min(d, 365 - d) <= 1; found = true; break; end
            end
            hits += found
        end
        hits / n
    end
    mc = near_mc(rng, 14, 4_000_000)
    println("    MC at n=4M: ", round(mc, digits=6))
    abs(mc - truep) <= tol4M ? pass("enlarged court HITS the true constant") :
                               fail("F6c: MC missed the true constant — recheck the exact formula")
    abs(mc - wrongp) > tol4M ? pass("enlarged court EXCLUDES the committed constant — conviction complete") :
                               fail("F6c: MC cannot exclude the committed constant")
end

println()
println(exitcode == 0 ?
  "ALL FINDINGS LANDED — six convictions, one debt paid (F3), one fix owed on the paradoxes branch (F6)." :
  "AUDIT BUILD FAILED — at least one finding did not replicate; re-date or retract it.")
exit(exitcode)
