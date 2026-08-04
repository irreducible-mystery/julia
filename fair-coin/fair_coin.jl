# ============================================================
# fair_coin.jl — the von Neumann extractor: a fair coin from a
#     crooked one, exact in ℚ, convicted and acquitted by MC,
#     and (P4) a surprise about Markov sources.
# ============================================================
# LEDGER — the auditing instance, proposing something entirely
# new. The user said "flip a coin ;p". House law says a coin
# flip must be an ARTIFACT: the coin's fairness proved exactly,
# its source verifiably biased, the flip anchored so the flipper
# cannot re-roll. This file is the coin's credentials; the flip
# itself lives in flip.jl and is bound to the pre-registration
# commit hash (see FLIP.md).
#
# THE EXTRACTOR (von Neumann 1951): read a biased iid stream in
# non-overlapping pairs; discard 00 and 11; map 01 → 1, 10 → 0.
# P(01) = (1−p)p and P(10) = p(1−p): the entire theorem is
# mul_comm. The dial law here is FLAT — P(1 | accepted) = 1/2
# for EVERY p ∈ (0,1), a constant fiber where every previous
# dial in this repo moved.
#
# PRE-REGISTERED PREDICTIONS (all hard; any miss fails this build):
#   P1  EXACT ℚ, honest extractor: P(1|accept) == 1//2 for a
#       grid of rationals p — flat dial, no simulation needed.
#   P2  EXACT ℚ, cheating extractor (greedy: also accepts 11→1):
#       P(1|accept) == 1/(2−p) exactly — a genuine dial, equal
#       to 1//2 for NO p in (0,1]. The cheat is never fair.
#   P3  MC, iid source at p=0.7 (n=800_000 raw bits): the RAW
#       stream is convicted of bias at >5σ; the EXTRACTED stream
#       is within 5σ of fair; the greedy cheat's output is
#       convicted at >5σ and lands near 1/(2−0.7) = 0.769….
#   P4  YIELD: #accepted from 400_000 pairs is within 5σ of
#       Binomial(400_000, 2p(1−p)) — fairness costs 1/(2p(1−p))
#       pairs per bit; the entropy meter runs while you launder.
#   P5  MARKOV SURPRISE: on a STATIONARY 2-state Markov source
#       (sticky, p01=p10=0.1) the extracted MARGINAL is still
#       fair (within 5σ) — because 2-state stationarity IS
#       detailed balance: π₀p₀₁ = π₁p₁₀ forces P(01)=P(10).
#       But consecutive extracted bits are CORRELATED: convicted
#       at >5σ (predicted direction: anti-correlation — an
#       accepted pair leaves the chain in the state that favors
#       the OPPOSITE pair next). Control: the iid stream from P3
#       shows no such correlation (within 5σ).
#
# FORCED-FAILURE CONTROLS (run before commit, verbatim record):
#   mutant A — P2's dial law changed to 1/(2+p):    exit 1 ✓
#   mutant B — extractor pair map swapped (emit a
#     instead of b): exit 0. This is a NULL mutation
#     by symmetry — relabeling a fair coin's faces
#     is still a fair coin — and is recorded as such
#     rather than hidden; a court that convicted it
#     would be the broken instrument.
#   mutant C — P5's predicted anti-correlation sign
#     flipped to positive:                          exit 1 ✓
#   Two live convictions, one honest acquittal.
# ------------------------------------------------------------

import Random

exitcode = 0
pass(m) = println("  PASS  ", m)
fail(m) = (global exitcode = 1; println("  ** FAIL ** ", m))

println("=== fair_coin.jl — credentials for a coin nobody has to trust ===")

