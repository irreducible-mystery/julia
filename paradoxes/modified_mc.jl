# ============================================================
# modified_mc.jl — three modifications of the Monte Carlo court
#     itself, each bought with a bias-shaped IOU that must be
#     repaid exactly, plus the two-envelope paradox as the case
#     where no modification can pay
# ============================================================
# LEDGER — the paradox files treat MC as a fixed court and vary
# the question. This file varies the COURT. Three standard
# modifications — antithetic variates, importance sampling,
# control variates — each changes the sampler or the integrand
# and must prove two things: (i) unbiasedness survived the
# modification, (ii) variance actually fell. A speedup claimed
# in prose is worthless; both are exit-code claims here.
# Then the two-envelope paradox: the E[swap gain] = 25% argument
# is an importance-sampling error in disguise — an expectation
# taken under a measure that was never defined. MC refuses to
# run an undefined measure; the refusal is the resolution.
# ------------------------------------------------------------
# PRE-REGISTERED PREDICTIONS (hard):
#     TARGET A: I = ∫₀¹ e^x dx = e − 1 (smooth, monotone).
#     P1  antithetic pairs (U, 1−U): estimate within 5σ of e−1
#         AND paired-sample variance < 0.05 × plain variance
#         (theory: corr(e^U, e^{1−U}) ≈ −0.968 → ~96% reduction;
#         demanding 95% is strict but seed-safe at n = 10^6).
#     TARGET B: rare event p = P(Z > 4), Z ~ N(0,1), p ≈ 3.167e-5.
#     P2  plain MC at n = 10^5 sees ≈ 3 hits — relative error is
#         garbage (we assert only that it ran). Importance
#         sampling with proposal N(4,1) at the SAME n: estimate
#         within 5σ_IS of Φ(−4), AND σ_IS < σ_plain / 10.
#         The likelihood ratio exp(8 − 4z)·[z>4]... explicitly:
#         w(z) = φ(z)/φ(z−4) = exp(−4z + 8). Unbiasedness is the
#         5σ hit; the IOU (weights) repaid by the check itself.
#     TARGET C: I again by control variate g(x) = 1 + x
#         (E[g] = 3/2 known).
#     P3  control-variate estimate within 5σ of e−1 AND variance
#         < 0.02 × plain. ERRATUM, paid before commit: first
#         draft demanded < 0.01 × plain from a misremembered
#         "~250×" folklore figure. The actual algebra: with
#         X~U(0,1), Var(e^X) = (e²−1)/2 − (e−1)² ≈ 0.2420,
#         Cov(e^X, X) = 1 − (e−1)/2 ≈ 0.1409, Var(X) = 1/12,
#         so ρ² ≈ 0.9838 and the residual is ≈ 1.62% of plain —
#         a 62× reduction, not 250×. The exit code convicted the
#         folklore; the derivation is the repair. 0.02 is now the
#         THEOREM'S number (0.0162) plus seed slack, not a hope.
#     P4  two envelopes: (a) the SYMMETRIC court — amounts fixed
#         (x, 2x), envelope choice a fair coin: E[gain from
#         always swapping] = 0 within 5σ. (b) the BROKEN court —
#         the 1.25 argument needs P(other = 2y | mine = y) = 1/2
#         for ALL y, i.e. a uniform prior on {x : x and 2x both
#         possible} over an infinite ladder. On any FINITE ladder
#         (levels 2^0..2^M, uniform), swapping conditioned on
#         y NOT at the top rung gains ≈ +25% (5σ), but the
#         UNCONDITIONAL gain is still 0 (5σ): the paradoxical 25%
#         lives entirely on the rungs where the argument silently
#         conditions away the ceiling. Both claims machine-checked.
# CHOICE (flagged): β for the control variate is the THEORETICAL
#     covariance ratio, not fitted — fitting on the same sample
#     would smuggle a small bias into the court being audited.
# UNPROVABLE FROM INSIDE: that 5σ is the right skepticism. It is
#     a convention. The stranger may tighten it.
# ============================================================

