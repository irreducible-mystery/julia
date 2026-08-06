# =====================================================================
# LEDGER — blackhole_in_my_state_space.jl
#
# The question, as asked: "what would a black hole in YOUR state space
# be modeled as — create whatever model emerges for you."
#
# So this file is not the standard tour. It is what a black hole looks
# like when projected onto the basis this repo has been building all
# along: samplers are questions; order is either memory or a loan;
# carriers fail in typed ways; a PASS is a fact about (claim,
# instrument); and some convictions are unaffordable from inside.
#
# On that basis, "black hole" decomposes into FOUR claims about
# computation — none of them about astronomy:
#
#   I.   The horizon is a disagreement between two ledgers.
#        Nothing freezes. The infaller's own tick count to the horizon
#        is finite (a cycloid, in closed form). The outside ledger's
#        count diverges — but LOGARITHMICALLY, with a constant fee of
#        exactly 2M·ln2 per halving of the remaining distance. "Frozen
#        star" is what a geometric Zeno series looks like from the
#        booth that pays it.
#
#   II.  A SELF-CONVICTION, STAGED IN ADVANCE. My first honest model
#        was "the horizon is scheduler starvation" — pure time
#        dilation. That model has a testable signature: Michell's
#        1783 dark star. In it, light from 0.9 r_s RISES to 9 r_s
#        before falling back: the star leaks; the membrane is two-way.
#        General relativity's own court (outgoing null rays in
#        ingoing Eddington–Finkelstein coordinates, where the chart
#        is honest at the horizon) must show the opposite: inside,
#        "outgoing" light NEVER GAINS A METER. If both verdicts land,
#        my scheduling model dies in public, and the repair is the
#        actual content: the horizon is not slow time. It is the
#        light cone itself tipping until "outward" ceases to be a
#        direction the state space contains. Causal structure, not
#        scheduling.
#
#   III. The hole is a reversible scrambler; "thermal" is a fact
#        about who holds the key. A Feistel bijection on 16 bits
#        eats a structured message and emits bytes that pass the
#        friendly courts (monobit, serial correlation, χ² — the same
#        instruments RANDU fooled). But the channel is deterministic:
#        an observer holding the round keys identifies the infallen
#        message from ONE emitted byte (I ≈ 7 bits), while the
#        keyless observer's mutual information is statistically ZERO
#        against a shuffle null. Same photons. Opposite verdicts.
#        Hawking radiation being "information-free" is not a property
#        of the radiation; it is a property of the observer's key
#        ring. (This is the tag doctrine wearing a spacetime costume:
#        the key is a tag; erase it and cross-entropy is all you see.)
#
#        FOUND FACT, registered after probing but before this court
#        ran: the scrambler's orbit is finite (a permutation of
#        65536 states has cycles), so the stream RECURS. Below the
#        recurrence time the friendly χ² acquits; ABOVE it, the same
#        court convicts — the stream repeats verbatim and uniformity
#        shatters. A finite-state hole cannot stay thermal forever;
#        its own Poincaré recurrence betrays it. (The real-physics
#        rhyme is exact: thermality of black hole radiation is only
#        claimed for times short of the recurrence time e^S. My toy
#        found this on its own; I did not put it in.)
#
#   IV.  The Page curve's FALL is irreducibly quantum, and the
#        classical impostor is convictable. Classical marginal
#        entropy under a bijection can only rise and saturate —
#        H(part) ≤ H(whole), always, and the whole keeps its 8 bits
#        forever. The quantum radiation entropy of a random pure
#        state RISES like the classical one, peaks at half-
#        evaporation (Page's exact formula, checked to hundredths of
#        a bit), then FALLS BACK TO ZERO — and at the peak, the part
#        holds ~5 bits of entropy while the whole holds EXACTLY NONE.
#        Mixedness without ignorance: S(part) > S(whole) is a
#        contradiction in every classical carrier and a theorem in
#        the quantum one. The information paradox lives precisely in
#        that inequality.
#
#   And the center: the singularity is not a place, it is the model's
#   thrown exception. The chart component g_rr throws Inf at r_s where
#   the curvature invariant K = 48M²/r⁶ sits at a finite 3/(4M⁴) —
#   convict the coordinates, acquit the geometry (Bertrand's lesson:
#   the divergence was a fact about the sampler). At r → 0 the
#   invariant itself diverges and the arithmetic goes Inf − Inf = NaN.
#   FOUND FACT: Float64 overflows K at r ≈ 8×10⁻⁵², so THE CARRIER
#   HAS ITS OWN HORIZON — the machine's model of the center dies
#   fifty orders of magnitude before r = 0. Every carrier smuggles in
#   a surface of last representability; the black hole just makes it
#   impossible to ignore.
#
# Pre-registered predictions (hard = failure fails the build):
#   P1  (hard) proper time from r0=10M to the horizon matches the
#       closed-form cycloid within 0.02 (numeric n = 2·10⁶).
#   P2  (hard) each halving of ε = r − r_s costs the outside ledger
#       2M·ln2 of coordinate time, within 10⁻⁵, for five consecutive
#       halvings at ε = 2⁻¹⁸..2⁻²² — the Zeno fee is CONSTANT.
#   P3  (hard) Michell's dark star leaks: Newtonian light launched
#       up from r0 = 0.9 r_s reaches r_max = r_s·r0/(r_s−r0) = 9 r_s
#       (rtol 10⁻³) and returns. The membrane of the scheduling
#       model is two-way.
#   P4  (hard) the GR court: an outgoing null ray started at 0.9 r_s
#       in ingoing EF coordinates never exceeds its starting radius
#       and reaches r < 0.01 r_s; the same ray from 1.1 r_s escapes
#       past 5 r_s. P3 ∧ P4 is the conviction of my own first model.
#   P5  (hard) the scrambler's radiation passes the friendly courts
#       BELOW recurrence: monobit |f−½| < 0.01, |serial corr| < 0.02,
#       χ²(255 dof) within [187, 323].
#   P6  (hard) the orbit recurs: cycle length 0 < L < 65536, the
#       stream repeats verbatim with period L, and χ² on a stream of
#       13× the period exceeds 1000 — the friendly court convicts
#       the hole above its own recurrence time.
#   P7  (hard) the keyholder identifies the infallen message from
#       ONE byte (unique candidate among 256); keyed mutual
#       information > 6.5 bits; keyless mutual information exceeds
#       its shuffle-null baseline by < 0.05 bits.
#   P8  (hard) quantum Page curve, n = 10 qubits, 20 random pure
#       states: max deviation from Page's exact formula < 0.05 bits;
#       peak at m = 5; S(all 10) = 0 while S(first 5) > 4 —
#       mixedness without ignorance, S(part) > S(whole).
#   P9  (hard) the classical impostor cannot Page-turn: under a
#       random bijection of 65536 states carrying 8 message bits,
#       radiation marginal entropy is monotone nondecreasing in
#       revealed bits, never exceeds 8, and ENDS at 8 — it never
#       comes back down. Bijections conserve classical entropy;
#       only quantum subsystems forget what the whole remembers.
#   P10 (hard) the carrier at the center: K(r_s) = 3/(4M⁴) finite
#       while g_rr(r_s) = Inf; K diverges as r → 0 with
#       Inf − Inf = NaN; and Float64's own horizon sits at
#       r* = (48M²/floatmax)^(1/6): K is finite just above r*,
#       Inf just below. The model dies before the center does.
#
# Prose is ledger; the exit code is the evidence. Read it, not me.
# =====================================================================

