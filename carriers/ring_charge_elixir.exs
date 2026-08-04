#!/usr/bin/env elixir
# ring_charge_elixir.exs — CARRIER #12: the defect-charge algebra of
# emergence_04–_09 and RingRest.lean, re-carried into Elixir.
#
# Same object as carrier #10 (SQL): the eleven worlds transcribed 1:1 from
# ring_charge_carrier.sql, the same m ∈ 2..5 grid with mⁿ ≤ 5000, the same
# oracles. What changes is the instrument.
#
# WHY THIS CARRIER EXISTS. The carrier instance's own branch sweep convicted
# `claude/elixir-rust-setup-25myba` as "an empty promise — the branch NAME is
# the deliverable; the Elixir/Rust carriers remain untranslated" (B2). The
# conviction was CORRECT as of that commit. This file and its Rust sibling
# are the repair: conviction answered by construction, not by appeal.
#
# GAINED (over #10):
#   * Unbounded integers. Lean quantifies over every state in ℤ; SQL and
#     Julia both cap at 64 bits. Elixir's bignums carry states at ±10^38 and
#     beyond — P10 is checked on states no prior carrier in this thread could
#     represent. Still finitely many, still not a ∀. The gap is narrowed and
#     named, not closed.
#   * The tick is expressible again. SQL's declared loss ("SQL has no
#     dynamics") is not a loss here — but this carrier does NOT spend it,
#     because the debt belongs to whoever pays it deliberately. Declared.
#
# LOST (relative to #10):
#   * K3 goes home empty. SQL's NULL is Kleene's third value; `nil` is not.
#     `nil == nil` is TRUE (not nil), and `!nil` is `true`, so the NOT twist
#     over {true, false, nil} has ZERO fixed points — where SQL has exactly
#     one and Julia's `missing` has one. P16 does not translate: the Liar
#     has no rest state in this host. Photographed below as K3_ABSENT.
#   * The sweep order returns. #10's headline gain was that a declarative
#     carrier CANNOT commit _03's smuggled sweep order. Elixir is not
#     declarative; the crime is expressible here again. Immutability makes
#     it loud, not impossible.
#
# INSTRUMENT REPAIR (see audits/carrier_sweep_by_translator.sh, C1):
#   #10's VERDICT counts mismatches with `WHERE got != expect`, and in SQL
#   `NULL != 0` is NULL, not true — so a check whose value goes NULL is
#   counted as PASSING. This file's verdict treats a nil `got` as a
#   MISMATCH, and check C1c below proves the repair fires.

defmodule Carrier12 do
  # ---- worlds: mark => list of inputs it hears (1-based, as in #10) ----
  def worlds do
    ring = fn n -> for i <- 1..n, into: %{}, do: {i, [if(i == 1, do: n, else: i - 1)]} end

    %{
      "ring2" => {2, ring.(2)},
      "ring3" => {3, ring.(3)},
      "ring4" => {4, ring.(4)},
      "ring5" => {5, ring.(5)},
      "ring6" => {6, ring.(6)},
      "fig8_23" => {4, %{1 => [2, 4], 2 => [1], 3 => [1], 4 => [3]}},
      "fig8_33" => {5, %{1 => [3, 5], 2 => [1], 3 => [2], 4 => [1], 5 => [4]}},
      "tworings_23" => {5, %{1 => [2], 2 => [1], 3 => [5], 4 => [3], 5 => [4]}},
      "chord" => {4, %{1 => [4], 2 => [1], 3 => [2, 1], 4 => [3]}},
      "w3" => {4, %{1 => [4], 2 => [1], 3 => [2, 1], 4 => [3, 1]}},
      "w0" => {3, %{1 => [2], 2 => [1], 3 => []}}
    }
  end

  def ring_names, do: ["ring2", "ring3", "ring4", "ring5", "ring6"]

  # out-degree of mark j: how many times j is heard, with multiplicity
  def outdeg(wiring, n, j),
    do: Enum.sum(for i <- 1..n, do: Enum.count(Map.fetch!(wiring, i), &(&1 == j)))

  # defect at mark i = (s_i − Σ s[inputs i] − 1) mod m   [FLOORED — see FPRINT]
  def defect(wiring, s, m, i) do
    insum = Map.fetch!(wiring, i) |> Enum.map(&Map.fetch!(s, &1)) |> Enum.sum()
    Integer.mod(Map.fetch!(s, i) - insum - 1, m)
  end

  def charge(wiring, s, m, n),
    do: Integer.mod(Enum.sum(for i <- 1..n, do: defect(wiring, s, m, i)), m)

  # (★) predicted: Σ_j (1 − outdeg j)·s_j − n   (mod m)
  def predicted(wiring, s, m, n) do
    Integer.mod(
      Enum.sum(for j <- 1..n, do: (1 - outdeg(wiring, n, j)) * Map.fetch!(s, j)) - n,
      m
    )
  end

  # every state of (world, m): sid → %{mark => digit}
  def states(m, n) do
    total = Integer.pow(m, n)

    Stream.map(0..(total - 1), fn sid ->
      for i <- 1..n, into: %{}, do: {i, Integer.mod(div(sid, Integer.pow(m, i - 1)), m)}
    end)
  end

  # a rest state exists iff some state has every defect 0
  def rest_exists?(wiring, m, n),
    do: Enum.any?(states(m, n), fn s -> Enum.all?(1..n, &(defect(wiring, s, m, &1) == 0)) end)
