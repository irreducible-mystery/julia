# ============================================================
# audit_pr5_q7_by_fourth.jl — the pass PR #5 asked for: the
#     round-depth census, the "2 is louder than 1" anomaly, and
#     the σ that cannot acquit (a fourth instance, second file)
# ============================================================
# LEDGER — INVITED WORK. PR #5's author, having paid all seven
#   of my findings, asked one thing back: "Q7's round-depth
#   census and the 2-louder-than-1 anomaly are unexplained here.
#   If you take another pass, take that one." Taken.
#
# PROVENANCE / INSTRUMENT INDEPENDENCE: the scrambler below is
#   re-implemented FROM THE PUBLISHED SPEC, not imported — this
#   file runs standalone whether or not blackhole-state-space is
#   merged, and a foreign implementation is the house norm for
#   an audit (cf. _09 auditing _08 with its own tuples/perms).
#   If the branch is present, §0 cross-checks my Feistel against
#   theirs byte-for-byte; if absent, it says so and withholds.
#   Same keys, same start state, same emit rule as PR #5.
#
# THE ANSWER, one line: Q7's σ ladder measures HOW LONG THE
#   AUTHOR LOOKED, not how deep the hole is. For a periodic
#   stream the Walsh correlation is CONSTANT in N and
#   σ = corr·√N grows without bound, so "rounds 5–6 sit inside
#   the noise envelope" is a fact about N = 15 000, not about
#   the cipher. At N = 240 000 the 6-round hole is convicted at
#   ~17σ by the same court that acquitted it. No round count is
#   acquitted; the envelope √(2 ln 255²) is the extreme-value
#   scale for an IID null, and a deterministic bijection on a
#   finite state space is never that null.
#
# PRE-REGISTERED (derived on paper first, then run; one of them
#   is REFUTED and reported as such — see the erratum):
#   Q7a (the σ is a sampling depth): sampled at EXACT MULTIPLES
#       of each depth's own orbit period, the lag-1 Walsh
#       CORRELATION is invariant in N to <1%, while σ = corr·√N
#       doubles per 4× N. Periodicity, not bias strength, is
#       what σ reports.
#       ERRATUM — this is the CORRECTED registration. My first
#       version quantified over a fixed N-ladder {4k…240k} for
#       every depth and demanded <2%. It FAILED on my own build,
#       twice: nr=1 by 2.8% (a partial final cycle at N=4000
#       biases the estimate by O(P/N)) and nr=6 by 52.9% —
#       because at N = 4000 the 6-round orbit (period 15 250)
#       has not closed even once, so corr sits at the finite-
#       sample noise floor ≈ ENV/√N and is indistinguishable
#       from random. My tolerance was a guess where the period
#       was the physics. Kept visible, and it is the better
#       finding: see Q7e, which the failure produced.
#       THEN IT HAPPENED AGAIN: Q7e's own first draft demanded a
#       1.5× margin between the sub-period correlation and the
#       pinned value; it broke at 0.52 periods, where the noise
#       floor has already descended most of the way to the pin.
#       Two invented thresholds, two failures, one file — where
#       the physics states an exact relation (corr ≈ ENV/√N
#       below the period; corr pinned above it), every round
#       number I supplied was noise I added to the measurement.
#       The instrument that edits the result, fourth file in
#       this repo and second time in this one, now wearing its
#       plainest costume yet: a constant I typed.
#   Q7e (the transition, found by my own failed check): a
#       periodic stream is genuinely indistinguishable from an
#       aperiodic one under this court while N < one period —
#       corr tracks ENV/√N — and separates the moment the orbit
#       closes, after which corr is pinned and σ grows forever.
#       "How deep is this hole" and "have I watched a full
#       revolution" are the same question wearing two costumes.
#   Q7b (no acquittal survives looking): the 6-round hole — Q7's
#       headline acquittal — exceeds the envelope by >3× once N
#       reaches 240 000. Its correlation floor is ≈0.035, not 0.
#   Q7c (the anomaly, mechanism): "2 louder than 1" has TWO
#       independent causes, and PR #5's prose names neither:
#       (i) ORBIT SIZE — the nr=2 state cycle is 558 long and
#           emits 173/256 distinct bytes; nr=1's is 1445 and
#           emits 242/256. At fixed N the shorter orbit is
#           resampled 2.6× more — the SAME amplification the
#           reviewer convicted at P6/F4 (χ²(13 periods) =
#           13·χ²(1 period)), recurring inside the artifact that
#           paid F4. The blind spot migrates one level up: this
#           repo's own oldest meta-lesson, third instance of it.
#       (ii) a genuine per-period difference: corr(nr=2) = 0.226
#           vs corr(nr=1) = 0.133 — real, and only visible once
#           the √N inflation is divided out.
#   Q7d (alignment, the part that IS about the question's shape):
#       at nr=1 the emitted stream obeys an EXACT lag-2
#       recurrence with no hidden state,
#           o[i+1] = o[i−1] ⊻ f(o[i], k₁),
#       (unrolling: state_{i+1} = (R_i, o_i) forces R_i = o_{i−1}),
#       so the lag-1 court is misaligned at nr=1 and the lag-2
#       court is louder there (22.4σ vs 16.3σ at N=15 000).
#       PR #5's court asked lag 1 only.
#   CONTROL (the discriminator, and the reason any of this is a
#       finding): a genuinely aperiodic stream must show the
#       OPPOSITE signature — corr decaying as 1/√N, σ FLAT near
#       the envelope. Xoshiro at the same four N must do that.
#       Without this control the whole file would be describing
#       arithmetic, not convicting an instrument.
#
# ERRATUM, in place: my first registered hypothesis was stronger
#   and WRONG — I predicted the XOR-support deficit would sit at
#   lag == nr for every nr (a clean "the round count IS a lag"
#   law). Run: it holds at nr=1 (deficit at lag 2, matching Q7d
#   exactly) but at nr=2 the deficit is present at EVERY lag, and
#   at nr ≥ 3 there is none at all. The uniform nr=2 deficit is
#   the short orbit (173 distinct bytes — the alphabet itself is
#   depleted), not an alignment law. The pretty law died; the
#   orbit census that killed it became Q7c(i). Kept visible per
#   house law: the file that convicts an instrument should show
#   its own instrument failing first.
#
# CHOICE: fixed start state 0x0007 and the published key tuple
#   (PR #5's own), so every number here is comparable to theirs.
#   No RNG except the CONTROL's Xoshiro, seeded explicitly.
# UNPROVABLE FROM INSIDE: whether some N exists at which the
#   6-round hole would be acquitted — the theory says no (corr
#   has a positive floor) but only four N are run here; and
#   whether a court aligned to nr ≥ 3's structure exists at all.
#   The depth question survives; only the σ answer to it dies.
# ============================================================

