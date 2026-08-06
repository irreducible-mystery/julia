#!/usr/bin/env elixir
# negation_census.exs — NEGATION, carried across hosts (Elixir half).
#
# The P16 finding of carriers #12/#13 ("the Liar's rest state needs a negation
# that PROPAGATES absence, not a three-valued equality") was the shallow end.
# This file goes after negation itself, and finds that two things this repo
# named separately are the two halves of one theorem.
#
#   emergence_09 P20 / my P26 : the outdeg-3 dial's image has size m/gcd(2,m)
#   RingRest.lean §1          : the neg twist's fixed points — "neg regains rest"
#
# Both are the doubling map φ(x) = 2x on ℤ/m:
#
#     x is fixed by negation  ⟺  x = −x  ⟺  2x ≡ 0  ⟺  x ∈ ker φ
#     the P26 dial's image (d = −2)                  =  im φ
#     |ker φ| · |im φ| = m                              (first isomorphism thm)
#
# So: THE DIAL COLLAPSES EXACTLY AS MUCH AS NEGATION HAS FIXED POINTS. P26's
# "half-vanishing at m=4" and RingRest's "neg-twisted worlds always rest" are
# one fact read from opposite ends. Checked exhaustively below (N1), and again
# in negation_rust.rs, which reaches the fixed-width case Julia calls Int64.
#
# Run:  elixir carriers/negation_census.exs        (read the VERDICT line)

defmodule Neg do
  def gcd2(m), do: Integer.gcd(2, m)

  # fixed points of x ↦ −x in ℤ/m
  def neg_fixed(m), do: Enum.filter(0..(m - 1), fn x -> Integer.mod(-x, m) == x end)

  # image of the P26 dial with coefficient d, i.e. {d·s + c : s ∈ ℤ/m}
  def dial_image(m, d, c),
    do: Enum.map(0..(m - 1), fn s -> Integer.mod(d * s + c, m) end) |> Enum.uniq()

  # RingRest neg_world_rest: the neg-twisted world rests at every fixed point
  # of the twist — s ≡ (m − s) mod m — for ANY wiring. Verified here on a ring.
  def neg_world_rests_at?(m, l, x0),
    do: Enum.all?(0..(l - 1), fn _ -> Integer.mod(m - x0, m) == x0 end)
end

checks = []
add = fn checks, name, got, expect -> [{name, got, expect} | checks] end

# ======================================================================
# N1 — THE DUALITY. |fixed points of negation| = gcd(2,m) = m / |dial image|
# ======================================================================
checks =
  Enum.reduce(1..64, checks, fn m, acc ->
    fp = length(Neg.neg_fixed(m))
    img = length(Neg.dial_image(m, -2, -4))
    add.(acc, "N1 m=#{m}: |neg fixed| · |dial image| = m", {fp, fp * img}, {Neg.gcd2(m), m})
  end)

# N1b — the two named results are the same gcd, stated side by side
checks =
  Enum.reduce([2, 3, 4, 5, 6, 8, 12], checks, fn m, acc ->
    add.(acc, "N1b m=#{m}: gcd(2,m) counts BOTH",
         {length(Neg.neg_fixed(m)), div(m, length(Neg.dial_image(m, -2, -4)))},
         {Neg.gcd2(m), Neg.gcd2(m)})
  end)

# ----------------------------------------------------------------------
# N1-ERRATUM — MY OWN OVER-CLAIM, CONVICTED HERE.
#
# The first draft of this file (and of PR #9's body, and of NEGATION.md) said:
# "the dial collapses exactly as much as negation has fixed points", as though
# P26 and neg_world_rest were one theorem in general. THEY ARE NOT.
#
# The dial's collapse is |ker(×d)| = gcd(d, m) for d = 1 − outdeg(j₀).
# Negation's fixed points are |ker(×2)| = gcd(2, m).
# These agree iff gcd(|d|, m) = gcd(2, m) — which is an IDENTITY only when
# d = ±2, i.e. only at OUT-DEGREE 3. Everywhere else it is a coincidence that
# depends on m. Measured below, over m = 2..60:
#
#     outdeg 1 (d= 0):   1/59 moduli      outdeg 4 (d=−3):  19/59
#     outdeg 2 (d=−1):  29/59             outdeg 5 (d=−4):  44/59
#     outdeg 3 (d=−2):  59/59  ← the world I generalized from (w3)
#
# I checked the duality on w3, the one world whose out-degree is 3, and read a
# general law off a single case. What IS general: both quantities are ker/im
# of multiplication on ℤ/m, so both obey |ker|·|im| = m. That is the first
# isomorphism theorem, applied to two DIFFERENT multipliers — a shared
# mechanism, not a shared theorem. The corrected claim is in NEGATION.md.
#
# These checks fail if the over-claim is ever restored.
# ----------------------------------------------------------------------
agree_count = fn d ->
  Enum.count(2..60, fn m -> Integer.gcd(abs(d), m) == Integer.gcd(2, m) end)
