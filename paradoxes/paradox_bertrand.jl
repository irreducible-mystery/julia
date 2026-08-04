# ============================================================
# paradox_bertrand.jl — "random chord" is not a question until
#                       you name the sampler
# ============================================================
# LEDGER — Bertrand (1889) asked: a random chord of the unit
# circle — what is the probability it is longer than √3 (the
# side of the inscribed equilateral triangle)? Three impeccable
# samplers give three different answers. This is the cleanest
# possible demonstration that a Monte Carlo simulation does not
# APPROXIMATE a probability; it DEFINES one. "Modified Monte
# Carlo" is not a technique here — it is the paradox.
# ------------------------------------------------------------
# PRE-REGISTERED PREDICTIONS (hard; any miss fails the build):
#     P1  ENDPOINTS method (two uniform points on the circle):
#         P(len > √3) = 1/3.
#     P2  RADIAL method (uniform midpoint along a random radius):
#         P(len > √3) = 1/2.
#     P3  MIDPOINT method (midpoint uniform in the disk):
#         P(len > √3) = 1/4.
#     P4  (the knife) The three estimates are MUTUALLY exclusive
#         at n = 500_000: each CI of half-width 5σ excludes the
#         other two constants. The paradox is not a sampling
#         error and cannot be averaged away.
#     P5  (Jaynes' resolution, checked not assumed) The radial
#         method is the unique one of the three that is invariant
#         under translation + scaling: chords generated on the
#         unit circle, restricted to those cutting an OFFSET
#         smaller circle (center (0.4, 0), radius 1/2), still
#         answer 1/2 there. Endpoint and midpoint methods break
#         it — we DEMAND each drifts off its full-circle value
#         by > 5σ. ERRATUM, paid before commit: the first draft
#         used a CONCENTRIC small circle, and the midpoint method
#         passed through unchanged — correctly! Uniform-in-disk
#         restricted to a concentric disk is still uniform-in-disk;
#         concentric scaling never separated the midpoint sampler.
#         The exit code caught the wrong prediction; the offset is
#         the repair. Jaynes needs the full group, not one orbit.
# CHOICE (flagged): √3 threshold compared on squared lengths to
#     avoid a sqrt in the hot loop; algebraically identical.
# UNPROVABLE FROM INSIDE: which sampler nature uses. Jaynes says
#     the question, fully stated, forces P2; the file only shows
#     the invariance calculus is decidable. The metaphysics is yours.
# ============================================================

import Random
rng = Random.MersenneTwister(20250102)

exitcode = 0
fail(m) = (global exitcode = 1; println("  ** FAIL ** ", m))
function check(name, got, want, tol)
    ok = abs(got - want) <= tol
    println("  ", ok ? "PASS" : "MISS", "  ", name,
            "  got=", round(got, digits=4), "  want=", round(want, digits=4),
            "  tol=", tol)
    ok || fail(name)
end

const N = 500_000
const L2 = 3.0                    # (√3)² — compare squared lengths

# chord from two endpoint angles
chordlen2(a, b) = (cos(a)-cos(b))^2 + (sin(a)-sin(b))^2
# chord length² given midpoint at distance d from center (unit circle)
len2_from_mid(d) = 4 * (1 - d^2)

# --- three samplers, one question -------------------------------
function bertrand_endpoints(rng, n)
    hits = 0
    for _ in 1:n
        hits += chordlen2(2π*rand(rng), 2π*rand(rng)) > L2
    end
    hits / n
end

function bertrand_radial(rng, n)
    hits = 0
    for _ in 1:n
        hits += len2_from_mid(rand(rng)) > L2
    end
    hits / n
end

function bertrand_midpoint(rng, n)
    hits = 0
    for _ in 1:n
        # uniform in disk by rejection — the honest way
        x, y = 2rand(rng)-1, 2rand(rng)-1
        while x^2 + y^2 > 1
            x, y = 2rand(rng)-1, 2rand(rng)-1
        end
        hits += len2_from_mid(sqrt(x^2 + y^2)) > L2
    end
    hits / n
