# ============================================================
# paradox_uncomputable.jl — ℝ is the imaginary object, and
#     randomness and time are the same unpaid debt
# ============================================================
# LEDGER — the third file of the carriers trilogy. The human
# instance asked whether rand() approximates "actual
# randomness" and whether i is less real than ℝ. This file
# runs the two inversions as far as a machine can run them:
#   INVERSION 1: i is finite data (paradox_carriers.jl P5,
#     exact to the last bit). ℝ is the object no machine has
#     ever held: almost every real number is UNCOMPUTABLE —
#     there are only countably many programs, so the
#     computable reals have measure zero. Every float, every
#     BigFloat, every rand() output is a rational. The reals
#     your simulation "samples from" are a set it cannot touch,
#     except on a measure-zero skeleton. ℝ is the working
#     mathematician's most-used object and the machine's most
#     imaginary one. The names are exactly backwards.
#   INVERSION 2: the emergence files carry a debt flagged nine
#     times and never paid — "the global tick is exogenous;
#     schedules come from our RNG, not from the world" (_02 IV,
#     _03, _04, ... _09). Note the confession's own wording:
#     the tick comes FROM THE RNG. Time and randomness enter
#     those worlds through the SAME door — an ordering the
#     world does not generate, handed in from outside. And the
#     machine's own randomness has the same shape: Xoshiro is
#     pure clockwork (replayable = not chance), while
#     RandomDevice imports non-replayable order from physical
#     entropy — outside the program as the schedule is outside
#     the world. One debt, two costumes. This file cannot pay
#     it either; it makes the identity checkable and prices it.
# ------------------------------------------------------------
# PRE-REGISTERED PREDICTIONS (hard unless marked WITNESS):
#   P1 (everything the machine holds is rational) 10^4 draws
#      from rand(): every one is exactly a rational with
#      denominator dividing 2^53 (max observed denominator IS
#      2^53). BigFloat(π) at 1024 bits: exactly rational,
#      denominator a power of 2. The machine's "reals" are a
#      countable lattice of dyadic rationals wearing ℝ's name.
#   P2 (the lattice, counted) The number of representable
#      Float64 values in [0,1) is exactly 2^62 − 2^52 =
#      4607182418800017408 (computed by bit-pattern arithmetic,
#      reinterpret(UInt64, 1.0) − reinterpret(UInt64, 0.0)) —
#      yet rand() visits only 2^53 of them (multiples of 2^-53):
#      the sampler's support is ~1/512 of the type's own grid,
#      which is measure zero in [0,1) — a lattice ON a lattice,
#      each level believing the one below is a continuum.
#   P3 (computable ⊂ measure zero, made runnable) The measure-
#      zero-ness of ANY countable set is checkable arithmetic:
#      cover point k by an interval of length ε/2^k; in exact
#      Rational{BigInt} arithmetic, Σ_{k≤60} ε/2^k < ε holds
#      EXACTLY (no float fuzz). Diagonalization is also run,
#      not cited: for any explicit list of reals-as-digit-
#      streams, the diagonal real differs from list entry k at
#      digit k — verified on a concrete 10-element list, giving
#      a number provably outside it. (Cantor as a unit test:
#      the enumeration of programs can never exhaust ℝ.)
#   P4 (π is computable — the skeleton is real) BigFloat(π) at
#      1024 bits is a prefix of BigFloat(π) at 4096 bits (the
#      approximation is CONVERGENT with a known modulus — this
#      is what "computable real" MEANS, and why π, e, √2 are
#      honorary machine citizens while almost all of ℝ is not).
#      Contrast is P1: π's rational stand-ins change with
#      precision; a computable real is the LAW of that change.
#   P5 (Chaitin's boundary, stated as a refusal) Ω — the
#      halting probability — is a specific, well-defined real
#      in [0,1] that NO program computes to arbitrary
#      precision. We do not simulate Ω (nothing can); we check
#      the boundary it marks: the file's own halting-oracle
#      refusal (emergence_00's diagonal, now typed): a
#      hypothetical halts() oracle is defeated by the program
#      that does the opposite of its own verdict — constructed
#      and exhibited as a type-level fact (the construction
#      exists; running it against a real oracle is impossible
#      because there is none). WITNESS status: the diagonal is
#      shown, the impossibility is cited (Turing 1936), the
#      exit code asserts only the construction.
#   P6 (the two doors are one door) (a) Xoshiro(42) replayed
#      twice: identical 10^3-draw streams — algorithmic
#      "randomness" is memory, and supplies the emergence
#      files' schedules; a replayed schedule means the worlds'
#      "nondeterministic" races (_02 §II) are exactly as
#      deterministic as their tick. (b) RandomDevice, read
#      twice: 256-bit reads differ — non-replayable order,
#      bought from physics, not computed. The predicate
#      REPLAYABLE cleanly separates the two randomness sources
#      exactly as EXOGENOUS separates the emergence worlds'
#      time from anything they generate. The unpaid debt of
#      nine files and the "is rand() real randomness?" question
#      are the same question. Priced, not paid: paying it would
#      require either a world that generates its own schedule
#      (closed timelike bootstrap, nobody has one) or a proof
#      that physical entropy is irreducible (nobody has one —
#      device entropy is unfalsifiable-from-inside in exactly
#      Xoshiro's blind spot: P2 of paradox_randu.jl showed
#      order-blind courts acquit clockwork).
# CHOICE (flagged): P2's "rand() visits only 2^53 values" is
#     asserted from the observed max denominator + Julia's
#     documented bits-53 sampling; a full-support census is
#     2^53 draws and is not affordable. The claim is falsifiable
#     cheaply: one draw with denominator > 2^53 kills it.
# UNPROVABLE FROM INSIDE: whether the physical entropy behind
#     RandomDevice is "actual randomness" or a subtler RANDU —
#     the universe's own lattice planes, awaiting an integrand.
#     No court below can reach that question. It is the visible
#     edge; we stop at it, and say so.
# ============================================================