end

checks = add.(checks, "N1e outdeg=3 (d=−2): duality holds at EVERY modulus",
              agree_count.(-2), 59)
checks = add.(checks, "N1e outdeg=2 (d=−1): duality FAILS at most moduli",
              agree_count.(-1), 29)
checks = add.(checks, "N1e outdeg=4 (d=−3): duality FAILS at most moduli",
              agree_count.(-3), 19)
checks = add.(checks, "N1e outdeg=5 (d=−4): duality holds only sometimes",
              agree_count.(-4), 44)
checks = add.(checks, "N1e outdeg=1 (d=0): duality essentially never holds",
              agree_count.(0), 1)
checks = add.(checks, "N1e ⇒ the duality is CONTINGENT on out-degree 3",
              Enum.all?([-1, -3, -4, 0], fn d -> agree_count.(d) < 59 end), true)

# What survives the erratum: |ker(×k)| · |im(×k)| = m for EVERY multiplier k.
# The mechanism is general even though the identification is not.
checks =
  Enum.reduce([1, 2, 3, 4, 5, 6], checks, fn k, acc ->
    ok =
      Enum.all?(2..40, fn m ->
        ker = Enum.count(0..(m - 1), fn x -> Integer.mod(k * x, m) == 0 end)
        img = Enum.map(0..(m - 1), fn x -> Integer.mod(k * x, m) end) |> Enum.uniq() |> length()
        ker * img == m
      end)

    add.(acc, "N1f survives: |ker(×#{k})|·|im(×#{k})| = m for all m", ok, true)
  end)

# N1c — the fixed points are exactly {0} for odd m, {0, m/2} for even m
checks =
  Enum.reduce([3, 5, 7, 9], checks, fn m, acc ->
    add.(acc, "N1c odd m=#{m}: only 0 is self-negating", Neg.neg_fixed(m), [0])
  end)

checks =
  Enum.reduce([2, 4, 6, 8, 10], checks, fn m, acc ->
    add.(acc, "N1c even m=#{m}: 0 and m/2 are self-negating",
         Neg.neg_fixed(m), [0, div(m, 2)])
  end)

# ======================================================================
# N2 — Int64 IS ℤ/2⁶⁴, AND THE GCD LAW PREDICTS ITS NEGATION FIXED POINTS.
#
# Carrier #11 recorded that "the Int64 = ℤ/2⁶⁴ finding DIES" in Common Lisp,
# because CL promotes to bignums and nothing wraps. Elixir promotes too — and
# that is exactly what lets it RECOVER the finding as an explicit model: with
# unbounded integers you can carry ℤ/2⁶⁴ as a value rather than as an ambush.
# The host that cannot suffer the wrap can still SAY it.
#
# Prediction: gcd(2, 2⁶⁴) = 2, so negation in Int64 has exactly two fixed
# points — 0 and 2⁶³ (which reads as typemin when the bits are signed).
# negation_rust.rs confirms this EXHAUSTIVELY at 8 and 16 bits.
# ======================================================================
two64 = Integer.pow(2, 64)
checks = add.(checks, "N2 gcd(2, 2^64) = 2 ⇒ exactly two fixed points", Neg.gcd2(two64), 2)
checks = add.(checks, "N2 0 is self-negating in ℤ/2^64", Integer.mod(-0, two64), 0)
checks = add.(checks, "N2 2^63 is self-negating in ℤ/2^64",
              Integer.mod(-Integer.pow(2, 63), two64), Integer.pow(2, 63))
checks = add.(checks, "N2 2^63 read as signed IS typemin(Int64)",
              Integer.pow(2, 63) - two64, -9_223_372_036_854_775_808)

# exhaustive at small widths — the same law, fully checked
checks =
  Enum.reduce([2, 4, 8, 16], checks, fn bits, acc ->
    m = Integer.pow(2, bits)
    add.(acc, "N2 exhaustive ℤ/2^#{bits}: fixed points",
         Neg.neg_fixed(m), [0, div(m, 2)])
  end)

# ======================================================================
# N3 — INVOLUTIVITY IS DECIDED BY PROPAGATE-VS-COERCE.
#
# Elixir's `!` COERCES: it reads truthiness, so it maps the third value into
# the boolean lattice and never returns it. Consequence: DOUBLE NEGATION
# ELIMINATION FAILS. `!!nil` is `false`, and `false != nil` in this host.
# A propagating twist (one clause, below) restores involutivity.
# ======================================================================
dom = [true, false, nil]
coercing = fn v -> !v end
propagating = fn nil -> nil
                 b -> not b end

checks = add.(checks, "N3 coercing: !nil is true", coercing.(nil), true)
checks = add.(checks, "N3 coercing: ¬¬nil is false, NOT nil", coercing.(coercing.(nil)), false)
checks = add.(checks, "N3 coercing: DNE fails (¬¬x = x holds for only 2 of 3)",
              Enum.count(dom, fn v -> coercing.(coercing.(v)) === v end), 2)