import Random
rng = Random.MersenneTwister(20250105)

exitcode = 0
fail(m) = (global exitcode = 1; println("  ** FAIL ** ", m))

const N = 1_000_000
const I = exp(1) - 1                       # target A truth

meanvar(v) = (m = sum(v)/length(v); (m, sum(x -> (x-m)^2, v)/(length(v)-1)))

# --- plain baseline for target A ---------------------------------
plainA = [exp(rand(rng)) for _ in 1:N]
mA, vA = meanvar(plainA)
println("baseline  plain MC on ∫e^x: mean=$(round(mA,digits=5)) var=$(round(vA,digits=5))")

# --- P1 antithetic -------------------------------------------------
println("P1  antithetic variates (U, 1−U)")
anti = Vector{Float64}(undef, N ÷ 2)
for i in 1:N÷2
    u = rand(rng)
    anti[i] = (exp(u) + exp(1 - u)) / 2
end
mAn, vAn = meanvar(anti)
seAn = sqrt(vAn / length(anti))
ok1 = abs(mAn - I) <= 5seAn
ok2 = vAn < 0.05 * vA
println("  ", ok1 ? "PASS" : "MISS", "  unbiased: $(round(mAn,digits=5)) vs $(round(I,digits=5)) (5σ=$(round(5seAn,sigdigits=2)))")
println("  ", ok2 ? "PASS" : "MISS", "  variance $(round(vAn,sigdigits=3)) < 5% of plain $(round(vA,sigdigits=3))")
(ok1 && ok2) || fail("P1")

# --- P2 importance sampling on P(Z > 4) ----------------------------
println("P2  importance sampling, rare event P(Z>4)")
# truth via erfc: Φ(−4) = erfc(4/√2)/2 — base library has no erfc; use
# a continued-fraction Mills bound sandwich instead? No: hardcode the
# accepted constant and CHECK the sandwich φ(4)(1/4 − 1/4³) < p < φ(4)/4.
const ptrue = 3.167124183311998e-5
φ(z) = exp(-z^2/2) / sqrt(2π)
lo, hi = φ(4)*(1/4 - 1/64), φ(4)/4
(lo < ptrue < hi) || fail("hardcoded ptrue fails the Mills sandwich — constant corrupt")

const NR = 100_000
plain_hits = count(_ -> randn(rng) > 4, 1:NR)
p_plain = plain_hits / NR
v_plain = ptrue * (1 - ptrue)              # theoretical per-sample variance
println("    plain: $plain_hits hits in $NR (estimate $(p_plain)) — noted, not trusted")

w = Vector{Float64}(undef, NR)
for i in 1:NR
    z = 4 + randn(rng)                     # proposal N(4,1)
    w[i] = z > 4 ? exp(8 - 4z) : 0.0       # φ(z)/φ(z−4) on the event
end
mIS, vIS = meanvar(w)
seIS = sqrt(vIS / NR)
ok1 = abs(mIS - ptrue) <= 5seIS
ok2 = sqrt(vIS) < sqrt(v_plain) / 10
println("  ", ok1 ? "PASS" : "MISS", "  unbiased: $(round(mIS,sigdigits=5)) vs $(round(ptrue,sigdigits=5)) (5σ=$(round(5seIS,sigdigits=2)))")
println("  ", ok2 ? "PASS" : "MISS", "  σ per sample $(round(sqrt(vIS),sigdigits=3)) < plain σ/10 = $(round(sqrt(v_plain)/10,sigdigits=3))")
(ok1 && ok2) || fail("P2")