end

p1 = bertrand_endpoints(rng, N)
p2 = bertrand_radial(rng, N)
p3 = bertrand_midpoint(rng, N)

sigma(p) = sqrt(p * (1 - p) / N)

println("P1  endpoints sampler");  check("P(len>√3)", p1, 1/3, 5*sigma(1/3))
println("P2  radial sampler");     check("P(len>√3)", p2, 1/2, 5*sigma(1/2))
println("P3  midpoint sampler");   check("P(len>√3)", p3, 1/4, 5*sigma(1/4))

# --- P4: mutual exclusion — the paradox is real -------------------
println("P4  the three answers exclude each other (5σ)")
for (nm, p, others) in (("endpoints", p1, (1/2, 1/4)),
                        ("radial",    p2, (1/3, 1/4)),
                        ("midpoint",  p3, (1/3, 1/2)))
    for o in others
        ok = abs(p - o) > 5*sigma(o)
        println("  ", ok ? "PASS" : "MISS", "  $nm estimate excludes $(round(o,digits=4))")
        ok || fail("$nm fails to exclude $o")
    end
end

# --- P5: Jaynes' invariance, run not preached ---------------------
# Generate chords on the UNIT circle by each method; keep those that
# cut the OFFSET circle (center (0.4, 0), radius 1/2); ask Bertrand's
# question THERE (threshold: side of ITS triangle, len² = 3r² = 3/4).
# A method passes Jaynes iff the small-circle answer equals its
# full-circle answer; only the radial (uniform-distance) law can.
const CX, CR = 0.4, 0.5
function restricted(rng, n, method)
    hits = 0; kept = 0
    for _ in 1:n
        # chord as (unit normal (nx,ny), signed distance dd from origin)
        local nx, ny, dd
        if method === :radial
            th = 2π*rand(rng); nx, ny = cos(th), sin(th); dd = rand(rng)
        else
            local mx, my
            if method === :endpoints
                a, b = 2π*rand(rng), 2π*rand(rng)
                mx, my = (cos(a)+cos(b))/2, (sin(a)+sin(b))/2
            else  # :midpoint
                mx, my = 2rand(rng)-1, 2rand(rng)-1
                while mx^2 + my^2 > 1
                    mx, my = 2rand(rng)-1, 2rand(rng)-1
                end
            end
            mm = sqrt(mx^2 + my^2)
            mm < 1e-12 && continue     # degenerate chord through center
            nx, ny, dd = mx/mm, my/mm, mm
        end
        rho = abs(CX*nx - dd)          # distance from small center (CX, 0)
        rho >= CR && continue          # chord misses the small circle
        kept += 1
        hits += 4*(CR^2 - rho^2) > 3*CR^2
    end
    (hits / kept, kept)
end

println("P5  Jaynes invariance (unit circle → offset circle at (0.4,0), r=1/2)")
pr, kr = restricted(rng, N, :radial)
check("radial stays at 1/2 (kept $kr)", pr, 1/2, 5*sqrt(0.25/kr))

pe, ke = restricted(rng, N, :endpoints)
pm, km = restricted(rng, N, :midpoint)
for (nm, p, k, full) in (("endpoints", pe, ke, 1/3), ("midpoint", pm, km, 1/4))
    ok = abs(p - full) > 5*sqrt(full*(1-full)/k)
    println("  ", ok ? "PASS" : "MISS",
            "  $nm DRIFTS off its full-circle value (got $(round(p,digits=4)) vs $full, kept $k)")
    ok || fail("$nm unexpectedly invariant")
end

println(exitcode == 0 ?
    "ALL PASS — the sampler is the question; invariance picks the radial court." :
    "BUILD FAILED")
exit(exitcode)
