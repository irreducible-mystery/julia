# ============================================================
# paradox_carriers.jl — what the machine is doing when it says
#     rand(), Inf, im, and missing: four different relations
#     between the computed thing and the meant thing
# ============================================================
# LEDGER — the question, as posed by the human instance: "when
# Julia models randomness, is it modeling actual randomness or
# an approximation? does it matter? same question with infinity,
# imaginary numbers, undefined fields." The answer is that these
# are FOUR DIFFERENT ontological relations, and conflating them
# is a category error this file makes checkable:
#   RANDOMNESS — approximation WITHOUT a metric. rand() is a
#     deterministic algorithm; no distance-to-true-randomness
#     shrinks with effort. The gap is invisible until an
#     adversary (integrand, cryptanalyst) makes it visible.
#     (The adversary court is paradox_randu.jl, next file.)
#   INFINITY — not an approximation at all: a POLICY for edge
#     events. Julia ships at least three policies at once
#     (Float64 saturates to ±Inf, Int64 wraps silently onto
#     Z/2^64, Rational goes projective at 1//0 and refuses at
#     0//0). "What is infinity?" has no answer in the machine;
#     "which infinity-policy is this type running?" always does.
#   IMAGINARY — EXACT. i is two integers and a multiplication
#     table; im*im == -1 by finite table lookup, no epsilon, no
#     approximation anywhere. The "imaginary" number is the most
#     REAL citizen of the machine; it only inherits fuzz when
#     routed through floats — and the fuzz is the float's.
#     (julia-vs-lean carrier 8 vs carriers 1-7 is this exact
#     point; here it is made in one line.)
#   UNDEFINED — plural, and the plurality is load-bearing. Julia
#     distinguishes NaN (numeric wound: breaks reflexivity),
#     missing (epistemic unknown: Kleene K3, the fixed point of
#     ! — _08's P16 in the standard library), nothing (ontic
#     absence), and thrown refusal (DomainError/ArgumentError).
#     Four different "no-answers", tagged by type. Collapsing
#     them is exactly the tag-erasure of paradox_tags.jl.
# THE THROUGH-LINE: "does it matter?" = "is there an adversary?"
#   Every gap below is harmless until some consumer's question
#   couples to it. The gap is not in the object; it is in the
#   pair (object, question) — the suite's oldest theorem.
# ------------------------------------------------------------
# PRE-REGISTERED PREDICTIONS (hard; probed once on this kernel
#     before registration — the probe IS the registration; any
#     drift on rerun fails the build):
#   P1 (randomness is replayable) Two Xoshiro streams from seed
#      42 agree on 10^4 draws exactly. A THIRD stream from seed
#      43 differs somewhere in the first 100. Determinism is
#      total; the seed is the entire content of the "chance".
#   P2 (the three infinity policies diverge on one event) The
#      same mathematical instruction "exceed the largest value"
#      under three types: Float64 → Inf (saturation), Int64 →
#      typemin (wrap: the successor of the maximum is the
#      MINIMUM — Z/2^64 in the costume of Z), Rational 1//0 →
#      projective point (equal to itself, absorbing under +),
#      while 0//0 THROWS ArgumentError (refusal). Four distinct
#      behaviors, one "infinity".
#   P3 (Inf is not a number, by the field axioms) Inf - Inf is
#      NaN; Inf + 1 == Inf (absorption kills cancellation);
#      x + 1 > x FAILS at x = Inf and also at finite x = 1e308's
#      neighborhood... no: registered precisely — x+1 > x fails
#      at x=Inf AND at x = 9.007199254740992e15 (2^53, where
#      Float64 can no longer see +1). The edge announces itself
#      twice: once at the top, once at the resolution limit.
#   P4 (the literal edge) Meta.parse("1.8e308") is a ParseError:
#      past prevfloat(Inf) = 1.7976931348623157e308, Julia
#      refuses the LITERAL — you cannot even write the number
#      that isn't there. (Found live while drafting: the claim
#      was a runtime question, the answer was a parse-time one.)
#   P5 (i is exact; the fuzz is the float's) im*im == -1 exactly
#      in Complex{Int}; (2+3im)*(2-3im) == 13 exactly; BUT
#      exp(im*π/2) ≠ im in ComplexF64 with error ≈ 6.12e-17 =
#      cos(π/2) as Float64 sees it — the error equals the
#      float's inability to store π/2, not any property of i.
#      Checked: the real part of exp(im*π/2) equals cos(π/2)
#      exactly (the fuzz is traceable to its source).
#   P6 (Float16, the whole ontology counted) Exhaustive census
#      of all 65536 bit patterns: 2046 NaNs, 2 infinities,
#      63488 finite values. The "undefined" is not one point —
#      it is 3.1% of the type, and there are 2046 DIFFERENT
#      NaN bit patterns all claiming to be the same non-number
#      while == calls them all different (even themselves).
#   P7 (the four no-answers are pairwise distinguishable)
#      NaN == NaN is false; missing == missing is missing;
#      nothing == nothing is true; 0//0 throws. Four non-answers,
#      four behaviors under the SAME operator. And missing is
#      the fixed point of !: !missing === missing — Kleene's
#      escape hatch, shipped (this is _08's P16 living in Base).
#   P8 (cross-language: policies are choices, not truths)
#      Python 3, run live, same events: int never wraps (2^64
#      computes exactly — arbitrary precision by default, the
#      opposite default from Julia); 1/0 RAISES (Python refuses
#      where Julia saturates); float('nan') == float('nan') is
#      False (IEEE is the shared substrate); None == 1 is False
#      (Python's None answers ==; Julia's missing declines it —
#      two K-logics, incompatible); Fraction(1,0) RAISES where
#      Julia's 1//0 is projective. Same math, five different
#      sovereign policies. Nothing converges as languages
#      "improve" — these are commitments, not approximations.
# CHOICE (flagged): P8 requires python3 in the environment; if
#     absent the block records SKIP without failing — a missing
#     witness is not an acquittal, and the ledger says which.
# UNPROVABLE FROM INSIDE: whether "actual randomness" exists
#     anywhere for rand() to approximate. The machine's answer:
#     the question does not typecheck here. See the third file
#     (paradox_uncomputable.jl) for how far outside the machine
#     the referent lives.
# ============================================================