# --- P1: exact flat dial for the honest extractor ------------------------
println("\nP1  honest extractor, exact in ℚ: the dial that does not turn")
function p1_flat()
    for p in (1//10, 1//3, 179//256, 1//2, 7//9, 9//10, 355//1000)
        w01 = (1 - p) * p          # pair (0,1) → bit 1
        w10 = p * (1 - p)          # pair (1,0) → bit 0
        w01 / (w01 + w10) == 1//2 || return (false, p)
    end
    (true, 0//1)
end
let (ok, badp) = p1_flat()
    ok ? pass("P(1|accept) == 1//2 exactly at 7 rationals incl. p=179//256 (the flip source's bias)") :
         fail("P1: flat dial broken at p=$badp")
end

# --- P2: exact dial for the cheat -----------------------------------------
println("\nP2  greedy cheat (11 also accepted as 1): dial P = 1/(2−p), never fair")
function p2_cheat()
    for p in (1//10, 1//3, 179//256, 1//2, 7//9, 9//10)
        w1 = (1 - p) * p + p * p   # 01 and 11 both emit 1
        w  = 2 * p * (1 - p) + p * p
        w1 / w == 1 / (2 - p)     || return (false, p, :form)
        w1 / w == 1//2 && p != 0  && return (false, p, :fair)
    end
    (true, 0//1, :ok)
end
let (ok, badp, why) = p2_cheat()
    ok ? pass("cheat dial == 1/(2−p) exactly at 6 rationals, equal to 1/2 at none (even p=1/2 gives 2/3)") :
         fail("P2: cheat dial broken at p=$badp ($why)")
end

# --- shared machinery ------------------------------------------------------
"non-overlapping von Neumann extraction: (0,1)→1, (1,0)→0, else discard"
function extract_vn(bits::AbstractVector{Bool})
    out = Bool[]
    for k in 1:2:length(bits)-1
        a, b = bits[k], bits[k+1]
        a != b && push!(out, b)
    end
    out
end
"greedy cheat: also accepts (1,1) as 1"
function extract_cheat(bits::AbstractVector{Bool})
    out = Bool[]
    for k in 1:2:length(bits)-1
        a, b = bits[k], bits[k+1]
        if a != b; push!(out, b)
        elseif a && b; push!(out, true)
        end
    end
    out
end
zscore(k, n, p0) = (k / n - p0) / sqrt(p0 * (1 - p0) / n)

# --- P3: the laundering, watched by a court --------------------------------
println("\nP3  iid source p=0.7: raw convicted, extracted acquitted, cheat convicted")
const RNG = Random.MersenneTwister(20260804)
const RAW = BitVector(rand(RNG) < 0.7 for _ in 1:800_000)
const EXT = extract_vn(collect(RAW))
let zraw = zscore(count(RAW), length(RAW), 0.5)
    abs(zraw) > 5 ? pass("raw stream convicted of bias: z = $(round(zraw, digits=1))σ from fair") :
                    fail("P3: raw stream looks fair (z=$zraw) — source generator broken")
end
let zext = zscore(count(EXT), length(EXT), 0.5)
    abs(zext) <= 5 ? pass("extracted stream within 5σ of fair: z = $(round(zext, digits=2))σ  (n=$(length(EXT)))") :
                     fail("P3: extracted stream convicted (z=$zext) — extractor broken")
end
let ch = extract_cheat(collect(RAW)), zch = zscore(count(ch), length(ch), 0.5),
    target = 1 / (2 - 0.7), zt = zscore(count(ch), length(ch), target)
    abs(zch) > 5 ? pass("cheat convicted: z = $(round(zch, digits=1))σ from fair") :
                   fail("P3: cheat passed the fairness court — court too weak")
    abs(zt) <= 5 ? pass("cheat lands on its exact dial 1/(2−p) = $(round(target, digits=4)) (z = $(round(zt, digits=2))σ)") :
                   fail("P3: cheat missed its own dial (z=$zt)")
end

# --- P4: the entropy fee ----------------------------------------------------
println("\nP4  yield: fairness costs 1/(2p(1−p)) pairs per bit")
let npairs = length(RAW) ÷ 2, q = 2 * 0.7 * 0.3,
    z = zscore(length(EXT), npairs, q)
    println("    accepted $(length(EXT)) of $npairs pairs; expected q = $q")
    abs(z) <= 5 ? pass("acceptance within 5σ of Binomial(n, 2p(1−p)): z = $(round(z, digits=2))σ — fee ≈ $(round(1/q, digits=2)) pairs/bit") :
                  fail("P4: yield off (z=$z)")
end

# --- P5: the Markov surprise -------------------------------------------------
println("\nP5  stationary Markov source: marginal fair, neighbors guilty")
function markov_bits(rng, n; p01=0.1, p10=0.1)
    bits = Vector{Bool}(undef, n)
    s = rand(rng) < p01 / (p01 + p10)          # stationary start
    for i in 1:n
        s = s ? !(rand(rng) < p10) : (rand(rng) < p01)
        bits[i] = s
    end
    bits
end
same_frac(v) = count(v[i+1] == v[i] for i in 1:length(v)-1) / (length(v) - 1)
let mb = markov_bits(RNG, 1_000_000), me = extract_vn(mb)
    zmarg = zscore(count(me), length(me), 0.5)
    abs(zmarg) <= 5 ?
        pass("Markov marginal STILL fair: z = $(round(zmarg, digits=2))σ (n=$(length(me))) — stationarity IS detailed balance in 2 states") :
        fail("P5: Markov marginal convicted (z=$zmarg) — detailed-balance prediction wrong")
    zser = zscore(count(me[i+1] == me[i] for i in 1:length(me)-1), length(me) - 1, 0.5)
    (zser < -5) ?
        pass("consecutive extracted bits ANTI-correlated as predicted: P(same) z = $(round(zser, digits=1))σ — fair is not the same as independent") :
        fail("P5: serial correlation not convicted in the predicted direction (z=$zser)")
    ziid = zscore(count(EXT[i+1] == EXT[i] for i in 1:length(EXT)-1), length(EXT) - 1, 0.5)
    abs(ziid) <= 5 ?
        pass("control: iid-source extracted bits show NO serial correlation (z = $(round(ziid, digits=2))σ)") :
        fail("P5: control failed — iid extraction serially correlated (z=$ziid)")
end

println()
println(exitcode == 0 ?
  "COIN CREDENTIALED — fairness is mul_comm, the fee is 1/(2p(1−p)), the cheat has a dial and it never reads 1/2, and a Markov source launders bias but smuggles memory. The flip itself: see FLIP.md and flip.jl." :
  "BUILD FAILED — do not flip this coin.")
exit(exitcode)
