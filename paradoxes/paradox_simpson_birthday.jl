# ============================================================
# paradox_simpson_birthday.jl — two paradoxes of aggregation:
#     collisions arrive early; averages reverse under pooling
# ============================================================
# LEDGER — two courts in one file, both about what happens when
# you collapse structure you should have kept.
#
# BIRTHDAY: with 23 people, P(shared birthday) > 1/2 — the
# intuition fails because there are C(23,2) = 253 pairs, not 22.
# MODIFIED variant: "near-birthday" (within ±1 day, cyclic year).
# The near-match threshold drops to 14 people. Same engine, one
# parameter turned — the modification shows the paradox is about
# pair-counting, not about the number 365.
#
# SIMPSON: a treatment better in EVERY subgroup, worse in the
# pool. We do not merely cite the arithmetic; we build a
# GENERATIVE world (confounder → severity → treatment choice and
# outcome) and let Monte Carlo produce the reversal from the
# mechanism. The paradox is a fact about the sampler — doctors
# assign the good treatment to the hard cases — and vanishes the
# moment MC is MODIFIED to intervene (randomized assignment):
# that modification is exactly the do-operator, run, not preached.
# ------------------------------------------------------------
# PRE-REGISTERED PREDICTIONS (hard):
#     P1  P(match, 23 people, 365 days) = 0.5073 ± 5σ.
#     P2  exact-match crossing: smallest n with P > 1/2 is 23
#         (bracketed by MC at 22 below and 23 above, 5σ each side).
#     P3  near-match (±1 day): with 14 people P > 1/2, with 13 P < 1/2
#         (5σ). Exact CDF for ±1 via the circular-gap (≥2) closed
#         form  P(none) = n!·N·C(N−n,n) / ((N−n)·N^n), verified
#         by brute exhaustion at small N inside this file, and
#         checked by MC at n=4_000_000 (5σ = 0.00125 — an
#         instrument fine enough to convict a wrong constant).
#         ERRATUM, convicted by the adversarial sweep (audits/
#         adversarial_sweep_by_stranger.jl F6, replicated in
#         paradoxes/audit_paradoxes_by_author.jl): the first
#         committed draft used ∏(365−3k)/365, "the clean product
#         form" — which is FALSE (fails exhaustion at N=10, n=3;
#         off by 0.00284 at (365,14)). It passed because the
#         original court's 5σ at n=400_000 was 0.00394: the
#         error was smaller than the instrument. A PASS is a
#         fact about (claim, instrument) — this file now quotes
#         the pair. The wrong formula is preserved here because
#         deleting it would repeat the error.
#     P4  Simpson world, OBSERVATIONAL arm: treatment A beats B
#         inside both severity strata (each by > 5σ) AND loses
#         pooled (by > 5σ). All three inequalities must hold in
#         one run — the reversal, machine-checked.
#     P5  Simpson world, INTERVENTIONAL arm (assignment coin
#         replaces doctor): pooled ordering flips back — A beats
#         B pooled by > 5σ. The confounder was the whole paradox.
# CHOICE (flagged): the Simpson world's parameters are chosen to
#     make the reversal robust at n = 400_000, not to be subtle.
#     Subtlety is a different file.
# UNPROVABLE FROM INSIDE: that real hospitals are this world.
#     The file proves possibility and mechanism, not prevalence.
# ============================================================

import Random
rng = Random.MersenneTwister(20250104)

exitcode = 0
fail(m) = (global exitcode = 1; println("  ** FAIL ** ", m))

# ---------------- BIRTHDAY COURT ---------------------------------
const NB = 400_000

function p_match(rng, npeople, n; window = 0)
    hits = 0
    days = Vector{Int}(undef, npeople)
    for _ in 1:n
        for i in 1:npeople
            days[i] = rand(rng, 0:364)
        end
        found = false
        for i in 1:npeople-1, j in i+1:npeople
            d = abs(days[i] - days[j])
            if min(d, 365 - d) <= window
                found = true; break
            end
        end
        hits += found
    end
    hits / n
end

sigmaB(p) = sqrt(p*(1-p)/NB)

println("P1  classic: 23 people, exact match")
p23 = p_match(rng, 23, NB)
exact23 = 1 - prod((365 - k) / 365 for k in 0:22)
ok = abs(p23 - exact23) <= 5sigmaB(exact23)
println("  ", ok ? "PASS" : "MISS", "  got=$(round(p23,digits=4)) exact=$(round(exact23,digits=4))")
ok || fail("P1")

println("P2  the crossing sits between 22 and 23 people")
p22 = p_match(rng, 22, NB)
ok1 = p22 < 0.5 - 5sigmaB(0.5)
ok2 = p23 > 0.5 + 5sigmaB(0.5)
println("  ", ok1 ? "PASS" : "MISS", "  n=22 below 1/2  (got $(round(p22,digits=4)))")
println("  ", ok2 ? "PASS" : "MISS", "  n=23 above 1/2  (got $(round(p23,digits=4)))")
(ok1 && ok2) || fail("P2")

println("P3  modified: near-match ±1 day — crossing drops to 14")
# exact circular-gap (≥2) closed form; the product form ∏(365−3k)/365 was
# convicted (see ERRATUM in the ledger). Acquit the exact form by exhaustion
# at small N first — the formula must earn jurisdiction before it judges MC:
exact_no(N, n) = factorial(big(n)) * big(N) * binomial(big(N-n), big(n)) //
                 (big(N-n) * big(N)^n)