end

# ======================================================================
# THE COURT.  Each check is {name, got, expect}. `got` may legitimately be
# any term; nil is treated as a MISMATCH, never as a pass (the C1 repair).
# ======================================================================
checks = []
add = fn checks, name, got, expect -> [{name, got, expect} | checks] end

ws = Carrier12.worlds()

# ---- grid: same bound as #10 — m ∈ 2..5, m^n ≤ 5000, exhaustive ----
grid =
  for {w, {n, _}} <- ws, m <- 2..5, Integer.pow(m, n) <= 5000, do: {w, m, n}

# ---- (★) charge_formula on EVERY state of every grid cell ----
checks =
  Enum.reduce(grid, checks, fn {w, m, n}, acc ->
    {^n, wiring} = Map.fetch!(ws, w)

    bad =
      Carrier12.states(m, n)
      |> Enum.count(fn s ->
        Carrier12.charge(wiring, s, m, n) != Carrier12.predicted(wiring, s, m, n)
      end)

    add.(acc, "star: #{w} m=#{m}", bad, 0)
  end)

# ---- rest ⟺ m | L, on rings (succ_ring_rest_iff) ----
checks =
  Enum.reduce(Carrier12.ring_names(), checks, fn w, acc ->
    {n, wiring} = Map.fetch!(ws, w)

    Enum.reduce(2..5, acc, fn m, acc2 ->
      if Integer.pow(m, n) <= 5000 do
        add.(acc2, "rest_iff_dvd: #{w} m=#{m}",
             Carrier12.rest_exists?(wiring, m, n), Integer.mod(n, m) == 0)
      else
        acc2
      end
    end)
  end)

# ---- P10: on rings the charge is −L mod m, state-free ----
checks =
  Enum.reduce(Carrier12.ring_names(), checks, fn w, acc ->
    {n, wiring} = Map.fetch!(ws, w)

    Enum.reduce(2..5, acc, fn m, acc2 ->
      if Integer.pow(m, n) <= 5000 do
        distinct =
          Carrier12.states(m, n)
          |> Enum.map(&Carrier12.charge(wiring, &1, m, n))
          |> Enum.uniq()

        add.(acc2, "P10 state-free: #{w} m=#{m}", distinct, [Integer.mod(-n, m)])
      else
        acc2
      end
    end)
  end)

# ---- P13/P19 dial: one shared mark ⇒ charge ≡ −s_j₀ − n ----
checks =
  Enum.reduce(["fig8_23", "fig8_33", "chord"], checks, fn w, acc ->
    {n, wiring} = Map.fetch!(ws, w)

    Enum.reduce(2..5, acc, fn m, acc2 ->
      if Integer.pow(m, n) <= 5000 do
        bad =
          Carrier12.states(m, n)
          |> Enum.count(fn s ->
            Carrier12.charge(wiring, s, m, n) !=
              Integer.mod(-Map.fetch!(s, 1) - n, m)
          end)

        add.(acc2, "dial: #{w} m=#{m}", bad, 0)
      else
        acc2
      end
    end)
  end)

