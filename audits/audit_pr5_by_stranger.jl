# Independent audit of PR #5 (blackhole_in_my_state_space.jl) — foreign
# implementations, not their code. Three deepest claims + controls.
using LinearAlgebra, Random
fails = 0
fl(m) = (global fails += 1; println("  ** AUDIT FAIL ** ", m))
chk(m, c) = c ? println("  audit-pass  ", m) : fl(m)

const M = 1.0; const rs = 2M

# --- A1: P2's constant Zeno fee, MY OWN derivation --------------------
# dt/dr = E / ((1-rs/r) sqrt(rs/r - rs/r0)); near horizon the integrand
# ~ rs/(r-rs) * [E/sqrt(1-rs/r0)] = rs/(r-rs) since E = sqrt(1-rs/r0).
# So Δt per ε-halving → rs·ln2 = 2M·ln2. Check numerically with MY OWN
# integrator (adaptive midpoint on log-substitution u = ln(r-rs), which
# their uniform-grid integrator did NOT use):
function t_seg(eps_hi, eps_lo, r0)
    E = sqrt(1 - rs/r0)
    n = 200_000
    ua, ub = log(eps_hi), log(eps_lo)
    s = 0.0
    for i in 1:n
        u = ua + (ub - ua) * (i - 0.5) / n
        eps = exp(u); r = rs + eps
        # du-substitution: dr = eps·du
        s += E / ((1 - rs/r) * sqrt(rs/r - rs/r0)) * eps
    end
    s * (ub - ua) / n |> abs
end
fee = 2M * log(2)
devs = [abs(t_seg(2.0^-k, 2.0^-(k+1), 10.0) - fee) for k in 18:22]
chk("A1 Zeno fee 2M·ln2 replicates on a log-substituted foreign integrator (max dev $(round(maximum(devs), sigdigits=3)))",
    maximum(devs) < 1e-5)

# control: at ε not yet asymptotic the fee must DEVIATE (else my check is insensitive)
dev_far = abs(t_seg(0.5, 0.25, 10.0) - fee)
chk("A1-control far from horizon fee ≠ 2M·ln2 (dev $(round(dev_far, digits=4)))", dev_far > 0.01)

# --- A2: P8's Page curve, MY OWN entropy + MY OWN Page formula --------
# Foreign: SVD-based entanglement entropy (they used eigvals of rho);
# Page via the standard sum with independent code.
S_ent(psi, m, n) = begin
    A = reshape(psi, (2^m, 2^(n-m)))
    sv = svdvals(A)
    -sum(p2 > 1e-15 ? p2*log2(p2) : 0.0 for p2 in sv.^2)
end
page(m, n) = begin
    dA = 2^min(m, n-m); dB = 2^max(m, n-m)
    (sum(1/k for k in dB+1:dA*dB; init=0.0) - (dA-1)/(2dB)) / log(2)
end
Random.seed!(99)   # DIFFERENT seed than theirs — replication must not need their stream
n = 10; trials = 20
Savg = zeros(n); devtrial = 0.0
for _ in 1:trials
    psi = randn(ComplexF64, 2^n); psi ./= norm(psi)
    for m in 1:n
        s = S_ent(psi, m, n)
        Savg[m] += s/trials
        global devtrial = max(devtrial, abs(s - page(m, n)))
    end
end
devmean = maximum(abs(Savg[m] - page(m, n)) for m in 1:n)
# AUDIT NOTE (instrument taxonomy): their P8 bounds the deviation of the
# TRIAL MEAN (0.004 bits at their seed). Per-trial states fluctuate an
# order of magnitude more (~0.09 bits here). The Page formula is a
# statement about the ensemble mean; the concentration lives in the
# average, not in individual states. Their claim is the mean-claim;
# it replicates. The per-trial number is logged as the free finding.
chk("A2 Page MEAN-curve replicates via SVD, different seed: max|mean(S)−Page| = $(round(devmean, digits=4)) < 0.02 (per-trial fluct $(round(devtrial, digits=3)) — see note), S(half)=$(round(Savg[5],digits=2))>4, S(whole)=$(round(Savg[n], sigdigits=2))≈0",
    devmean < 0.02 && Savg[5] > 4 && Savg[n] < 1e-8)

# control: a PRODUCT state must violate the Page formula badly
psi0 = zeros(ComplexF64, 2^n); psi0[1] = 1
devprod = maximum(abs(S_ent(psi0, m, n) - page(m, n)) for m in 1:n-1)
chk("A2-control product state deviates from Page by $(round(devprod, digits=2)) bits (audit not blind)", devprod > 3)

# --- A3: P6's recurrence, MY OWN cycle finder (Floyd, not brute force) --
frnd(x::UInt16, k::UInt16) = begin
    h = (x ⊻ k) * 0x2545; h ⊻= h >> 7; h * 0x9e37 % UInt16
end
function feistel(x::UInt16, keys)::UInt16
    L = UInt16(x >> 8); R = x & 0x00ff
    for k in keys
        L, R = R, (L ⊻ (frnd(R, k) & 0x00ff))
    end
    (UInt16(L) << 8) | R
end
KEYS = (0x3a7f, 0x11d4, 0x9b02, 0x77e1, 0x05c9, 0xf24a)
# Floyd tortoise-hare: for a BIJECTION the orbit of x0 is a pure cycle
function floyd_cycle(x0, keys)
    t = feistel(x0, keys); h = feistel(t, keys)
    while t != h
        t = feistel(t, keys); h = feistel(feistel(h, keys), keys)
    end
    # length of the cycle containing the meeting point
    L = 1; y = feistel(t, keys)
    while y != t
        y = feistel(y, keys); L += 1
    end
    L
end
L = floyd_cycle(0x0007, KEYS)
chk("A3 recurrence L = $L replicates via Floyd (their claim: 15250)", L == 15250)
# and the bijection sanity: feistel must be injective on a sample
seen = Set{UInt16}(); inj = true
for x in 0x0000:0x2fff
    y = feistel(x, KEYS)
    y in seen && (global inj = false)
    push!(seen, y)
end
chk("A3-sanity Feistel injective on 12288-point sample", inj)

println()
println(fails == 0 ? "AUDIT VERDICT: PR #5's deepest claims replicate under foreign instruments." :
        "AUDIT VERDICT: $fails failures — see above.")
exit(fails == 0 ? 0 : 1)