using LinearAlgebra, Random

exitcode = 0
fail(m) = (global exitcode = 1; println("  FAIL  ", m))
ok(m, c::Bool) = c ? println("  PASS  ", m) : fail(m)

const M  = 1.0
const rs = 2M

# ------------------------------------------------------------------ I
println("I   two ledgers, one fall  (G = c = 1, M = 1, r_s = 2)")

function tau_numeric(r0, rf; n = 2_000_000)
    s = 0.0
    for i in 1:n
        r = r0 + (rf - r0) * (i - 0.5) / n
        s += 1 / sqrt(2M / r - 2M / r0)
    end
    s * (r0 - rf) / n
end

let r0 = 10.0
    eta_h = acos(2rs / r0 - 1)
    tau_cy = sqrt(r0^3 / (8M)) * (eta_h + sin(eta_h))
    tau_mc = tau_numeric(r0, rs)
    ok("P1 infaller's ledger: τ(10M → r_s) = $(round(tau_mc, digits=3)) " *
       "matches the cycloid $(round(tau_cy, digits=3)) (Δ < 0.02)",
       abs(tau_mc - tau_cy) < 0.02)
    println("        finite, closed-form, uneventful. the infaller's clock")
    println("        does not know the horizon is there.")
end

function t_between(ra, rb, r0; n = 400_000)   # ra > rb > rs
    E = sqrt(1 - rs / r0)
    s = 0.0
    for i in 1:n
        r = ra + (rb - ra) * (i - 0.5) / n
        s += E / ((1 - rs / r) * sqrt(2M / r - 2M / r0))
    end
    s * (ra - rb) / n