brute_no(N, n) = count(code -> begin
        days = digits(code, base=N, pad=n)
        all(begin d = abs(days[i]-days[j]); min(d, N-d) > 1 end
            for i in 1:n-1 for j in i+1:n)
    end, 0:N^n-1) / N^n
for (N, n) in ((10,3),(14,4))
    ok = isapprox(brute_no(N, n), Float64(exact_no(N, n)); atol=1e-12)
    println("  ", ok ? "PASS" : "MISS", "  exact form matches exhaustion at N=$N, n=$n")
    ok || fail("P3 formula check at N=$N")
end
const NB4 = 4_000_000      # instrument fine enough to convict a wrong constant
sigmaB4(p) = sqrt(p*(1-p)/NB4)
p14 = p_match(rng, 14, NB4; window = 1)
p13 = p_match(rng, 13, NB;  window = 1)
exact14 = 1 - Float64(exact_no(365, 14))
wrong14 = 1 - prod((365 - 3k) / 365 for k in 1:13)   # the convicted constant
oka = abs(p14 - exact14) <= 5sigmaB4(exact14)
okw = abs(p14 - wrong14) >  5sigmaB4(exact14)
okb = p14 > 0.5 + 5sigmaB4(0.5)
okc = p13 < 0.5 - 5sigmaB(0.5)
println("  ", oka ? "PASS" : "MISS", "  n=14 hits exact form (got $(round(p14,digits=5)), exact $(round(exact14,digits=5)), n=4M)")
println("  ", okw ? "PASS" : "MISS", "  n=14 EXCLUDES the convicted product constant $(round(wrong14,digits=5))")
println("  ", okb ? "PASS" : "MISS", "  n=14 above 1/2")
println("  ", okc ? "PASS" : "MISS", "  n=13 below 1/2  (got $(round(p13,digits=4)))")
(oka && okw && okb && okc) || fail("P3")

# ---------------- SIMPSON COURT ----------------------------------
# Generative world:
#   severity S ~ Bernoulli(0.5)            (mild = 0, severe = 1)
#   observational doctor: P(A | severe) = 0.85, P(A | mild) = 0.15
#     (good drug goes to hard cases — the confounding arrow)
#   recovery: mild:   A → 0.95, B → 0.90
#             severe: A → 0.55, B → 0.50    (A better in BOTH strata)
const NS = 400_000

recover_p(sev, tr) = sev == 0 ? (tr == :A ? 0.95 : 0.90) :
                                (tr == :A ? 0.55 : 0.50)

function simpson(rng, n; intervene::Bool)
    # counts[stratum, treatment] = (recoveries, trials); stratum 3 = pooled
    rec = zeros(Int, 3, 2); tri = zeros(Int, 3, 2)
    for _ in 1:n
        sev = rand(rng) < 0.5 ? 0 : 1
        pA  = intervene ? 0.5 : (sev == 1 ? 0.85 : 0.15)
        tr  = rand(rng) < pA ? :A : :B
        r   = rand(rng) < recover_p(sev, tr)
        ti  = tr == :A ? 1 : 2
        for s in (sev + 1, 3)
            tri[s, ti] += 1
            rec[s, ti] += r
        end
    end
    rate(s, t) = rec[s, t] / tri[s, t]
    se(s, t)   = sqrt(rate(s,t) * (1 - rate(s,t)) / tri[s,t])
    (rate, se, tri)
end

println("P4  Simpson, observational arm — reversal demanded")
rate, se, tri = simpson(rng, NS; intervene = false)
labels = ("mild", "severe", "POOLED")
let allok = true
    for s in 1:2
        diff = rate(s,1) - rate(s,2)
        tolr = 5 * sqrt(se(s,1)^2 + se(s,2)^2)
        ok = diff > tolr
        println("  ", ok ? "PASS" : "MISS",
            "  $(labels[s]): A=$(round(rate(s,1),digits=3)) > B=$(round(rate(s,2),digits=3))  (nA=$(tri[s,1]), nB=$(tri[s,2]))")
        allok &= ok
    end
    diffp = rate(3,2) - rate(3,1)   # B minus A, pooled
    tolp  = 5 * sqrt(se(3,1)^2 + se(3,2)^2)
    okp = diffp > tolp
    println("  ", okp ? "PASS" : "MISS",
        "  POOLED: B=$(round(rate(3,2),digits=3)) > A=$(round(rate(3,1),digits=3)) — the reversal")
    (allok && okp) || fail("P4")
end

println("P5  Simpson, interventional arm (the do-operator as modified MC)")
rate2, se2, _ = simpson(rng, NS; intervene = true)
diffi = rate2(3,1) - rate2(3,2)
toli  = 5 * sqrt(se2(3,1)^2 + se2(3,2)^2)
oki = diffi > toli
println("  ", oki ? "PASS" : "MISS",
    "  randomized: A=$(round(rate2(3,1),digits=3)) > B=$(round(rate2(3,2),digits=3)) pooled — reversal gone")
oki || fail("P5")

println(exitcode == 0 ?
    "ALL PASS — collisions come from pairs; reversals come from who holds the coin." :
    "BUILD FAILED")
exit(exitcode)