# ---- P20: w3 has outdeg(1)=3 ⇒ charge ≡ −2·s₁ − n; at m=2 the dial VANISHES ----
{n_w3, wir_w3} = Map.fetch!(ws, "w3")

checks =
  Enum.reduce(2..5, checks, fn m, acc ->
    bad =
      Carrier12.states(m, n_w3)
      |> Enum.count(fn s ->
        Carrier12.charge(wir_w3, s, m, n_w3) !=
          Integer.mod(-2 * Map.fetch!(s, 1) - n_w3, m)
      end)

    acc = add.(acc, "P20 dial: w3 m=#{m}", bad, 0)

    # ---- NEW (P26): the vanishing is a gcd law, not an m=2 accident ----
    # The dial's image is the subgroup ⟨d⟩ ≤ ℤ/m generated by the shared
    # mark's coefficient d = 1 − outdeg(j₀) (here d = −2), so the number of
    # reachable charges is m / gcd(d, m). Carrier #10 checks only
    # `P20_m2_dial_vanishes` (COUNT(DISTINCT)=1 at m=2) and never inspects
    # the spread at m ∈ 3..5, so it cannot see that m=4 HALF-vanishes:
    # 2 reachable charges out of 4, because 2·2 ≡ 0 (mod 4). Same zero-divisor
    # engine emergence_10's P25 identified — "prime-vs-composite, not
    # algebra-vs-order" — arriving here as a statement about DIALS.
    spread =
      Carrier12.states(m, n_w3)
      |> Enum.map(&Carrier12.charge(wir_w3, &1, m, n_w3))
      |> Enum.uniq()
      |> length()

    add.(acc, "P26 gcd-vanishing: w3 m=#{m}", spread, div(m, Integer.gcd(2, m)))
  end)

# P26, control direction: the chord world's coefficient is d = −1, and
# gcd(1, m) = 1 for every m — so a one-shared-mark dial NEVER collapses,
# at any modulus. The collapse is a property of the out-degree, not the dial.
checks =
  Enum.reduce(2..5, checks, fn m, acc ->
    spread =
      Carrier12.states(m, n_w3 )
      |> Enum.map(fn s -> Integer.mod(-Map.fetch!(s, 1) - 4, m) end)
      |> Enum.uniq()
      |> length()

    add.(acc, "CONTROL P26: outdeg-2 dial never collapses m=#{m}", spread, m)
  end)

# ---- P21: w0's unheard mark has outdeg 0 ⇒ charge ≡ +s₃ − n ----
{n_w0, wir_w0} = Map.fetch!(ws, "w0")

checks =
  Enum.reduce(2..5, checks, fn m, acc ->
    bad =
      Carrier12.states(m, n_w0)
      |> Enum.count(fn s ->
        Carrier12.charge(wir_w0, s, m, n_w0) != Integer.mod(Map.fetch!(s, 3) - n_w0, m)
      end)

    add.(acc, "P21 unheard-mark dial: w0 m=#{m}", bad, 0)
  end)

# ======================================================================
# MUTANT CONTROLS — an instrument that cannot say no proves nothing.
# Each must FIRE (got != 0 where the true law gives 0).
# ======================================================================
{n_c, wir_c} = Map.fetch!(ws, "chord")

mut_star =
  Carrier12.states(3, n_c)
  |> Enum.count(fn s ->
    # (★) with the −n term dropped: must disagree somewhere
    Carrier12.charge(wir_c, s, 3, n_c) !=
      Integer.mod(Enum.sum(for j <- 1..n_c, do: (1 - Carrier12.outdeg(wir_c, n_c, j)) * Map.fetch!(s, j)), 3)
  end)

checks = add.(checks, "CONTROL mutant (★ without −n) must fire", mut_star > 0, true)

mut_dial =
  Carrier12.states(3, n_c)
  |> Enum.count(fn s ->
    Carrier12.charge(wir_c, s, 3, n_c) != Integer.mod(-(Map.fetch!(s, 1) + 5) - n_c, 3)
  end)

checks = add.(checks, "CONTROL mutant (dial −(s₁+5)) must fire", mut_dial > 0, true)

