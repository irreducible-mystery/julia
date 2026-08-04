# ============================================================
# paradox_tags.jl — the tag is the question made portable:
#     what combining samplers destroys, and what keeping the
#     sampler's name attached to every draw buys back
# ============================================================
# LEDGER — the five earlier courts each showed a paradox
# dissolving once its sampler was named. This file asks the
# next question: what does COMBINING samplers do, and what does
# EXPLICIT TAGGING (keeping (sampler, outcome) pairs instead of
# outcomes) change? Five claims, each an exit-code claim:
#   (1) untagged mixtures relocate ambiguity into their weights
#       — a new sampler one level up; Bertrand recurses;
#   (2) tagging is lossless: conditioning on the tag recovers
#       every canonical answer from one mixed run;
#   (3) tags are EXCHANGEABLE: the likelihood ratio between two
#       samplers' densities is an exchange rate — draws made
#       under one tag answer another tag's question, no new
#       draws (importance sampling revealed as question
#       transport, not just variance reduction);
#   (4) the spread of tagged answers is an AMBIGUITY METER for
#       a question relative to a family: it reads loud on the
#       chord-length question and zero on a question the family
#       cannot disagree about;
#   (5) Dawid's regime tag: one dataset tagged {observe,
#       intervene} answers BOTH the seeing and the doing
#       question; the untagged blend answers neither.
# ------------------------------------------------------------
# COMMON COORDINATE: a chord of the unit circle reduced to
#     d = distance from center. The three Bertrand samplers
#     induce known densities on d ∈ (0,1):
#       radial     f(d) = 1            P(d < 1/2) = 1/2
#       endpoints  f(d) = 2/(π√(1−d²)) P(d < 1/2) = 1/3
#       midpoint   f(d) = 2d           P(d < 1/2) = 1/4
#     (len > √3 ⇔ d < 1/2 — the question in d-coordinates.)
# PRE-REGISTERED PREDICTIONS (hard; any miss fails the build):
#     P1  two untagged mixtures, weights (1/3,1/3,1/3) and
#         (0.8,0.1,0.1) on (endpoints, radial, midpoint):
#         answers 13/36 and 41/120 respectively, each within 5σ
#         of ITS OWN theory value AND each > 5σ from the OTHER's
#         — the weights are the new sampler; nothing resolved.
#     P2  same mixed run, tags kept: conditioning on each tag
#         recovers 1/3, 1/2, 1/4, each within 5σ of canonical.
#     P3  500_000 draws under the RADIAL tag only, re-weighted by
#         f_target/f_radial, answer the endpoints question (1/3)
#         and the midpoint question (1/4), each within 5σ of its
#         empirical se. (The endpoints weight is unbounded at
#         d→1 but the ESTIMATOR 1[d<1/2]·w has finite second
#         moment — the exchange is affordable ON THE EVENT.)
#     P4  ambiguity meter = max pairwise |pᵢ−pⱼ| in combined-σ
#         units across the three tags. Length question: meter
#         > 5 (ill-posed for this family). Direction question
#         (chord direction angle < π/2, computed from each
#         sampler's own generative coordinates): meter < 5 and
#         every tagged answer within 5σ of 1/2 (well-posed —
#         the family shares rotational symmetry, and the meter
#         certifies exactly that and no more).
#     P5  Simpson world of paradox_simpson_birthday.jl, one run
#         of 400_000 records tagged regime ∈ {observe, intervene}
#         (fair coin). Tagged: observe-pooled has B > A by 5σ
#         (the seeing answer, reversal intact) AND intervene-
#         pooled has A > B by 5σ (the doing answer). Untagged
#         blend: its A−B difference sits > 5σ away from BOTH
#         tagged differences — a number that answers neither
#         question. Erasure, not aggregation, was the crime.
# CHOICE (flagged): the family in P4 is three samplers that all
#     happen to be rotation-invariant, so the direction question
#     PASSES by shared symmetry. The meter certifies consistency
#     RELATIVE TO THE DECLARED FAMILY — never more. A family
#     containing a rotation-breaking sampler would move the
#     needle; declaring the family is part of asking.
# UNPROVABLE FROM INSIDE: who tags the taggers. The choice of
#     family is a sampler one level up, and this file cannot
#     audit its own parametrization. Bertrand recurses; we stop
#     at the visible edge and say so.
# ============================================================

import Random
rng = Random.MersenneTwister(20250106)

