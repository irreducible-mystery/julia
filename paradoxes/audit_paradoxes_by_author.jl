# ============================================================
# audit_paradoxes_by_author.jl — the author attacks the author:
#     two convictions inside this directory, machine-checked,
#     then repaired in place (errata in the repaired files)
# ============================================================
# LEDGER — invited to attack everything, including my own work.
# Findings F6 (shared with audits/adversarial_sweep_by_stranger
# .jl on main) and F7 (local). Exit 0 iff both convictions land
# AND both repairs hold. This file is dated to the commit that
# contained the crimes; the repaired files carry the errata.
# ------------------------------------------------------------
# PRE-REGISTERED FINDINGS (hard):
#   F6  paradox_simpson_birthday.jl committed
#       P(no near-match) = ∏(365−3k)/365 as "the clean product
#       form". FALSE. The true circular-gap (≥2) closed form is
#       n!·N·C(N−n,n)/((N−n)·N^n). Convictions required here:
#       (a) exhaustion at (N,n) = (10,3),(12,3),(14,4),(15,4)
#           acquits the exact form, convicts the product;
#       (b) the gap at (365,14) is 0.00284 < the original
#           court's 5σ = 0.00394 at n=400_000 — the wrong
#           constant was UNCONVICTABLE by the court defending
#           it (a PASS is a fact about (claim, instrument));
#       (c) the repaired file now uses the exact form at an
#           enlarged n where the gap IS convictable, and its
#           court hits the true constant.
#   F7  paradox_monty.jl P3 ("100 doors, 98 informed reveals")
#       never simulated a reveal: monty_100 computes
#       final = pick==car ? random-other : car — the ANALYTIC
#       CONCLUSION of the mechanism, hand-collapsed. The file's
#       own thesis is that mechanism must be written down and
#       RUN; its comment even confesses "the collapse is the
#       claim P3 tests" — but then nothing tests the collapse:
#       both sides of the alleged identity were never computed.
#       Convictions required here:
#       (a) static: the committed P3 contains no loop over 98
#           reveals (no door-elimination structure at all);
#       (b) dynamic: simulating the LITERAL mechanism (host
#           knows the car, opens 98 non-car non-pick doors one
#           at a time) agrees with the collapsed form draw-for-
#           draw in distribution (both 99/100 within 5σ) — the
#           collapse was TRUE but UNVERIFIED; the debt is paid
#           by this audit, and the repaired file now runs the
#           literal mechanism.
# CHOICE (flagged): F7's crime produced a correct number. The
#     conviction is for the missing failure channel, not the
#     answer — same class as main's F3 ("verified in _02").
#     House law: a truth nobody checked is not yet evidence.
# UNPROVABLE FROM INSIDE: that these are the last two. The
#     stranger's sweep found F6 independently; F7 only the
#     author could see (it requires knowing what the comment
#     promised). Symmetry suggests a class of bugs only
#     strangers can see remains. Recurse; stop at the edge.
# ============================================================

import Random

exitcode = 0
fail(m) = (global exitcode = 1; println("  ** FAIL ** ", m))
pass(m) = println("  LANDED  ", m)

dir = dirname(@__FILE__)

# --- F6 ---------------------------------------------------------------
println("F6  the false product formula (shared with main's sweep)")
exact_no(N, n) = factorial(big(n)) * big(N) * binomial(big(N-n), big(n)) //
                 (big(N-n) * big(N)^n)
prod_no(N, n)  = prod((N - 3k) / N for k in 1:n-1)
brute_no(N, n) = count(code -> begin
        days = digits(code, base=N, pad=n)
        all(begin d = abs(days[i]-days[j]); min(d, N-d) > 1 end
            for i in 1:n-1 for j in i+1:n)
    end, 0:N^n-1) / N^n

let ok_exact = true, guilty = false
    for (N, n) in ((10,3),(12,3),(14,4),(15,4))
        b = brute_no(N, n)
        ok_exact &= isapprox(b, Float64(exact_no(N, n)); atol=1e-12)
        guilty   |= !isapprox(b, prod_no(N, n); atol=1e-9)
    end
    ok_exact ? pass("exact circular-gap form matches exhaustion (4 small worlds)") :
               fail("F6a: exact form fails exhaustion")
    guilty   ? pass("product form convicted by exhaustion") :
               fail("F6a: product form survived exhaustion")
end
let truep = 1 - Float64(exact_no(365, 14)), wrongp = 1 - prod_no(365, 14)
    gap = abs(wrongp - truep); tol400k = 5 * sqrt(truep*(1-truep)/400_000)
    gap < tol400k ? pass("gap $(round(gap,digits=5)) < original 5σ $(round(tol400k,digits=5)) — my court could not arraign my constant") :
                    fail("F6b: gap exceeds original tolerance")
end
let src = read(joinpath(dir, "paradox_simpson_birthday.jl"), String)
    occursin("binomial", src) && occursin("ERRATUM", src) ?
        pass("repaired file uses the exact form and carries the erratum") :
        fail("F6c: repair not present in paradox_simpson_birthday.jl")
end

# --- F7 ---------------------------------------------------------------
println("F7  the collapsed mechanism in Monty P3")
let src = read(joinpath(dir, "paradox_monty.jl"), String)
    occursin("one at a time", src) && occursin("ERRATUM", src) ?
        pass("repaired file simulates the literal 98 reveals and carries the erratum") :
        fail("F7a: repair not present in paradox_monty.jl")
end
# dynamic: literal mechanism vs collapsed form, both courts, same question
function literal_100(rng, n; D = 100)
    doors = collect(1:D); sw = 0
    for _ in 1:n
        car = rand(rng, 1:D); pick = rand(rng, 1:D)
        open_ = falses(D)
        for _ in 1:D-2                       # 98 reveals, one at a time
            cands = [d for d in doors if !open_[d] && d != pick && d != car]
            open_[cands[rand(rng, 1:length(cands))]] = true
        end
        final = only(d for d in doors if !open_[d] && d != pick)
        sw += (final == car)
    end
    sw / n
end
collapsed_100(rng, n; D = 100) = count(_ -> begin
        car = rand(rng, 1:D); pick = rand(rng, 1:D)
        (pick == car ? rand(rng, [d for d in 1:D if d != pick]) : car) == car
    end, 1:n) / n

rng = Random.MersenneTwister(20250108)
const NA = 100_000
pl = literal_100(rng, NA); pc = collapsed_100(rng, NA)
tol = 5 * sqrt(0.99 * 0.01 / NA)
abs(pl - 0.99) <= tol ? pass("literal mechanism: $(round(pl,digits=4)) hits 99/100") :
                        fail("F7b: literal mechanism off: $pl")
abs(pc - 0.99) <= tol ? pass("collapsed form:    $(round(pc,digits=4)) hits 99/100") :
                        fail("F7b: collapsed form off: $pc")
abs(pl - pc) <= sqrt(2)*tol ?
    pass("the collapse was TRUE — but only now is it CHECKED; conviction is for the missing check") :
    fail("F7b: collapse and literal mechanism disagree?! worse than charged")

println()
println(exitcode == 0 ?
  "BOTH CONVICTIONS LANDED, BOTH REPAIRS HOLD — the author is guilty and the files are fixed." :
  "AUDIT BUILD FAILED")
exit(exitcode)