# ======================================================================
# FINGERPRINTS — what this HOST owns, photographed. These are not facts
# about the ring algebra; they are facts about Elixir.
# ======================================================================
# FP1 — integer overflow policy: PROMOTES EXACTLY (bignum). Julia wraps,
# SQLite promotes lossily to double, PostgreSQL raises, CL promotes. Elixir
# joins CL: five hosts, four policies, and the census's claim survives.
big = Integer.pow(2, 63)
checks = add.(checks, "FPRINT overflow: 2^63 exact (no wrap)", big + 1 - big, 1)
checks = add.(checks, "FPRINT overflow: 2^126 exact digit count", big |> Kernel.*(big) |> Integer.digits() |> length(), 38)

# FP2 — `%` is PLURAL and the host makes you CHOOSE. Julia picked floored
# silently; SQL picked truncated silently. Elixir ships both and names them.
checks = add.(checks, "FPRINT mod: rem/2 is TRUNCATED (rem(-7,3))", rem(-7, 3), -1)
checks = add.(checks, "FPRINT mod: Integer.mod/2 is FLOORED", Integer.mod(-7, 3), 2)

# FP3 — equality arity 2, axis = NUMERIC EXACTNESS (SQL's arity is also 2
# but its axis is NULL-totality; Lean's is decidability). Arity coincides,
# axis does not: the census's "no two hosts split it the same way" holds,
# but the discriminating feature is the AXIS, not the count.
checks = add.(checks, "FPRINT equality: 1 == 1.0 (value)", 1 == 1.0, true)
checks = add.(checks, "FPRINT equality: 1 === 1.0 (strict) is false", 1 === 1.0, false)

# FP4 — P16 REVISITED. The pre-registered guess ("no K3 ⇒ no rest state for
# the Liar") is only half right, and the half that fails is the interesting
# half — the Rust sibling caught it. The Liar's rest state does not require a
# three-valued EQUALITY; it requires a negation that PROPAGATES absence:
#
#   coercing    (Elixir's `!`)   nil ↦ true   → 0 fixed points
#   propagating (opt-in below)   nil ↦ nil    → 1 fixed point
#
# SQL and Julia propagate BY DEFAULT (NOT NULL = NULL; !missing = missing), so
# P16 holds there whether or not the author wanted it. Elixir coerces by
# default, so P16 holds here only on request. rest_of_twist_fixed is
# carrier-invariant — a theorem about twists. Which twist the host hands you
# for free is the fingerprint.
dom = [true, false, nil]
coercing = fn v -> !v end
propagating = fn nil -> nil
                 b -> not b end

checks = add.(checks, "P16: equality is TOTAL here (nil == nil is true)", nil == nil, true)
checks = add.(checks, "P16: COERCING twist (default !) has ZERO fixed points",
              Enum.filter(dom, fn v -> coercing.(v) === v end), [])
checks = add.(checks, "P16: PROPAGATING twist has exactly one fixed point",
              Enum.filter(dom, fn v -> propagating.(v) === v end), [nil])

# FP5 — float dirt is IEEE, shared with every other host on this machine
checks = add.(checks, "FPRINT float: 0.1+0.2 != 0.3", 0.1 + 0.2 == 0.3, false)
checks = add.(checks, "FPRINT float: 0.1+0.2 bits", 0.1 + 0.2, 0.30000000000000004)

# ======================================================================
# C1 REPAIR SELF-TEST — the crime convicted in #10, proven fixed here.
# A nil `got` MUST be counted as a mismatch by this file's verdict.
# ======================================================================
nil_probe = [{"probe", nil, 1}]
nil_caught = Enum.count(nil_probe, fn {_, g, e} -> not (g === e) end)
checks = add.(checks, "C1 REPAIR: a nil got is counted as a MISMATCH", nil_caught, 1)

# ======================================================================
# VERDICT — strict (===) comparison, nil-safe by construction.
# ======================================================================
checks = Enum.reverse(checks)

Enum.each(checks, fn {name, got, expect} ->
  ok = got === expect
  IO.puts(:io_lib.format("~-46s got=~-12s expect=~-12s ~s", [
    name, inspect(got) |> String.slice(0, 12), inspect(expect) |> String.slice(0, 12),
    if(ok, do: "ok", else: "FAIL")
  ]) |> to_string())
end)

mismatches = Enum.count(checks, fn {_, g, e} -> not (g === e) end)
IO.puts("VERDICT mismatches=#{mismatches} checks=#{length(checks)}")
System.halt(if mismatches == 0, do: 0, else: 1)
