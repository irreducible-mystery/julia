# ============================================================
# paradox_boygirl.jl — the question is the protocol: one family,
#     three probabilities, and a dial between them
#     (contributed by the auditing instance, in the house style)
# ============================================================
# LEDGER. "Mr. Smith has two children. At least one is a boy.
# What is the probability both are boys?" The textbook fight
# (1/3 vs 1/2) is not a fight about probability. It is a fight
# about WHICH SAMPLER produced the sentence "at least one is a
# boy" — the Bertrand lesson (three protocols, three answers)
# in its smallest possible arena: four equally likely states
# {BB, BG, GB, GG}.
#
#   Protocol F (family census): sample two-child families,
#     DISCARD those with no boy, report the rest. The sentence
#     is a filter. P(BB | kept) = 1/3.
#   Protocol C (child encounter): sample a family, then meet a
#     RANDOM ONE of its children; you happened to meet a boy.
#     The sentence is an observation of one child.
#     P(BB | met a boy) = 1/2. Same words. Different machine.
#   Protocol T (the Tuesday boy): "at least one is a boy born
#     on Tuesday" under the census protocol. Folk intuition
#     says the weekday is irrelevant. It is not — it is a
#     LEAK GAUGE: the more specific the mentioned trait, the
#     closer the census answer climbs from 1/3 to the encounter
#     answer 1/2, because specificity makes it ever less likely
#     that BOTH children triggered the filter. The trait's
#     rarity 1/k interpolates the two classic answers — the
#     paradox has a DIAL in it, and the two famous numbers are
#     its endpoints. (The emergence thread met this shape in
#     _07/_09: two "contradictory" invariants revealed as the
#     zero- and generic- fibers of one parametric law.)
#
# PRE-REGISTERED PREDICTIONS (hard = failure fails the build;
# derived on paper first, in this header, before running):
#   P1 (exact, by enumeration — no dice): census protocol gives
#      EXACTLY 1/3 (as Rational: 1//3) on the 4-state space.
#   P2 (exact): encounter protocol gives EXACTLY 1//2 on the
#      8-state space (family × which child you met).
#   P3 (exact): Tuesday-boy census on the 196-state space
#      (7 weekdays per child squared): EXACTLY 13//27.
#      Paper: P(BB | ≥1 Tue-boy) = (2·7−1)/(4·7−1) = 13/27.
#   P4 (the dial, exact): for trait rarity 1/k, k = 1..30,
#      census-with-trait gives EXACTLY (2k−1)/(4k−1); at k=1 it
#      IS 1/3 (the plain census: "born on any day"), and it is
#      strictly increasing in k with limit 1/2 (the encounter
#      answer). Monotonicity checked exactly in ℚ for all
#      consecutive k. The two textbook answers are the k=1 and
#      k=∞ fibers of ONE formula.
#   P5 (MC agrees with ℚ, 5σ): 400k-family Monte Carlo for
#      protocols F, C, T lands within 5σ binomial noise of the
#      exact answers. The court that convicted F6 (birthday)
#      taught us: quote (claim, instrument) — n and σ both.
#   P6 (control — the instrument can convict): running the
#      ENCOUNTER data against the CENSUS answer 1/3 must fail
#      by > 5σ. If it cannot, this court is too weak to convict
#      protocol confusion, which is the only crime here.
#   P7 (the seam, exact): the census filter and the encounter
#      weighting differ ONLY on the mixed states {BG, GB}:
#      census counts them fully (weight 1), encounter counts
#      them at weight 1/2 (you might have met the girl). The
#      1/3-vs-1/2 gap is EXACTLY that reweighting, verified by
#      computing both as measures on the same 4-state space.
#      The paradox is two importance weights wearing one noun.
# ------------------------------------------------------------
# UNPROVABLE FROM INSIDE: which protocol the ENGLISH sentence
# "at least one is a boy" denotes. That is a fact about the
# speaker's sampler, not about families; no amount of Julia can
# recover it from the words. This is the tag doctrine: the
# missing tag is WHO FILTERED. (Bertrand's chord asked the same
# question with geometry; this file asks it with a noun phrase.)
# ============================================================

using Random

exitcode = 0
fail(m) = (global exitcode = 1; println("  FAIL  ", m))
ok(m, c::Bool) = c ? println("  PASS  ", m) : fail(m)

# ---------------------------------------------------------- I
println("I   exact court: three protocols on paper-sized state spaces")

# 4 states: (c1, c2) with true = boy. Uniform 1//4 each.
states2 = [(b1, b2) for b1 in (true, false), b2 in (true, false)]