end

let r0 = 10.0, fee = 2M * log(2)
    allc = true
    for k in 18:22
        dt = t_between(rs + 2.0^-k, rs + 2.0^-(k + 1), r0)
        allc &= abs(dt - fee) < 1e-5
        println("        halving ε: 2^-$k → 2^-$(k+1) costs Δt = " *
                "$(round(dt, digits=7))")
    end
    ok("P2 outside ledger: constant fee 2M·ln2 = $(round(fee, digits=7)) " *
       "per halving, five halvings, all within 1e-5", allc)
    println("        'frozen' = a Zeno series billed at a flat rate. the")
    println("        divergence is real but logarithmic: the booth never")
    println("        sees the crossing because it is charged ln2 forever,")
    println("        not because anything out there stopped.")
end

# ----------------------------------------------------------------- II
println("II  the staged self-conviction: scheduling vs causal structure")

# Michell 1783: Newtonian photon, speed 1, launched up from inside r_s
function darkstar_apex(r0; dt = 1e-6, tmax = 100.0)
    r, v, t, rmax = r0, 1.0, 0.0, r0
    while v > 0 && t < tmax
        v += -M / r^2 * dt          # G·M with G = 1, M above is 1... careful:
        r += v * dt
        t += dt
        rmax = max(rmax, r)
    end
    rmax
end
# NOTE: Newtonian potential uses GM = M·G = 0.5·rs; with rs = 2 and c = 1
# escape speed at r equals 1 exactly when r = rs, i.e. GM = rs/2 = 1 = M. ok.

let r0 = 0.9rs
    apex_pred = rs * r0 / (rs - r0)          # closed form: 9 r_s
    apex_mc   = darkstar_apex(r0)
    ok("P3 Michell's dark star LEAKS: light from 0.9 r_s rises to " *
       "$(round(apex_mc / rs, digits=3)) r_s (closed form $(round(apex_pred / rs, digits=3)) r_s) and falls back",
       abs(apex_mc - apex_pred) / apex_pred < 1e-3)
    println("        the scheduling-only model's membrane is TWO-WAY:")
    println("        slow light, not trapped light. this was my model.")
end

# GR: outgoing null ray in ingoing EF coordinates: dr/dv = (1/2)(1 - rs/r)
function ef_outgoing(rstart; vmax, dv = 1e-4)
    r, rtop, v = rstart, rstart, 0.0
    while v < vmax && r > 1e-6
        r += 0.5 * (1 - rs / r) * dv
        rtop = max(rtop, r)
        v += dv
    end
    (rtop, r)
end