exitcode = 0
fail(m) = (global exitcode = 1; println("  ** FAIL ** ", m))
function check(name, got, want, tol)
    ok = abs(got - want) <= tol
    println("  ", ok ? "PASS" : "MISS", "  ", name,
            "  got=", round(got, digits=4), "  want=", round(want, digits=4),
            "  tol=", round(tol, digits=4))
    ok || fail(name)
end

const N = 500_000
const TAGS = (:endpoints, :radial, :midpoint)
const CANON = Dict(:endpoints => 1/3, :radial => 1/2, :midpoint => 1/4)

# draw d under a named sampler (inverse-CDF where closed)
draw_d(rng, tag) = tag === :radial    ? rand(rng) :
                   tag === :endpoints ? abs(cos(π * rand(rng))) :
                                        sqrt(rand(rng))          # midpoint

# densities on d — the tag's full content, kept for exchange
dens(tag, d) = tag === :radial    ? 1.0 :
               tag === :endpoints ? 2 / (π * sqrt(1 - d^2)) :
                                    2d                            # midpoint

sigma(p, n) = sqrt(p * (1 - p) / n)

# --- P1 + P2: one tagged mixed run, read two ways ------------------
# Mixture weights over (endpoints, radial, midpoint)
const W1 = (1/3, 1/3, 1/3);  const A1 = 13/36    # (1/3+1/2+1/4)/3
const W2 = (0.8, 0.1, 0.1);  const A2 = 41/120   # 0.8/3 + 0.05 + 0.025

function tagged_mixture(rng, n, w)
    hits = Dict(t => 0 for t in TAGS)
    cnt  = Dict(t => 0 for t in TAGS)
    for _ in 1:n
        u = rand(rng)
        tag = u < w[1] ? :endpoints : (u < w[1] + w[2] ? :radial : :midpoint)
        cnt[tag] += 1
        hits[tag] += draw_d(rng, tag) < 0.5
    end
    (hits, cnt)
end

h1, c1 = tagged_mixture(rng, N, W1)
h2, c2 = tagged_mixture(rng, N, W2)
p1 = sum(values(h1)) / N
p2 = sum(values(h2)) / N

println("P1  untagged mixtures — the weights are the new sampler")
check("mixture W1 hits its own theory 13/36", p1, A1, 5sigma(A1, N))
check("mixture W2 hits its own theory 41/120", p2, A2, 5sigma(A2, N))
let z12 = abs(p1 - A2) / sigma(A2, N), z21 = abs(p2 - A1) / sigma(A1, N)
    ok = z12 > 5 && z21 > 5
    println("  ", ok ? "PASS" : "MISS",
        "  the two mixtures exclude each other (", round(z12, digits=1),
        "σ, ", round(z21, digits=1), "σ) — ambiguity relocated, not resolved")
    ok || fail("mixtures failed to exclude each other")
end

println("P2  same W1 run, tags kept — conditioning is lossless")
for t in TAGS
    pt = h1[t] / c1[t]
    check("tag=$(t) recovers canonical (n=$(c1[t]))", pt, CANON[t],
          5sigma(CANON[t], c1[t]))
end

# --- P3: the exchange rate — radial draws answer foreign questions --
println("P3  question transport: radial draws, foreign answers")
function transport(rng, n, target)
    local s = 0.0; local s2 = 0.0
    for _ in 1:n
        d = rand(rng)                        # radial tag: f = 1
        x = d < 0.5 ? dens(target, d) : 0.0  # 1[event] · f_target/f_radial
        s += x; s2 += x^2
    end
    m = s / n
    (m, sqrt((s2/n - m^2) / n))
end
for target in (:endpoints, :midpoint)
    m, se = transport(rng, N, target)
    check("radial → $(target) question", m, CANON[target], 5se)
end

# --- P4: the ambiguity meter ---------------------------------------
println("P4  ambiguity meter: spread of tagged answers, in σ units")
# direction angle of the chord, computed from each sampler's OWN
# generative coordinates (not assumed uniform):
function draw_dir(rng, tag)
    if tag === :endpoints
        a, b = 2π*rand(rng), 2π*rand(rng)
        mod(atan(sin(b) - sin(a), cos(b) - cos(a)), π)
    elseif tag === :radial
        mod(2π*rand(rng) + π/2, π)           # ⊥ to the radius
    else
        mx, my = 2rand(rng)-1, 2rand(rng)-1
        while mx^2 + my^2 > 1
            mx, my = 2rand(rng)-1, 2rand(rng)-1
        end
        mod(atan(my, mx) + π/2, π)           # ⊥ to the midpoint ray
    end