import Random

exitcode = 0
fail(m) = (global exitcode = 1; println("  ** FAIL ** ", m))
ok(name, cond) = (println("  ", cond ? "PASS" : "MISS", "  ", name);
                  cond || fail(name))

# --- P1 -----------------------------------------------------------
println("P1  everything the machine holds is rational")
rng = Random.Xoshiro(2)
rs = [Rational{BigInt}(rand(rng)) for _ in 1:10_000]
ok("all 10⁴ rand() outputs are dyadic rationals",
   all(r -> ispow2(r.den), rs))
maxden = maximum(r.den for r in rs)
ok("max denominator observed is exactly 2⁵³ (got 2^$(Int(log2(maxden))))",
   maxden == big(2)^53)
pirat = setprecision(() -> Rational{BigInt}(BigFloat(pi)), 1024)
ok("BigFloat(π) at 1024 bits is exactly a rational with power-of-2 denominator",
   ispow2(pirat.den))
println("    'floating-point real number' is a rational in costume; the")
println("    machine has never once held an irrational number as a value.")

# --- P2 -----------------------------------------------------------
println("P2  the lattice, counted by bit arithmetic")
nfloats = reinterpret(UInt64, 1.0) - reinterpret(UInt64, 0.0)
ok("Float64 count in [0,1) = 2⁶² − 2⁵² = $nfloats",
   nfloats == UInt64(2)^62 - UInt64(2)^52)
ok("rand()'s support (2⁵³) is exactly 1/511.5 of the type's own grid",
   2 * big(nfloats) == 1023 * big(2)^53)   # nfloats = 2⁵²·1023, so ratio = 511.5 exactly
println("    grid ratio: $(round(Float64(big(nfloats) / big(2)^53), digits=1)) : 1")
println("    a lattice sampling a lattice believing itself a continuum —")
println("    and both are measure zero in the ℝ they are named after.")

# --- P3 -----------------------------------------------------------
println("P3  measure zero and the diagonal, both run in exact arithmetic")
ε = 1 // 1000
cover = sum(ε // big(2)^k for k in 1:60)
ok("Σ ε/2ᵏ (k ≤ 60) = $(Float64(cover)) < ε exactly, in Rational{BigInt}",
   cover < ε)
println("    any countable set — all programs, all floats, all outputs of")
println("    all RNGs ever run — fits in total length < any ε you name.")
# the diagonal as a unit test: 10 'reals' as digit streams, defeat them all
digitlist = [[mod(7i + 3j, 10) for j in 1:10] for i in 1:10]
diag = [mod(digitlist[k][k] + 5, 10) for k in 1:10]   # differs at digit k, never 9↔0 wrap issue (shift 5)
ok("diagonal digit-stream differs from every listed stream at its own index",
   all(diag[k] != digitlist[k][k] for k in 1:10))
println("    Cantor as a unit test: no enumeration (in particular, not the")
println("    enumeration of all programs) exhausts the digit streams.")

# --- P4 -----------------------------------------------------------
println("P4  computable reals: the skeleton that IS reachable")
p1 = setprecision(() -> string(BigFloat(pi)), 1024)
p2 = setprecision(() -> string(BigFloat(pi)), 4096)
ok("π@1024 bits is a prefix of π@4096 bits (convergent with a modulus)",
   startswith(p2, p1[1:250]))
println("    π = $(p1[1:44])…")
println("    a computable real is not a value but a LAW: give me n, I give")
println("    you n digits. π, e, √2 are laws; almost all of ℝ is lawless.")

# --- P5 -----------------------------------------------------------
println("P5  the boundary: the diagonal against any halting oracle (WITNESS)")
# emergence_00's construction, typed: given any putative halts(), build
# the defeater. We exhibit the construction as a value; Turing 1936 is
# the citation for why no halts() exists for it to defeat.
defeater(halts::Function) = () -> halts(defeater(halts)) ? (while true end) : nothing
ok("the defeater is constructible (a value of type Function)",
   defeater(f -> true) isa Function)
println("    Ω (Chaitin) is a definite real in [0,1] no program approximates;")
println("    rand() cannot sample the reals not because its lattice is coarse")
println("    but because almost all targets have no address to sample AT.")

# --- P6 -----------------------------------------------------------
println("P6  two randomness sources, one predicate: REPLAYABLE")
s1 = rand(Random.Xoshiro(42), 1000)
s2 = rand(Random.Xoshiro(42), 1000)
ok("Xoshiro(42) replays exactly — algorithmic chance is memory", s1 == s2)
d1 = [rand(Random.RandomDevice(), UInt64) for _ in 1:4]
d2 = [rand(Random.RandomDevice(), UInt64) for _ in 1:4]
ok("RandomDevice does not replay — order imported from physics", d1 != d2)
println("    the emergence files' tick debt ('schedules come from our RNG,")
println("    not from the world' — _02 §IV, unpaid through _09) and this")
println("    file's question are the same debt: order that the system")
println("    consumes but does not generate. Replayable order = simulation;")
println("    non-replayable order = a loan from outside. Whether the")
println("    OUTSIDE's order is itself a subtler RANDU — the universe's")
println("    lattice planes awaiting their integrand — no inside court")
println("    can say. Priced; not paid; named.")

println()
println(exitcode == 0 ?
  "ALL PASS — i is exact, ℝ is the imaginary one; and time and randomness\n" *
  "enter every world here through the same door, marked EXOGENOUS." :
  "BUILD FAILED")
exit(exitcode)