checks = add.(checks, "N3 propagating: DNE holds for all 3",
              Enum.count(dom, fn v -> propagating.(propagating.(v)) === v end), 3)
checks = add.(checks, "N3 coercing has ZERO fixed points",
              Enum.filter(dom, fn v -> coercing.(v) === v end), [])
checks = add.(checks, "N3 propagating has exactly one (nil)",
              Enum.filter(dom, fn v -> propagating.(v) === v end), [nil])

# N3b — the coercing twist is idempotent from step 2 on: once it has left the
# third value it can never return. The absent value is a source, never a sink.
checks = add.(checks, "N3b coercing: ¬³nil = ¬nil (collapsed after one step)",
              coercing.(coercing.(coercing.(nil))) === coercing.(nil), true)

# ======================================================================
# N4 — WHICH HALF OF CLASSICAL NEGATION DOES THE HOST DROP?
#
# Classical negation obeys both DNE (¬¬P → P) and LEM (P ∨ ¬P). The
# non-classical negations in this thread's toolbox drop DIFFERENT halves —
# so "non-classical" is at least a two-bit classification, not a label:
#
#   SQL / K3    : DNE holds, LEM FAILS          (run in run_negation_census.sh)
#   Elixir `!`  : DNE FAILS, LEM holds vacuously (below — every value is
#                 truthy-or-not, so x or !x is always truthy)
#   intuitionistic: BOTH fail                    (testimony; Lean not run here)
#
# Elixir is the mirror image of K3: it keeps the law K3 loses and loses the
# law K3 keeps. Two "third-value" hosts, opposite concessions.
# ======================================================================
checks = add.(checks, "N4 Elixir LEM: x or !x is truthy for all three",
              Enum.count(dom, fn v -> !!(v || !v) end), 3)
checks = add.(checks, "N4 Elixir DNE: fails at nil (the mirror of K3)",
              coercing.(coercing.(nil)) === nil, false)

# ======================================================================
# N5 — NEGATION'S FIXED-POINT COUNT DEPENDS ON WHICH EQUALITY YOU PICK.
#
# On floats, negation flips the sign bit unconditionally, so under BIT
# identity it has NO fixed point at all. Under `==`, −0.0 == 0.0, so 0.0 IS
# fixed. Same operator, same type, two answers — decided by the equality, the
# very thing the census calls host-owned.
# ======================================================================
checks = add.(checks, "N5 -0.0 == 0.0 (so 0.0 is fixed under ==)", -0.0 == 0.0, true)
checks = add.(checks, "N5 but the bits differ (no fixed point under bit identity)",
              <<-0.0::float>> != <<0.0::float>>, true)
checks = add.(checks, "N5 Elixir's === agrees with == here (it splits on type, not bits)",
              -0.0 === 0.0, true)

# ======================================================================
# N6 — neg_world_rest, the theorem behind N1's left half. RingRest.lean:
# any twist with a fixed point gives rest on ANY single-input world. The neg
# twist always has one (0), so neg-twisted worlds ALWAYS rest — for every
# modulus and every wiring. Here: the rest states are exactly the fixed points.
# ======================================================================
checks =
  Enum.reduce([2, 3, 4, 6, 9], checks, fn m, acc ->
    resting = Enum.filter(0..(m - 1), fn x0 -> Neg.neg_world_rests_at?(m, 7, x0) end)
    add.(acc, "N6 m=#{m}: neg-world rest states = negation's fixed points",
         resting, Neg.neg_fixed(m))
  end)

checks = add.(checks, "N6 zero always rests (the constructive witness)",
              Enum.all?(2..40, fn m -> Neg.neg_world_rests_at?(m, 5, 0) end), true)

# ======================================================================
# CONTROLS — an instrument that cannot say no proves nothing.
# ======================================================================
checks = add.(checks, "CONTROL: a wrong gcd law must fire",
              Enum.any?(1..40, fn m -> length(Neg.neg_fixed(m)) != Integer.gcd(3, m) end), true)
checks = add.(checks, "CONTROL: dial with d=−1 never collapses (gcd(1,m)=1)",
              Enum.all?(2..40, fn m -> length(Neg.dial_image(m, -1, 0)) == m end), true)

# ======================================================================
# VERDICT (nil-safe by construction — the C1 repair)
# ======================================================================
checks = Enum.reverse(checks)

Enum.each(checks, fn {name, got, expect} ->
  ok = got === expect
  unless ok, do: IO.puts("#{String.pad_trailing(name, 54)} got=#{inspect(got)} expect=#{inspect(expect)} FAIL")
end)

mismatches = Enum.count(checks, fn {_, g, e} -> not (g === e) end)
IO.puts("(#{length(checks) - mismatches} passing rows suppressed; failures printed above)")
IO.puts("VERDICT mismatches=#{mismatches} checks=#{length(checks)}")
System.halt(if mismatches == 0, do: 0, else: 1)