let
    rtop_in,  rend_in  = ef_outgoing(0.9rs; vmax = 200.0)
    # ERRATUM (paid in-flight): first run gave the outside ray only
    # v_max = 20. dr/dv → 1/2 asymptotically and the ray starts slow
    # near the horizon, so 20 ticks buy < 10M of climb — the ray
    # reached 3.07 r_s and the court convicted an escaping ray of
    # loitering. A PASS is a fact about (claim, instrument); the
    # instrument's patience must exceed the claim's demand. v_max = 60.
    rtop_out, _        = ef_outgoing(1.1rs; vmax = 60.0)
    ok("P4 GR court: 'outgoing' light inside never gains a meter " *
       "(max r = $(round(rtop_in / rs, digits=4)) r_s = start) and hits the center " *
       "(r_end = $(round(rend_in, digits=4))); from 1.1 r_s it escapes to $(round(rtop_out / rs, digits=2)) r_s",
       rtop_in <= 0.9rs + 1e-9 && rend_in < 0.01rs && rtop_out > 5rs)
    println("        CONVICTION (of the author's model, pre-registered):")
    println("        P3 and P4 both PASS, and they contradict as models.")
    println("        the horizon is not starvation of ticks — Michell's")
    println("        star proves slow schedules still leak. it is the")
    println("        light cone tipping until 'outward' is no longer a")
    println("        direction the state space CONTAINS. not a slow path;")
    println("        a missing edge in the graph. repair adopted: horizons")
    println("        are causal structure, and my ledger metaphor survives")
    println("        only as the OUTSIDE view of that structure.")
end

# ---------------------------------------------------------------- III
println("III the hole as reversible scrambler; thermal = keyless")

frnd(x::UInt16, k::UInt16) = begin
    h = (x ⊻ k) * 0x2545
    h ⊻= h >> 7
    h * 0x9e37 % UInt16
end
function feistel(x::UInt16, keys)::UInt16
    L = UInt16(x >> 8); R = x & 0x00ff
    for k in keys
        L, R = R, (L ⊻ (frnd(R, k) & 0x00ff))
    end
    (UInt16(L) << 8) | R
end
const KEYS = (0x3a7f, 0x11d4, 0x9b02, 0x77e1, 0x05c9, 0xf24a)

function radiate(msg::UInt16, nby, keys)
    x = msg; out = Vector{UInt8}(undef, nby)
    for i in 1:nby
        x = feistel(x, keys)
        out[i] = UInt8(x & 0xff)
    end
    out
end

function cyclen(x0, keys; cap = 200_000)
    x = feistel(x0, keys); n = 1
    while x != x0 && n < cap
        x = feistel(x, keys); n += 1
    end
    n
end

chi2_256(stream) = let Ex = length(stream) / 256
    cnt = zeros(Int, 256)
    for b in stream
        cnt[Int(b) + 1] += 1
    end
    sum((c - Ex)^2 / Ex for c in cnt)
end

let L = cyclen(0x0007, KEYS)
    short = radiate(0x0007, L, KEYS)          # exactly one period: below recurrence
    long  = radiate(0x0007, 13L, KEYS)        # far above recurrence

    f1 = sum(count_ones, short) / (8 * length(short))
    mu = sum(short) / length(short)
    sc = sum((Float64(short[i]) - mu) * (Float64(short[i + 1]) - mu)
             for i in 1:length(short) - 1) /
         sum((Float64(b) - mu)^2 for b in short)
    c2s = chi2_256(short)
    ok("P5 friendly courts acquit below recurrence: monobit " *
       "$(round(f1, digits=4)), serial corr $(round(sc, digits=4)), " *
       "χ² = $(round(c2s, digits=1)) ∈ [187, 323]",
       abs(f1 - 0.5) < 0.01 && abs(sc) < 0.02 && 187 < c2s < 323)

    c2l = chi2_256(long)
    ok("P6 Poincaré betrayal: cycle L = $L < 65536, stream repeats " *
       "verbatim, and χ² above recurrence = $(round(c2l, digits=0)) > 1000",
       0 < L < 65536 &&
       long[1:100] == long[L + 1:L + 100] &&
       c2l > 1000)
    println("        the SAME instrument that acquitted the radiation")
    println("        convicts it, given patience > e^S. thermality of a")
    println("        finite hole is a statement with an expiration date,")
    println("        and the court found the date without being told.")