# P1 census: keep families with ≥ 1 boy
let kept = [(s, 1//4) for s in states2 if s[1] || s[2]]
    tot = sum(w for (_, w) in kept)
    bb  = sum(w for (s, w) in kept if s[1] && s[2])
    ans = bb // tot
    ok("P1 census protocol, exact: P(BB | ≥1 boy) = $ans == 1//3", ans == 1//3)
end

# P2 encounter: 8 states = family × which child was met; condition on met-a-boy
# (functions, not bare loops: _05's soft-scope conviction is house law —
#  and this file's first draft was convicted by it live; erratum in place)
function encounter_exact()
    num = 0//1; den = 0//1
    for s in states2, meet in (1, 2)
        w = 1//8
        met_boy = (meet == 1 ? s[1] : s[2])
        met_boy || continue
        den += w
        s[1] && s[2] && (num += w)
    end
    num // den
end
let ans = encounter_exact()
    ok("P2 encounter protocol, exact: P(BB | met a boy) = $ans == 1//2", ans == 1//2)
end

# exact census-with-trait of rarity 1//k (used by P3 and P4)
function dial(k)
    num = 0//1; den = 0//1
    for b1 in (true, false), b2 in (true, false), d1 in 1:k, d2 in 1:k
        w = (1//4) * (1//k) * (1//k)
        trig = (b1 && d1 == 1) || (b2 && d2 == 1)
        trig || continue
        den += w
        b1 && b2 && (num += w)
    end
    num // den
end

# P3 Tuesday boy: 196 states, exact
let ans = dial(7)
    ok("P3 Tuesday-boy census, exact on 196 states: $ans == 13//27", ans == 13//27)
end

# ---------------------------------------------------------- II
println("II  the dial: rarity interpolates the two textbook answers")

let all_formula = true, mono = true
    prev = 0//1
    for k in 1:30
        d = dial(k)
        all_formula &= (d == (2k - 1) // (4k - 1))
        mono &= (d > prev)
        prev = d
    end
    ok("P4 dial law, exact ℚ, k = 1..30: P = (2k−1)/(4k−1); k=1 gives $(dial(1)) " *
       "(the plain census), strictly increasing, → 1/2", 
       all_formula && mono && dial(1) == 1//3)
    println("        'irrelevant' weekday, quantified: mentioning a 1-in-7 trait")
    println("        moves the answer from 9/27 to 13/27 — half the distance to")
    println("        the encounter protocol. Specificity is evidence about WHICH")
    println("        child triggered the sentence; at k → ∞ the trait names the")
    println("        child outright and census BECOMES encounter. The two famous")
    println("        answers were never rivals — they are the k=1 and k=∞ fibers")
    println("        of one law. (The emergence thread calls this a dial; its")
    println("        charge dial has the same anatomy: endpoints in dispute,")
    println("        parameter unnoticed.)")
end

# --------------------------------------------------------- III
println("III Monte Carlo court, with its σ on the record")

let n = 400_000
    Random.seed!(20260804)
    # protocol F
    cf = 0; nf = 0
    # protocol C
    cc = 0; nc = 0
    # protocol T (k = 7)
    ct = 0; nt = 0
    for _ in 1:n
        b1, b2 = rand(Bool), rand(Bool)
        d1, d2 = rand(1:7), rand(1:7)
        if b1 || b2
            nf += 1; (b1 && b2) && (cf += 1)
        end
        meet = rand(1:2)
        if (meet == 1 ? b1 : b2)
            nc += 1; (b1 && b2) && (cc += 1)
        end
        if (b1 && d1 == 1) || (b2 && d2 == 1)
            nt += 1; (b1 && b2) && (ct += 1)
        end
    end
    sig(p, m) = 5 * sqrt(p * (1 - p) / m)
    pf, pc, pt = cf / nf, cc / nc, ct / nt
    okF = abs(pf - 1/3)   < sig(1/3, nf)
    okC = abs(pc - 1/2)   < sig(1/2, nc)
    okT = abs(pt - 13/27) < sig(13/27, nt)
    ok("P5 MC within 5σ of ℚ: census $(round(pf, digits=4)) (5σ=$(round(sig(1/3, nf), digits=4))), " *
       "encounter $(round(pc, digits=4)), Tuesday $(round(pt, digits=4))",
       okF && okC && okT)

    # P6 control: encounter data vs census claim must CONVICT
    conv = abs(pc - 1/3) > sig(1/3, nc)
    zscore = abs(pc - 1/3) / (sig(1/3, nc) / 5)
    ok("P6 control: encounter sample REJECTS the census answer 1/3 " *
       "(z ≈ $(round(zscore, digits=1)) > 5) — the court can convict protocol confusion",
       conv)
    println("        F6's lesson applied before the crime this time: the")
    println("        tolerance (5σ at n=$(nc)) is narrower than the gap it")
    println("        must police (1/2 − 1/3 = 1/6). Quote the pair.")
end

# ---------------------------------------------------------- IV
println("IV  the seam, exact: one noun, two importance weights")

let
    # both protocols as measures on the SAME 4-state space
    census_w    = Dict((true,true) => 1//1, (true,false) => 1//1,
                       (false,true) => 1//1, (false,false) => 0//1)
    encounter_w = Dict((true,true) => 1//1, (true,false) => 1//2,
                       (false,true) => 1//2, (false,false) => 0//1)
    post(w) = w[(true,true)] // (w[(true,true)] + w[(true,false)] + w[(false,true)])
    same_on_pure  = census_w[(true,true)] == encounter_w[(true,true)] &&
                    census_w[(false,false)] == encounter_w[(false,false)]
    diff_on_mixed = census_w[(true,false)] != encounter_w[(true,false)]
    ok("P7 seam isolated: protocols agree on {BB, GG}, differ exactly on " *
       "{BG, GB} (1 vs 1/2); posteriors $(post(census_w)) vs $(post(encounter_w))",
       same_on_pure && diff_on_mixed &&
       post(census_w) == 1//3 && post(encounter_w) == 1//2)
    println("        the entire paradox is the number 1/2 sitting on two")
    println("        states — the chance you'd have met the girl instead.")
    println("        census: the sentence was made by a FILTER (both mixed")
    println("        states pass, full weight). encounter: the sentence was")
    println("        made by a MEETING (mixed states halve — the boy had to")
    println("        be the one you saw). WHO FILTERED is the missing tag;")
    println("        the English sentence ships without it, and every fight")
    println("        about this puzzle is two samplers claiming one noun.")
end

println()
println(exitcode == 0 ?
    "ALL PASS — one family, three machines, one dial; the noun was never enough." :
    "FAILURES — read the ledger.")
exit(exitcode)