import Random

exitcode = 0
fail(m) = (global exitcode = 1; println("  ** FAIL ** ", m))
ok(name, cond) = (println("  ", cond ? "PASS" : "MISS", "  ", name);
                  cond || fail(name))

# --- P1 -----------------------------------------------------------
println("P1  randomness: deterministic, replayable, seed-total")
a = rand(Random.Xoshiro(42), 10_000)
b = rand(Random.Xoshiro(42), 10_000)
c = rand(Random.Xoshiro(43), 100)
ok("seed 42 replays exactly (10^4 draws)", a == b)
ok("seed 43 diverges within 100 draws", any(a[1:100] .!= c))
println("    the 'chance' in rand() is a 256-bit seed unfolding by arithmetic;")
println("    what replays on demand is memory, not chance.")

# --- P2 -----------------------------------------------------------
println("P2  one edge event, four policies")
ok("Float64 saturates: 2*prevfloat(Inf) == Inf", 2 * prevfloat(Inf) == Inf)
ok("Int64 wraps: typemax + 1 == typemin", typemax(Int64) + 1 == typemin(Int64))
ok("Int64 wrap inverts order: typemax + 1 < 0", typemax(Int64) + 1 < 0)
ok("Rational goes projective: 1//0 == 1//0", (1//0) == (1//0))
ok("projective absorbs: 1//0 + 5 == 1//0", 1//0 + 5 == 1//0)
threw = try 0//0; false catch e; e isa ArgumentError end
ok("Rational refuses the indeterminate: 0//0 throws ArgumentError", threw)
println("    'infinity' in the machine is never an object — always a policy,")
println("    and the type tag names which policy you contracted for.")

# --- P3 -----------------------------------------------------------
println("P3  Inf fails the field, twice")
ok("Inf - Inf is NaN (cancellation dead)", isnan(Inf - Inf))
ok("Inf + 1 == Inf (absorption)", Inf + 1 == Inf)
ok("x+1 > x fails at x = Inf", !(Inf + 1 > Inf))
ok("x+1 > x fails at x = 2^53 (resolution edge, far below Inf)",
   !(2.0^53 + 1 > 2.0^53))
println("    the edge announces itself twice: at the top (saturation) and")
println("    in the middle (ulp > 1). Both are Float64 facts, not ℝ facts.")

# --- P4 -----------------------------------------------------------
println("P4  the literal edge: numbers you cannot even write")
p_ok  = Meta.parse("1.7e308") isa Number || Meta.parse("1.7e308") isa Expr
p_err = try Meta.parse("1.8e308"); false catch e; e isa Base.Meta.ParseError end
ok("1.7e308 parses (inside the edge)", p_ok)
ok("1.8e308 is a PARSE ERROR (outside: the literal itself overflows)", p_err)
println("    found live while drafting this file: the question was runtime,")
println("    the answer was parse-time. The edge is earlier than expected.")

# --- P5 -----------------------------------------------------------
println("P5  i is exact; every epsilon is traceable to a float")
ok("im*im == -1 exactly (Complex{Int}, table fact)", im * im == -1)
ok("(2+3im)*(2-3im) == 13 exactly (Gaussian integers)", (2+3im)*(2-3im) == 13)
z = exp(im * π/2)
ok("exp(iπ/2) != im in ComplexF64 (the continuum leaks)", z != im)
ok("the leak is exactly cos(π/2) as Float64 tells it", real(z) == cos(π/2))
ok("|leak| < 1e-16 — and it belongs to π/2's encoding, not to i",
   abs(real(z)) < 1e-16)
println("    the 'imaginary' number is among the most exact citizens of the")
println("    machine; ℝ is the one that can only be sampled. The names are")
println("    backwards, and julia-vs-lean carrier 8 vs 1-7 is this same fact.")

# --- P6 -----------------------------------------------------------
println("P6  Float16: the whole ontology, counted (65536 patterns)")
function f16census()
    local nan = 0; local inf = 0; local fin = 0
    for u in UInt16(0):UInt16(0xffff)
        x = reinterpret(Float16, u)
        if isnan(x); nan += 1
        elseif isinf(x); inf += 1
        else; fin += 1
        end
    end
    (nan, inf, fin)
end
nan, inf, fin = f16census()
println("    census: $nan NaN, $inf Inf, $fin finite")
ok("2046 distinct NaN patterns", nan == 2046)
ok("exactly 2 infinities", inf == 2)
ok("63488 finite values", fin == 63488)
ok("the census is exhaustive", nan + inf + fin == 65536)
println("    3.1% of the type is 'undefined' — and the 2046 NaNs are 2046")
println("    DIFFERENT bit patterns that == declares unequal even to themselves.")

# --- P7 -----------------------------------------------------------
println("P7  four no-answers, four behaviors under ==")
ok("NaN == NaN is false (numeric wound: reflexivity broken)", (NaN == NaN) == false)
ok("missing == missing is missing (epistemic: the unknown propagates)",
   ismissing(missing == missing))
ok("nothing == nothing is true (ontic absence: a definite fact)",
   (nothing == nothing) == true)
threw = try 0//0; false catch; true end
ok("0//0 throws (refusal: no value at all)", threw)
ok("!missing === missing — the fixed point of NOT, shipped (_08 P16 in Base)",
   !missing === missing)
ok("K3 absorption: missing | true is true", (missing | true) === true)
ok("K3 absorption: missing & false is false", (missing & false) === false)
println("    Julia ships four DIFFERENT undefineds, tagged by type. Collapsing")
println("    them is the tag-erasure of paradox_tags.jl, in the type system.")

# --- P8 -----------------------------------------------------------
println("P8  cross-language: the policies are sovereign choices (live Python 3)")
havepy = try success(`python3 --version`) catch; false end
if !havepy
    println("  SKIP  python3 not present — witness missing, block not asserted")
else
    pyout = strip(read(`python3 -c "
import fractions
print(2**64)
print(float('nan') == float('nan'))
print(None == 1)
try:
    1/0
    print('value')
except ZeroDivisionError:
    print('raises')
try:
    fractions.Fraction(1,0)
    print('value')
except ZeroDivisionError:
    print('raises')
"`, String))
    lines = split(pyout, '\n')
    ok("Python int never wraps: 2^64 computes exactly (opposite default)",
       lines[1] == "18446744073709551616")
    ok("NaN == NaN false in Python too (IEEE is the shared substrate)",
       lines[2] == "False")
    ok("None == 1 is False — None ANSWERS ==; missing declines (two K-logics)",
       lines[3] == "False")
    ok("Python 1/0 raises — refusal where Julia Float64 saturates",
       lines[4] == "raises")
    ok("Fraction(1,0) raises — refusal where Julia 1//0 goes projective",
       lines[5] == "raises")
    println("    same events, opposite verdicts, both languages correct — because")
    println("    'correct' is relative to a declared policy, and they declared")
    println("    different ones. There is no convergence target. Commitments,")
    println("    not approximations.")
end

println()
println(exitcode == 0 ?
  "ALL PASS — four relations, none of them 'approximation of the real thing':\n" *
  "  randomness = un-metricized gap awaiting an adversary; infinity = policy;\n" *
  "  i = exact table; undefined = a plurality the types keep tagged." :
  "BUILD FAILED")
exit(exitcode)