end

function meter(estimates)   # [(p, n)] → max pairwise gap in combined σ
    worst = 0.0
    for i in 1:3, j in i+1:3
        (pi, ni), (pj, nj) = estimates[i], estimates[j]
        z = abs(pi - pj) / sqrt(pi*(1-pi)/ni + pj*(1-pj)/nj)
        worst = max(worst, z)
    end
    worst
end

len_est = [(count(_ -> draw_d(rng, t) < 0.5, 1:N) / N, N) for t in TAGS]
dir_est = [(count(_ -> draw_dir(rng, t) < π/2, 1:N) / N, N) for t in TAGS]

zlen = meter(len_est); zdir = meter(dir_est)
let ok = zlen > 5
    println("  ", ok ? "PASS" : "MISS",
        "  length question: meter reads ", round(zlen, digits=1),
        "σ — ill-posed for this family")
    ok || fail("length meter failed to exceed 5σ")
end
let ok = zdir < 5
    println("  ", ok ? "PASS" : "MISS",
        "  direction question: meter reads ", round(zdir, digits=1),
        "σ — family cannot disagree")
    ok || fail("direction meter unexpectedly loud")
end
for (i, t) in enumerate(TAGS)
    check("direction under tag=$(t) is 1/2", dir_est[i][1], 0.5, 5sigma(0.5, N))
end

# --- P5: the regime tag — seeing and doing in one ledger ------------
println("P5  Dawid's regime tag on the Simpson world")
const NS = 400_000
recover_p(sev, tA) = sev ? (tA ? 0.55 : 0.50) : (tA ? 0.95 : 0.90)

function regime_world(rng, n)
    rec = zeros(Int, 2, 2); tri = zeros(Int, 2, 2)   # [regime, treatment]
    for _ in 1:n
        sev    = rand(rng) < 0.5
        regime = rand(rng) < 0.5 ? 1 : 2             # 1 observe, 2 intervene
        pA     = regime == 2 ? 0.5 : (sev ? 0.85 : 0.15)
        tA     = rand(rng) < pA
        r      = rand(rng) < recover_p(sev, tA)
        ti     = tA ? 1 : 2
        tri[regime, ti] += 1; rec[regime, ti] += r
    end
    rec, tri
end
rec, tri = regime_world(rng, NS)
rate(r, t) = rec[r, t] / tri[r, t]
se(r, t)   = sqrt(rate(r,t) * (1 - rate(r,t)) / tri[r,t])

d_obs = rate(1,1) - rate(1,2); se_obs = sqrt(se(1,1)^2 + se(1,2)^2)
d_int = rate(2,1) - rate(2,2); se_int = sqrt(se(2,1)^2 + se(2,2)^2)
let ok = -d_obs > 5se_obs
    println("  ", ok ? "PASS" : "MISS",
        "  tag=observe: B=$(round(rate(1,2),digits=3)) > A=$(round(rate(1,1),digits=3)) — the seeing answer (reversal intact)")
    ok || fail("observe arm lost the reversal")
end
let ok = d_int > 5se_int
    println("  ", ok ? "PASS" : "MISS",
        "  tag=intervene: A=$(round(rate(2,1),digits=3)) > B=$(round(rate(2,2),digits=3)) — the doing answer")
    ok || fail("intervene arm lost A's superiority")
end
# untagged blend: pool across regimes as if the tag never existed
rb(t) = (rec[1,t] + rec[2,t]) / (tri[1,t] + tri[2,t])
seb(t) = sqrt(rb(t) * (1 - rb(t)) / (tri[1,t] + tri[2,t]))
d_blend = rb(1) - rb(2); se_blend = sqrt(seb(1)^2 + seb(2)^2)
let z_obs = abs(d_blend - d_obs) / sqrt(se_blend^2 + se_obs^2),
    z_int = abs(d_blend - d_int) / sqrt(se_blend^2 + se_int^2)
    ok = z_obs > 5 && z_int > 5
    println("  ", ok ? "PASS" : "MISS",
        "  untagged blend: A−B = $(round(d_blend,digits=3)) sits ",
        round(z_obs, digits=1), "σ from seeing and ",
        round(z_int, digits=1), "σ from doing — answers neither")
    ok || fail("blend failed to differ from both tagged answers")
end

println(exitcode == 0 ?
    "ALL PASS — erasure was the paradox; the tag is the question, kept." :
    "BUILD FAILED")
exit(exitcode)