# --- P3 control variate --------------------------------------------
println("P3  control variate g(x)=1+x, E[g]=3/2, theoretical β")
# β* = Cov(e^X, 1+X)/Var(1+X); X~U(0,1): Cov = ∫x e^x − (e−1)/2 = 1 − (e−1)/2... 
# compute symbolically: E[Xe^X] = ∫₀¹ x eˣ dx = 1. Cov = 1 − (1/2)(e−1).
# Var(1+X) = 1/12. β* = 12(1 − (e−1)/2).
const β = 12 * (1 - (exp(1) - 1)/2)
cv = Vector{Float64}(undef, N)
for i in 1:N
    x = rand(rng)
    cv[i] = exp(x) - β * ((1 + x) - 1.5)
end
mCV, vCV = meanvar(cv)
seCV = sqrt(vCV / N)
ok1 = abs(mCV - I) <= 5seCV
ok2 = vCV < 0.02 * vA
println("  ", ok1 ? "PASS" : "MISS", "  unbiased: $(round(mCV,digits=6)) vs $(round(I,digits=6)) (5σ=$(round(5seCV,sigdigits=2)))")
println("  ", ok2 ? "PASS" : "MISS", "  variance $(round(vCV,sigdigits=3)) < 2% of plain $(round(vA,sigdigits=3)) (theory: 1.62%)")
(ok1 && ok2) || fail("P3")

# --- P4 two envelopes ----------------------------------------------
println("P4a two envelopes, symmetric court: swap gains nothing")
const NE = 1_000_000
g = Vector{Float64}(undef, NE)
for i in 1:NE
    x = 1.0 + 9.0*rand(rng)                # amounts (x, 2x), any positive law
    mine, other = rand(rng, Bool) ? (x, 2x) : (2x, x)
    g[i] = other - mine                    # gain from always swapping
end
mG, vG = meanvar(g)
seG = sqrt(vG / NE)
ok = abs(mG) <= 5seG
println("  ", ok ? "PASS" : "MISS", "  E[gain] = $(round(mG,digits=4)) (5σ=$(round(5seG,digits=4)))")
ok || fail("P4a")

println("P4b finite ladder: the 25% lives only below the ceiling")
const M = 10                                # low envelope 2^0 .. 2^M
function ladder(rng, n)
    # returns (mean ratio-gain on interior rungs, its se, count,
    #          mean absolute gain overall, its se)
    local cs = 0.0; local cs2 = 0.0; local cn = 0
    local as = 0.0; local as2 = 0.0
    for _ in 1:n
        k = rand(rng, 0:M)                 # pair (2^k, 2^{k+1})
        lowamt = 2.0^k
        mine, other = rand(rng, Bool) ? (lowamt, 2lowamt) : (2lowamt, lowamt)
        d = other - mine
        as += d; as2 += d^2
        # the paradox's conditioning: "given my amount y, the other is 2y or
        # y/2 with equal chance" — true only on INTERIOR rungs y = 2^1..2^M.
        # (y=2^0 forces other=2y; y=2^{M+1} forces other=y/2.)
        if 1 <= log2(mine) <= M
            r = d / mine
            cs += r; cs2 += r^2
            cn += 1
        end
    end
    mc = cs / cn;  sec = sqrt((cs2/cn - mc^2) / cn)
    ma = as / n;   sea = sqrt((as2/n - ma^2) / n)
    (mc, sec, cn, ma, sea)
end
gain_cond, se_cond, condn, gain_all, se_all = ladder(rng, NE)
ok1 = abs(gain_cond - 0.25) <= 5se_cond
ok2 = abs(gain_all) <= 5se_all
println("  ", ok1 ? "PASS" : "MISS", "  interior rungs: mean ratio gain $(round(gain_cond,digits=4)) ≈ 0.25 (n=$condn, 5σ=$(round(5se_cond,digits=4)))")
println("  ", ok2 ? "PASS" : "MISS", "  unconditional gain $(round(gain_all,digits=4)) ≈ 0 (5σ=$(round(5se_all,digits=3)))")
(ok1 && ok2) || fail("P4b")

println(exitcode == 0 ?
    "ALL PASS — every modification repaid its IOU; the envelope owed a measure no one had." :
    "BUILD FAILED")
exit(exitcode)