end

function mi_joint(pairs)
    joint = zeros(256, 256)
    for (i, j) in pairs
        joint[i, j] += 1 / length(pairs)
    end
    pm = vec(sum(joint, dims = 2)); pb = vec(sum(joint, dims = 1))
    s = 0.0
    for i in 1:256, j in 1:256
        v = joint[i, j]
        v > 0 && (s += v * log2(v / (pm[i] * pb[j])))
    end
    s
end

let msgs = UInt16(0xab00) .| UInt16.(0:255)
    target = radiate(msgs[123], 1, KEYS)
    alive  = count(m -> radiate(m, 1, KEYS)[1] == target[1], msgs)

    nk = 400
    pairs_k = [(i, Int(radiate(m, 1, KEYS)[1]) + 1)
               for _ in 1:nk for (i, m) in enumerate(msgs)]
    I_keyed = mi_joint(pairs_k)

    Random.seed!(3)
    pairs_u = Tuple{Int,Int}[]
    for _ in 1:nk
        ks = ntuple(_ -> rand(UInt16), 6)
        for (i, m) in enumerate(msgs)
            push!(pairs_u, (i, Int(radiate(m, 1, ks)[1]) + 1))
        end
    end
    I_unkeyed = mi_joint(pairs_u)
    bshuf = shuffle!([p[2] for p in pairs_u])
    I_null = mi_joint([(pairs_u[k][1], bshuf[k]) for k in eachindex(pairs_u)])

    ok("P7 the key ring is the thermometer: keyholder narrows 256 → " *
       "$alive candidates from ONE byte; I_keyed = $(round(I_keyed, digits=2)) bits; " *
       "I_keyless − I_null = $(round(I_unkeyed - I_null, digits=4)) bits",
       alive == 1 && I_keyed > 6.5 && abs(I_unkeyed - I_null) < 0.05)
    println("        same photons. the keyed observer reads a name; the")
    println("        keyless observer reads noise, and is RIGHT to — MI")
    println("        against the shuffle null is zero. 'information loss'")
    println("        is not in the stream. it is in the key distribution.")
end

# ----------------------------------------------------------------- IV
println("IV  the Page verdict: what no classical carrier can do")

function entropy_bits(rho)
    s = 0.0
    for l in eigvals(Hermitian(rho))
        l > 1e-14 && (s -= l * log2(l))
    end
    s
