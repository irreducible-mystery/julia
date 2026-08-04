# ============================================================
# paradox_petersburg.jl — the game whose mean does not exist,
#                         and the modifications that summon one
# ============================================================
# LEDGER — St. Petersburg (Bernoulli 1738): flip until heads; if
# the first head is on flip k, receive 2^k. E[payout] = Σ 1 = ∞.
# Naive Monte Carlo cannot estimate ∞, but it fails in a highly
# structured way — the sample mean GROWS like log₂(n) and never
# stabilizes. This file measures the failure, then applies two
# modifications, each of which manufactures a finite answer:
#   (a) truncation — a bank with finite capital 2^K,
#   (b) utility — Bernoulli's own log-money resolution.
# The point: "modified MC" is not always variance reduction;
# sometimes the modification is a THEORY of why the naive
# question was ill-posed.
# ------------------------------------------------------------
# PRE-REGISTERED PREDICTIONS (hard unless marked soft):
#     P1  (structured divergence) MEDIAN of 31 independent batch
#         means at n = 10^2..10^5, regressed on log₂(n), gives
#         slope in [0.5, 1.5]. Theory: S_n/n ≈ log₂(n) + O_P(1)
#         (Feller); the O_P(1) is heavy-tailed UPWARD, so a single
#         batch mean is a corrupt witness — the median of batches
#         is the honest one. ERRATUM, paid before commit: the
#         first draft regressed SINGLE batch means and drew slope
#         −4.7 from one jackpot at n=10³; the exit code convicted
#         the statistic, not the theory. Medians are the repair.
#     P2  (truncated game) Bank caps payout at 2^K. Exact mean
#         is K + 1 (for the 2^k, k=1.. convention: Σ_{k≤K} 1 + 2^K·2^{-K} = K+1).
#         MC at K = 20 must land within 5σ_est of 21.
#     P3  (utility) E[log₂(payout)] = Σ k·2^{-k} = 2 exactly.
#         MC must land within 5σ_est of 2. The utility integrand
#         has finite variance (Σk²2^{-k} = 6, var = 2) — the SAME
#         random stream that refuses to average in dollars
#         averages calmly in utils. The modification is the cure.
#     P4  (control — the estimator court) For the truncated game,
#         the empirical variance must be FINITE and the 5σ check
#         in P2 must actually bind: σ_est > 0.
# CHOICE (flagged): geometric flips are sampled via inversion
#     k = ⌈log₂(1/U)⌉ ... no — honestly, via explicit coin flips,
#     because the paradox deserves its coins. Cost is O(2) flips
#     per play in expectation; n = 10^6 is cheap.
# UNPROVABLE FROM INSIDE: which modification is TRUE. Truncation
#     says the paradox is about banks; utility says it is about
#     minds. Both exit 0. The disagreement is not decidable here.
# ============================================================

import Random
rng = Random.MersenneTwister(20250103)

exitcode = 0
fail(m) = (global exitcode = 1; println("  ** FAIL ** ", m))

# one play: number of flips until first head (inclusive), payout 2^k
function play(rng)
    k = 1
    while rand(rng, Bool)
        k += 1
    end
    k
end

# --- P1: divergence with a shape ---------------------------------
println("P1  naive means grow like log₂(n) — median of 31 batches per n")
function batch_mean(rng, n)
    local s = 0.0
    for _ in 1:n
        s += 2.0^play(rng)
    end
    s / n
end
ns = [100, 1_000, 10_000, 100_000]
meds = Float64[]
for n in ns
    ms = sort!([batch_mean(rng, n) for _ in 1:31])
    push!(meds, ms[16])
    println("    n = $(lpad(n, 7))   median mean = $(round(ms[16], digits=2))",
            "   (batch range $(round(ms[1],digits=1))–$(round(ms[end],digits=1)))")
end
x = log2.(ns); y = meds
xm, ym = sum(x)/4, sum(y)/4
slope = sum((x .- xm) .* (y .- ym)) / sum((x .- xm).^2)
println("    slope vs log₂(n) = ", round(slope, digits=3))
if 0.5 <= slope <= 1.5
    println("  PASS  divergence has the Feller shape (slope ≈ 1)")
else
    fail("slope $slope outside [0.5, 1.5] — divergence shapeless or absent")
end

# --- P2 + P4: truncation buys a mean ------------------------------
println("P2  truncated bank, cap 2^K, K = 20 — exact mean K+1 = 21")
const K = 20
const NT = 2_000_000
function trunc_stats(rng, n, cap)
    local s = 0.0; local s2 = 0.0
    for _ in 1:n
        p = min(2.0^play(rng), cap)
        s += p; s2 += p^2
    end
    m = s / n
    (m, s2 / n - m^2)
end
m, v = trunc_stats(rng, NT, 2.0^K)
se = sqrt(v / NT)
println("    mean = $(round(m, digits=3))   se = $(round(se, digits=3))")
if abs(m - 21) <= 5se
    println("  PASS  truncated mean within 5σ of 21")
else
    fail("truncated mean $m not within 5·$se of 21")
end
println("P4  estimator court: variance finite and binding")
if isfinite(v) && se > 0
    println("  PASS  var = $(round(v, digits=1)), σ_est > 0")
else
    fail("degenerate variance — P2 was vacuous")
end

# --- P3: Bernoulli's utility — same coins, calm average -----------
println("P3  E[log₂ payout] = 2 exactly (Bernoulli's resolution)")
const NU = 2_000_000
function util_stats(rng, n)
    local s = 0.0; local s2 = 0.0
    for _ in 1:n
        u = Float64(play(rng))        # log₂(2^k) = k
        s += u; s2 += u^2
    end
    m = s / n
    (m, sqrt((s2/n - m^2) / n))
end
mu, seu = util_stats(rng, NU)
println("    mean = $(round(mu, digits=4))   se = $(round(seu, digits=5))")
if abs(mu - 2) <= 5seu
    println("  PASS  utility mean within 5σ of 2")
else
    fail("utility mean $mu not within 5·$seu of 2")
end

println(exitcode == 0 ?
    "ALL PASS — the same coins diverge in dollars and converge in utils." :
    "BUILD FAILED")
exit(exitcode)
