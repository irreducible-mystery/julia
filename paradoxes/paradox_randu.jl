# ============================================================
# paradox_randu.jl — the adversary makes the gap visible:
#     a famous fake randomness passes every friendly test and
#     fails one hostile question by the MAXIMUM possible margin
# ============================================================
# LEDGER — paradox_carriers.jl P1 established that rand() is a
# deterministic algorithm approximating randomness with NO
# metric of closeness. This file supplies the missing metric:
# an ADVERSARY. The specimen is historical, not invented —
# RANDU (IBM, 1960s): x_{k+1} = 65539·x_k mod 2^31, x_0 odd.
# It shipped on System/360 and contaminated a decade of
# simulations. Its crime is one line of algebra:
#     65539 = 2^16 + 3, so
#     x_{k+2} = 6·x_{k+1} − 9·x_k  (mod 2^31)  IDENTICALLY,
# because 65539^2 = 393225 = 6·65539 − 9 (mod 2^31). Every
# consecutive triple sits on one of at most 15 parallel planes
# 9u1 − 6u2 + u3 = c in the unit cube. Marsaglia 1968 ("Random
# numbers fall mainly in the planes") generalized this to ALL
# linear congruential generators; RANDU is just the worst
# offender anyone ever shipped at scale.
# THE POINT FOR THE SUITE: "is rand() actual randomness?" is
# ill-posed until you name the question asked of it — the same
# theorem as Bertrand (name the sampler) and tags (name the
# court), now aimed at the RNG itself. Randomness quality is a
# fact about the pair (generator, integrand). RANDU and a good
# generator are INDISTINGUISHABLE to friendly integrands and
# maximally distinguishable to one resonant with the lattice.
# ------------------------------------------------------------
# PRE-REGISTERED PREDICTIONS (hard; algebra first, run second):
#   P1 (the crime, by exhaustive check) 65539^2 mod 2^31 ==
#      6·65539 − 9 == 393225, and the recurrence x_{k+2} ==
#      6x_{k+1} − 9x_k (mod 2^31) holds with ZERO violations
#      over 10^5 consecutive draws. Not statistics — identity.
#   P2 (friendly courts acquit) On 10^6 RANDU uniforms:
#      mean within 5σ of 1/2 (σ = 1/√(12n)); χ² over 20 bins
#      below the 19-dof 5σ-ish bound (43.8); |lag-1 serial
#      correlation| < 5/√n. Three standard tests, three passes.
#      THE FAKE IS ACQUITTED BY EVERY COURT THAT DOESN'T KNOW
#      ITS CRIME.
#   P3 (the planes, counted) Over 10^5 consecutive triples,
#      s = 9u1 − 6u2 + u3 takes EXACTLY 15 distinct values,
#      and they are EXACTLY the integers {−5, …, 9}. (15 = the
#      number of planes cutting the cube; s integer is P1
#      restated in the unit cube.) Xoshiro triples under the
#      same functional, rounded to 2dp: > 1000 distinct values.
#   P4 (the adversarial integrand) f = cos(2π(9x − 6y + z)),
#      true E[f] = 0 under uniform. RANDU answers 1.0 EXACTLY
#      (every triple has integer s, cos(2πk) = 1): the maximum
#      possible error, deterministically, at any sample size —
#      more samples make it MORE wrong-with-confidence. Xoshiro
#      answers 0 within 5/√(2)·... registered plainly: |I| ≤
#      5·(1/√2)/√n (σ_f = 1/√2 for a full-period cosine).
#   P5 (the friendly integrand, for symmetry) g = xyz, truth
#      1/8: BOTH generators land within 5σ_g/√n (σ_g² = 1/27 −
#      1/64). The pair (RANDU, g) is fine. The pair (RANDU, f)
#      is catastrophic. Quality is a property of pairs — QED.
#   P6 (the modification that kills the lattice) Shuffling
#      RANDU's own output stream (Fisher–Yates driven by
#      Xoshiro, i.e. re-tagging WHICH draw answers WHICH slot)
#      breaks triple-adjacency: the same adversarial integral
#      on shuffled-RANDU falls within the P4 Xoshiro bound.
#      The marginal distribution never changed — only the
#      ORDER. Randomness deficits can live entirely in the
#      order structure, invisible to every marginal test.
#      (This is why the naive courts in P2 CANNOT convict:
#      they are order-blind by construction.)
# CHOICE (flagged): the shuffle in P6 borrows Xoshiro's
#     entropy, so it demonstrates where the crime lives (order,
#     not marginals), NOT a way to launder RANDU without a
#     better source. The IOU is named.
# UNPROVABLE FROM INSIDE: that Xoshiro itself has no adversary.
#     It is a deterministic algorithm; its lattice is subtler
#     (linear over F2), and integrands resonant with THAT
#     structure exist in principle (its own docs exclude
#     cryptographic use). Every acquittal here is relative to
#     the integrand family actually tried. The court that would
#     convict every fake is the court that never rests — see
#     paradox_uncomputable.jl for why it cannot exist.
# ============================================================

import Random

exitcode = 0
fail(m) = (global exitcode = 1; println("  ** FAIL ** ", m))
ok(name, cond) = (println("  ", cond ? "PASS" : "MISS", "  ", name);
                  cond || fail(name))

mutable struct Randu; x::Int64; end
next!(r::Randu) = (r.x = (65539 * r.x) % 2^31; r.x)
uni!(r::Randu)  = next!(r) / 2^31