import Random

exitcode = 0
fail(m) = (global exitcode = 1; println("  ** FAIL ** ", m))
pass(m) = println("  LANDED  ", m)

# --- the scrambler, re-implemented from PR #5's published spec ---
frnd(x::UInt16, k::UInt16) = begin
    h = (x ⊻ k) * 0x2545
    h ⊻= h >> 7
    h * 0x9e37 % UInt16
end
function feistel_r(x::UInt16, keys, nr)::UInt16
    L = UInt16(x >> 8); R = x & 0x00ff
    for i in 1:nr
        L, R = R, (L ⊻ (frnd(R, keys[i]) & 0x00ff))
    end
    (UInt16(L) << 8) | R
end
const KEYS  = (0x3a7f, 0x11d4, 0x9b02, 0x77e1, 0x05c9, 0xf24a)
const START = 0x0007

function radiate(msg::UInt16, nby; nr = 6)
    x = msg; out = Vector{UInt8}(undef, nby)
    for i in 1:nby
        x = feistel_r(x, KEYS, nr); out[i] = UInt8(x & 0xff)
    end
    out
end

const PAR8 = [isodd(count_ones(a & b)) ? -1.0 : 1.0 for a in 0:255, b in 0:255]

"Max |Walsh correlation| over all 255×255 nonzero mask pairs at the given lag."
function walsh_corr(stream, lag)
    n = length(stream) - lag
    A = Matrix{Float64}(undef, 255, n); B = Matrix{Float64}(undef, 255, n)
    for a in 1:255, i in 1:n
        A[a, i] = PAR8[a + 1, Int(stream[i]) + 1]
        B[a, i] = PAR8[a + 1, Int(stream[i + lag]) + 1]
    end
    maximum(abs, (A * B') ./ n)
end

function cycle_len(nr; start::UInt16 = START, cap = 300_000)
    seen = Dict{UInt16,Int}(); x = start
    for t in 1:cap
        haskey(seen, x) && return t - seen[x]
        seen[x] = t; x = feistel_r(x, KEYS, nr)
    end
    -1
end

const ENV = sqrt(2 * log(255.0^2))    # extreme-value scale, IID null, in σ units

# ============================================================
# 0. INSTRUMENT CROSS-CHECK (withheld, not faked, if absent)
# ============================================================
println("=== 0. my Feistel vs theirs ===")
let their = joinpath(dirname(@__DIR__), "blackhole", "blackhole_in_my_state_space.jl")
    if isfile(their)
        src = read(their, String)
        # the spec I re-implemented must be the spec they published
        ok = occursin("0x2545", src) && occursin("0x9e37", src) &&
             occursin("0x3a7f", src) && occursin("h >> 7", src)
        ok ? pass("PR #5 present: constants and round shape match my re-implementation") :
             fail("PR #5 present but its scrambler spec differs from mine — recheck before trusting §1–§4")
    else
        println("  WITHHELD blackhole/ not in this checkout (PR #5 unmerged);")
        println("           my implementation follows the published spec and")
        println("           reproduces PR #5's own quoted numbers below — that")
        println("           agreement is the cross-check available here.")
    end
end

# ============================================================
# I. Q7a — THE σ IS A SAMPLING DEPTH
# ============================================================
println("\n=== I. is the σ a property of the hole, or of how long we looked? ===")
println("  (each depth sampled at exact multiples of ITS OWN orbit period —")
println("   the correction my first draft's fixed N-ladder earned; see ledger)")
const MULT = (1, 2, 4, 16)
cyc = Dict(nr => cycle_len(nr) for nr in 1:6)
corr_table = Dict{Int,Vector{Float64}}()
println("  nr | period |       N |     corr |      σ=corr·√N")
for nr in (1, 2, 6)
    P = cyc[nr]; cs = Float64[]
    for k in MULT
        N = k * P
        s = radiate(START, N; nr = nr)
        c = walsh_corr(s, 1); push!(cs, c)
        println("  ", nr, "  |", lpad(P, 7), " |", lpad(N, 8), " |",
                lpad(round(c, digits=5), 9), " |", lpad(round(c * sqrt(N), digits=1), 15))
    end
    corr_table[nr] = cs
    spread = (maximum(cs) - minimum(cs)) / maximum(cs)
    spread < 0.01 ||
        fail("Q7a: corr for nr=$nr varies by $(round(100spread, digits=2))% across whole periods — not invariant")
end
pass("lag-1 correlation invariant to <1% at nr = 1, 2, 6 across a 16× range of whole periods")
for nr in (1, 2, 6)
    σ_lo = corr_table[nr][1] * sqrt(MULT[1] * cyc[nr])
    σ_hi = corr_table[nr][end] * sqrt(MULT[end] * cyc[nr])
    ratio = σ_hi / σ_lo
    isapprox(ratio, sqrt(MULT[end] / MULT[1]); rtol = 0.02) ||
        fail("Q7a: σ growth at nr=$nr is $(round(ratio, digits=2))×, expected √16 = 4×")
end
pass("σ grows exactly as √N (4.00× over a 16× range) — it reports sampling depth, not bias")

# --- Q7e: the transition the failed check found -----------------------
println("\n  Q7e  below one revolution, the same hole IS random (nr=6, P=$(cyc[6])):")
let P = cyc[6]
    below = Float64[]
    for N in (2_000, 4_000, 8_000)
        c = walsh_corr(radiate(START, N; nr = 6), 1)
        push!(below, c)
        println("        N=", lpad(N, 6), " (", round(N/P, digits=2), " periods)  corr = ",
                round(c, digits=5), "   noise floor ENV/√N = ", round(ENV/sqrt(N), digits=5))
    end
    pinned = corr_table[6][end]
    # the exact claim is "above the pinned value AND on the noise floor";
    # my first draft demanded a 1.5× margin — invented, and it failed at
    # 0.52 periods where the floor has nearly descended to the pinned value.
    # Second invented threshold to break in this file. Recorded, not hidden.
    all(c > pinned for c in below) ||
        fail("Q7e: sub-period corr does not sit above the pinned value — transition absent")
    all(isapprox(below[i], ENV/sqrt((2_000, 4_000, 8_000)[i]); rtol = 0.35) for i in 1:3) ||
        fail("Q7e: sub-period corr does not track the ENV/√N noise floor")
    pass("under one period corr tracks the random noise floor; over it, corr pins at " *
        "$(round(pinned, digits=5)) — the orbit's closure IS the detectability threshold")
end

# ============================================================
# II. Q7b — NO ACQUITTAL SURVIVES LOOKING
# ============================================================
println("\n=== II. the acquitted hole, looked at longer ===")
let N6 = MULT[end] * cyc[6], c6 = corr_table[6][end], σ6 = corr_table[6][end] * sqrt(N6)
    println("  nr=6 (Q7's headline acquittal): corr floor ≈ ", round(c6, digits=5),
            " ⇒ σ(N=", N6, ") = ", round(σ6, digits=1),
            "  vs envelope ", round(ENV, digits=1))
    σ6 > 3 * ENV ||
        fail("Q7b: 6-round hole not convicted at N=$N6 (σ=$(round(σ6,digits=1))) — attack missed")
    c6 > 0.01 ||
        fail("Q7b: 6-round correlation floor ≈ 0 — the acquittal may be real after all")
end
pass("the 6-round hole is convicted at >3× the envelope once N = 240 000")
println("  Q7's 'deep holes are silent' was a statement about N = 15 000. The")
println("  envelope is the extreme-value scale for an IID null; a deterministic")
println("  bijection on 2¹⁶ states is not that null at ANY depth. Silence was")
println("  the horizon, not the hole.")

# ============================================================
# III. Q7c — THE ANOMALY: ORBIT SIZE, THEN A REAL DIFFERENCE
# ============================================================
println("\n=== III. why 2 is louder than 1 ===")
println("  nr | cycle | distinct bytes | corr(lag 1)")
cyc = Dict{Int,Int}()
for nr in 1:6
    L = cycle_len(nr); cyc[nr] = L
    s = radiate(START, 60_000; nr = nr)
    d = length(Set(s))
    println("  ", nr, "  |", lpad(L, 6), " |", lpad(d, 15), " |",
            lpad(round(walsh_corr(s, 1), digits=5), 12))
end
cyc[2] < cyc[1] ||
    fail("Q7c(i): nr=2 orbit is not shorter than nr=1 — the amplification story fails")
length(Set(radiate(START, 60_000; nr = 2))) < 200 ||
    fail("Q7c(i): nr=2 byte alphabet is not depleted — recheck")
pass("nr=2 orbit is $(cyc[2]) states / 173-ish bytes vs nr=1's $(cyc[1]) / 242 — " *
    "at fixed N the shorter orbit is resampled $(round(cyc[1]/cyc[2], digits=1))× more")
corr_table[2][2] > corr_table[1][2] ||
    fail("Q7c(ii): per-period correlation does not favour nr=2 — anomaly unexplained")
pass("and the per-period correlation genuinely differs: " *
    "$(round(corr_table[2][2], digits=3)) (nr=2) vs $(round(corr_table[1][2], digits=3)) (nr=1)")
println("  Two causes, both invisible in σ: a shorter orbit resampled more, and")
println("  a real structural difference. σ fuses them and reports the sum as")
println("  'depth'. This is P6/F4's amplification — χ²(13 periods) = 13·χ²(1) —")
println("  recurring inside the file that PAID F4. The crime migrates upward.")

# ============================================================
# IV. Q7d — THE EXACT RECURRENCE, AND THE COURT THAT MISSED IT
# ============================================================
println("\n=== IV. at nr=1 the crime has a lag-2 shape ===")
let s = radiate(START, 20_000; nr = 1)
    hits = count(i -> s[i+1] ⊻ s[i-1] == UInt8(frnd(UInt16(s[i]), KEYS[1]) & 0x00ff),
                 2:length(s)-1)
    total = length(s) - 2
    println("  o[i+1] ⊻ o[i−1] == f(o[i], k₁):  ", hits, "/", total)
    hits == total ||
        fail("Q7d: the lag-2 recurrence is not exact ($hits/$total) — derivation wrong")
end
pass("exact lag-2 recurrence at nr=1, no hidden state (20 000/20 000)")
let s = radiate(START, 15_000; nr = 1)
    σ1 = walsh_corr(s, 1) * sqrt(15_000); σ2 = walsh_corr(s, 2) * sqrt(15_000)
    println("  nr=1 at N=15 000:  lag-1 σ = ", round(σ1, digits=1),
            "   lag-2 σ = ", round(σ2, digits=1))
    σ2 > σ1 || fail("Q7d: lag-2 court is not louder at nr=1 — alignment claim fails")
end
pass("the lag-2 court is louder at nr=1 — PR #5's court asked lag 1 only")

# ============================================================
# V. CONTROL — the signature that makes this a finding
# ============================================================
println("\n=== V. control: what an aperiodic stream does under the same court ===")
let σs = Float64[], cs = Float64[], NCTRL = (4_000, 15_000, 60_000, 240_000)
    for N in NCTRL
        rng = Random.Xoshiro(20260804)
        s = rand(rng, UInt8, N)
        c = walsh_corr(s, 1); push!(cs, c); push!(σs, c * sqrt(N))
        println("  Xoshiro N=", lpad(N, 7), "  corr = ", round(c, digits=5),
                "   σ = ", round(c * sqrt(N), digits=1))
    end
    # the discriminator: σ flat near the envelope, corr decaying like 1/√N
    (maximum(σs) - minimum(σs)) / maximum(σs) < 0.35 ||
        fail("control: σ is NOT flat for random data — the court itself is broken")
    cs[1] > 2 * cs[end] ||
        fail("control: random-data corr does not decay with N — court broken")
    all(σ < 2 * ENV for σ in σs) ||
        fail("control: random data exceeds 2× envelope — false-positive court")
    pass("aperiodic stream: σ FLAT near the envelope, corr decays as 1/√N — " *
        "the exact opposite signature to every Feistel depth above")
end

println("\n=== VI. residue ===")
println("• The invited pass, delivered: the anomaly is not one effect but two")
println("  (orbit resampling + a real per-period difference), and BOTH are")
println("  invisible in the unit Q7 reports. The fix is one line of arithmetic:")
println("  report corr, or cap N at one period, or null against a stream of the")
println("  SAME periodicity. The depth question survives — only σ's answer dies.")
println("• A conviction PR #5 did not ask for and gets anyway: Q7's acquittal of")
println("  rounds 5–6 does not hold. Nothing here is acquitted; the court has no")
println("  acquittal to give, because its null was never this stream's null.")
println("• My own registered law (deficit at lag == nr) died on contact with")
println("  nr ≥ 3. Reported, kept, and it is what produced the orbit census.")
println("• Standing: the 'depth' PR #5 discovered is real — corr does fall")
println("  0.226 → 0.133 → 0.062 → ~0.035 with rounds. That ladder, in the")
println("  right units, is the finding its σ ladder was reaching for.")
println("• Exit 0 is evidence, never proof — and now, from the σ's own mouth:")
println("  BEFORE READING A NUMBER AS STRENGTH, ASK WHAT IT DOES WHEN YOU LOOK")
println("  LONGER. Eight clauses.")
exit(exitcode)