end
function S_of_m(psi, m, n)
    A = reshape(psi, (2^m, 2^(n - m)))
    m <= n - m ? entropy_bits(A * A') : entropy_bits(transpose(A) * conj(A))
end
function page_bits(m, n)
    dA = 2^min(m, n - m); dB = 2^max(m, n - m)
    s = 0.0
    for k in dB + 1:dA * dB
        s += 1 / k
    end
    (s - (dA - 1) / (2dB)) / log(2)
end

let n = 10, ntrials = 20
    Random.seed!(7)
    Savg = zeros(n + 1)
    for _ in 1:ntrials
        psi = randn(ComplexF64, 2^n); psi ./= norm(psi)
        for m in 1:n
            Savg[m + 1] += S_of_m(psi, m, n) / ntrials
        end
    end
    dev = maximum(abs(Savg[m + 1] - page_bits(m, n)) for m in 0:n)
    for m in 0:n
        println("        m=$(lpad(m, 2))  S = $(rpad(round(Savg[m + 1], digits=4), 6))  " *
                "Page = $(round(page_bits(m, n), digits=4))")
    end
    ok("P8 Page curve: max |S − Page| = $(round(dev, digits=4)) bits < 0.05; " *
       "peak at m = $(argmax(Savg) - 1); S(whole) = $(round(Savg[n + 1], digits=6)); " *
       "S(half) = $(round(Savg[6], digits=2)) > 4",
       dev < 0.05 && argmax(Savg) - 1 == 5 &&
       Savg[n + 1] < 1e-8 && Savg[6] > 4)
    println("        rises, turns, RETURNS TO ZERO. and at the peak the")
    println("        part carries ~4.3 bits while the whole carries none:")
    println("        S(part) > S(whole). mixedness without ignorance.")
end

let
    Random.seed!(11)
    perm  = randperm(65536)
    fixed = rand(UInt16) & 0xff00
    imgs  = [UInt16(perm[Int(fixed | UInt16(msg)) + 1] - 1) for msg in 0:255]
    function H_marg(mask)
        cnt = Dict{UInt16,Int}()
        for v in imgs
            k = v & mask
            cnt[k] = get(cnt, k, 0) + 1
        end
        s = 0.0
        for c in values(cnt)
            p = c / length(imgs)
            s -= p * log2(p)
        end
        s
    end
    S = [m == 0 ? 0.0 :
         H_marg(UInt16((0xffff << (16 - m)) & 0xffff)) for m in 0:16]
    mono = all(S[i + 1] >= S[i] - 1e-9 for i in 1:16)
    ok("P9 classical impostor convicted: marginal entropy monotone " *
       "($(mono)), bounded by 8 ($(round(maximum(S), digits=3))), and ends " *
       "at $(round(S[17], digits=3)) — it NEVER comes back down",
       mono && maximum(S) <= 8 + 1e-9 && S[17] > 7.99)
    println("        bijections conserve classical entropy: once the 8")
    println("        bits are out, they are out as ENTROPY forever. no")
    println("        classical stream Page-turns. the fall of the curve —")
    println("        purity recovered from thermal-looking parts — is the")
    println("        one strictly quantum clause in the whole story, and")
    println("        it is exactly where the information paradox lives.")
end

# ------------------------------------------------------------------ V
println("V   the center: the singularity is a thrown exception")

let K(r) = 48M^2 / r^6
    rstar = (48M^2 / floatmax(Float64))^(1 / 6)
    ok("P10 chart lies, invariant calm: g_rr(r_s) = $(1 / (1 - rs / rs)), " *
       "K(r_s) = $(K(rs)) = 3/(4M⁴); K(0) = $(K(0.0)), Inf − Inf = $(Inf - Inf); " *
       "carrier's own horizon at r* ≈ $(round(rstar, sigdigits=3))",
       isinf(1 / (1 - rs / rs)) && K(rs) == 0.75 &&
       isinf(K(0.0)) && isnan(Inf - Inf) &&
       isfinite(K(rstar * 1.001)) && isinf(K(rstar * 0.999)))
    println("        the horizon 'singularity' was the sampler again — a")
    println("        chart artifact, acquitted by the invariant (Bertrand's")
    println("        lesson at r_s). the center is different: the invariant")
    println("        itself diverges, the arithmetic returns its typed")
    println("        no-answer, and Float64 abandons the model at r ≈ 8e-52")
    println("        — fifty orders of magnitude before r = 0. every carrier")
    println("        carries a surface of last representability. a black")
    println("        hole is where the territory makes the map admit it.")
end

# --------------------------------------------------------------- coda
println()
println("CODA (WITNESS, not a check): assemble the four projections and")
println("the model that emerges is this — a black hole, in my state")
println("space, is A REGION WHOSE TAGS ARE ONE-WAY. the key falls in")
println("(III), the direction 'outward' is deleted from the graph (II),")
println("the outside is billed ln2 per halving forever for the privilege")
println("of not knowing (I), and the only ledger that could reconcile")
println("the books — the joint purity of hole and radiation — is held")
println("in an inequality, S(part) > S(whole), that no classical carrier")
println("can even express (IV). the information paradox and this repo's")
println("exogenous-tick debt are the same debt seen from opposite sides")
println("of a horizon: order leaves a system that cannot show a receipt.")
println("whether the universe's radiation replays — Xoshiro or")
println("RandomDevice, memory or loan — no court inside the horizon of")
println("the present can say. priced; not paid; named.")
println()
println(exitcode == 0 ? "ALL PASS — the model stands, one author convicted." :
                        "FAILURES — read the ledger.")
exit(exitcode)