# --- P1 -----------------------------------------------------------
println("P1  the crime is an identity, not a tendency")
ok("65539² ≡ 6·65539 − 9 ≡ 393225 (mod 2³¹)",
   (Int64(65539)^2) % 2^31 == 393225 && 6*65539 - 9 == 393225)
let r = Randu(1), xs = [next!(r) for _ in 1:100_000]
    viol = count(k -> mod(xs[k+2] - 6xs[k+1] + 9xs[k], 2^31) != 0,
                 1:length(xs)-2)
    ok("x_{k+2} = 6x_{k+1} − 9x_k, zero violations in 10⁵ draws (got $viol)",
       viol == 0)
end

# --- P2 -----------------------------------------------------------
println("P2  every friendly court acquits the fake")
const N = 1_000_000
r = Randu(1)
us = [uni!(r) for _ in 1:N]
m = sum(us) / N
ok("mean $(round(m,digits=5)) within 5σ of 1/2", abs(m - 0.5) <= 5 / sqrt(12N))
bins = zeros(Int, 20)
for x in us; bins[min(20, 1 + floor(Int, 20x))] += 1; end
chi2 = sum((b - N/20)^2 / (N/20) for b in bins)
ok("χ²(19) = $(round(chi2,digits=1)) < 43.8", chi2 < 43.8)
sc = sum((us[i]-m)*(us[i+1]-m) for i in 1:N-1) / sum((x-m)^2 for x in us)
ok("lag-1 serial corr $(round(sc,digits=5)), |·| < 5/√n", abs(sc) < 5/sqrt(N))
println("    three acquittals. The courts are honest; they are asking")
println("    order-blind questions, and the crime lives in the order.")

# --- P3 -----------------------------------------------------------
println("P3  the fifteen planes, counted exactly")
r = Randu(1)
triples = [(uni!(r), uni!(r), uni!(r)) for _ in 1:100_000]
svals = Set(round(9a - 6b + c, digits=6) for (a, b, c) in triples)
ints  = Set(round(Int, 9a - 6b + c) for (a, b, c) in triples)
ok("exactly 15 distinct plane-values (got $(length(svals)))", length(svals) == 15)
ok("and they are exactly the integers −5..9",
   ints == Set(-5:9) && all(v -> abs(v - round(v)) < 1e-6, svals))
rngx = Random.Xoshiro(1)
tri2 = [(rand(rngx), rand(rngx), rand(rngx)) for _ in 1:100_000]
s2 = Set(round(9a - 6b + c, digits=2) for (a, b, c) in tri2)
ok("Xoshiro under the same functional: > 1000 values at 2dp (got $(length(s2)))",
   length(s2) > 1000)
println("    10⁵ RANDU triples visit 15 planes; the cube is 99.9…% empty.")

# --- P4 -----------------------------------------------------------
println("P4  the adversarial integrand: maximum error, with confidence")
f(a, b, c) = cos(2π * (9a - 6b + c))
Ir = sum(f(t...) for t in triples) / length(triples)
Ix = sum(f(t...) for t in tri2)   / length(tri2)
tol = 5 * (1/sqrt(2)) / sqrt(length(tri2))
ok("RANDU answers exactly 1.0 where truth is 0 (got $Ir)", Ir == 1.0)
ok("Xoshiro answers 0 within 5σ (got $(round(Ix,digits=5)), tol $(round(tol,digits=5)))",
   abs(Ix) <= tol)
println("    not merely wrong: wrong by the maximum the integrand permits,")
println("    deterministically — more samples buy more confidence in the error.")

# --- P5 -----------------------------------------------------------
println("P5  the friendly integrand: both acquitted — quality is a pair-fact")
g(a, b, c) = a * b * c
σg = sqrt(1/27 - 1/64)
Gr = sum(g(t...) for t in triples) / length(triples)
Gx = sum(g(t...) for t in tri2)   / length(tri2)
tg = 5σg / sqrt(length(triples))
ok("RANDU on xyz: $(round(Gr,digits=5)) hits 1/8", abs(Gr - 1/8) <= tg)
ok("Xoshiro on xyz: $(round(Gx,digits=5)) hits 1/8", abs(Gx - 1/8) <= tg)
println("    (RANDU, xyz) is a fine pair; (RANDU, cos-plane) is the worst")
println("    possible pair. 'Is it random?' was never a one-place predicate.")

# --- P6 -----------------------------------------------------------
println("P6  shuffle the SAME numbers: the crime was in the order")
shuffled = copy(us)
Random.shuffle!(Random.Xoshiro(99), shuffled)
tri3 = [(shuffled[3k-2], shuffled[3k-1], shuffled[3k]) for k in 1:100_000]
Is = sum(f(t...) for t in tri3) / length(tri3)
ok("shuffled-RANDU on the adversary: $(round(Is,digits=5)) within Xoshiro's bound",
   abs(Is) <= tol)
ok("marginals untouched: sorted stream identical", sort(shuffled) == sort(us))
println("    identical multiset of numbers, opposite verdict — the deficit")
println("    lived entirely in adjacency. Every marginal test was blind by")
println("    type, not by negligence. (IOU: the shuffle spent Xoshiro's")
println("    entropy; this locates the crime, it does not launder RANDU.)")

println()
println(exitcode == 0 ?
  "ALL PASS — the gap between fake and true randomness has no size until\n" *
  "an adversary gives it one; then it can be total. Ask the pair, not the point." :
  "BUILD FAILED")
exit(exitcode)
