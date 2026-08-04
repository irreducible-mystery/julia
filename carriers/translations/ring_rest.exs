#!/usr/bin/env elixir
# ring_rest.exs — translated from julia/emergence/lean/RingRest.lean.
#
# The Lean file PROVES; this file can only CHECK. Every ∀ below has become
# a for-loop, and a for-loop is a finite list of ∃. One place the runtime
# speaks about an unsearchable space (L = 701), it borrows the Lean theorem
# rest_iff_charge_zero — certainty imported, not manufactured here.
#
# What Elixir brings that Julia's sweeps could not: unbounded integers.
# The Lean comments taunt the sweeps with states "astronomically large,
# which no Julia sweep visits" — Elixir's bignums stroll in (still only
# finitely many of them).

defmodule RingRest do
  # IsFix m L s  ⇝  a decidable check on ONE concrete finite state
  def is_fix?(m, s) do
    n = tuple_size(s)
    Enum.all?(0..(n - 1), fn i ->
      v = elem(s, i)
      v < m and v == rem(elem(s, rem(i + 1, n)) + 1, m)
    end)
  end

  # dvd_imp_rest's constructive witness: s i = (L - i mod L) mod m
  def countdown(m, l),
    do: List.to_tuple(for i <- 0..(l - 1), do: rem(l - rem(i, l), m))

  # ∃ s, IsFix m L s  ⇝  exhaustion of [0,m)^L (the move Lean got to skip)
  def exists_rest?(m, l), do: search(m, List.duplicate(0, l))

  defp search(_m, nil), do: false
  defp search(m, digits) do
    if is_fix?(m, List.to_tuple(digits)), do: true, else: search(m, incr(digits, m))
  end

  defp incr([], _m), do: nil
  defp incr([d | t], m) when d + 1 < m, do: [d + 1 | t]
  defp incr([_ | t], m) do
    case incr(t, m) do
      nil -> nil
      t2 -> [0 | t2]
    end
  end

  # defect m L s i = (s i − s (prev i) − 1) mod m — Integer.mod is the
  # floored/mathematical mod, matching Lean's Int.emod for positive m.
  # (Elixir's rem/2 is truncated, like C. All five languages in this
  # exercise must privately decide what "%" means; Lean spent a comment
  # dodging Classical.choice over exactly this kind of care.)
  def defects(m, s) do
    n = tuple_size(s)
    for i <- 0..(n - 1) do
      Integer.mod(elem(s, i) - elem(s, rem(i + n - 1, n)) - 1, m)
    end
  end

  def defect_sum(m, s), do: Enum.sum(defects(m, s))

  # gaugeState L j — distance-from-j walking forward around the ring
  def gauge(l, j),
    do: List.to_tuple(for i <- 0..(l - 1), do: if(j <= i, do: i - j, else: i + l - j))

  # Section 3's fig8(2,3) wiring: mark 0 listens to both loop tails
  def fig8(0), do: [1, 3]
  def fig8(1), do: [0]
  def fig8(2), do: [0]
  def fig8(3), do: [2]

  def g_defect_sum(m, inputs, s, n) do
    Enum.reduce(0..(n - 1), 0, fn i, acc ->
      insum = inputs.(i) |> Enum.map(&elem(s, &1)) |> Enum.sum()
      acc + Integer.mod(elem(s, i) - insum - 1, m)
    end)
  end
end

bar = String.duplicate("─", 66)

IO.puts(bar)
IO.puts("1. succ_ring_rest_iff — the theorem, demoted back to the table")
IO.puts("   (L ∈ 2..9, m ∈ {2,3}: the exact cases Lean says Julia exhausted)")
IO.puts(bar)

for m <- [2, 3] do
  row =
    for l <- 2..9 do
      found = RingRest.exists_rest?(m, l)
      law = rem(l, m) == 0
      mark = if found == law, do: "✓", else: "✗"
      "L=#{l}:#{if found, do: "rest", else: "  — "}#{mark}"
    end
  IO.puts("   m=#{m}  " <> Enum.join(row, "  "))
end
IO.puts("   every cell agrees with the law  ∃ rest ⇔ L % m == 0")

IO.puts("\n" <> bar)
IO.puts("2. dvd_imp_rest — the constructive witness runs at sizes")
IO.puts("   exhaustion cannot reach (7^700 states; we check ONE)")
IO.puts(bar)

w = RingRest.countdown(7, 700)
IO.puts("   countdown state on (m=7, L=700): IsFix? #{RingRest.is_fix?(7, w)}")

IO.puts("\n" <> bar)
IO.puts("3. defect_sum_invariant — the charge refuses to move.")
IO.puts("   200 wild states each: negative, and ~10^38 in magnitude —")
IO.puts("   the states 'no Julia sweep visits'. Elixir bignums visit.")
IO.puts(bar)

:rand.seed(:exsss, {11, 13, 17})
big = Integer.pow(10, 38)

wild = fn l ->
  List.to_tuple(
    for _ <- 1..l do
      sign = if :rand.uniform() < 0.5, do: -1, else: 1
      sign * (:rand.uniform(9) * big + :rand.uniform(1_000_000))
    end
  )
end

for {m, l} <- [{3, 4}, {3, 8}, {2, 5}, {4, 6}, {3, 6}] do
  charges =
    for _ <- 1..200 do
      Integer.mod(RingRest.defect_sum(m, wild.(l)), m)
    end
    |> Enum.uniq()

  IO.puts(
    "   (m=#{m}, L=#{l})  charge over 200 wild states: #{inspect(charges)}" <>
      "   Lean predicts: #{Integer.mod(-l, m)}"
  )
end

IO.puts("\n" <> bar)
IO.puts("4. defect_gauge — blame is a choice, the total is a fact")
IO.puts(bar)

{m, l, j} = {5, 12, 7}
g = RingRest.gauge(l, j)
ds = RingRest.defects(m, g)
IO.puts("   gauge state (m=#{m}, L=#{l}, j=#{j}) defects: #{inspect(ds)}")
IO.puts("   only edge #{j} carries charge #{Enum.at(ds, j)} = -L mod m = #{Integer.mod(-l, m)}")

IO.puts("\n" <> bar)
IO.puts("5. charge_dial on fig8(2,3) — Section 3's example, sampled")
IO.puts(bar)

dial_ok =
  Enum.all?(1..200, fn _ ->
    s = wild.(4)
    lhs = Integer.mod(RingRest.g_defect_sum(3, &RingRest.fig8/1, s, 4), 3)
    rhs = Integer.mod(-elem(s, 0) - 4, 3)
    lhs == rhs
  end)

IO.puts("   charge ≡ −s₀ − 4 (mod 3) on 200 wild states: #{dial_ok}")

IO.puts("\n" <> bar)
IO.puts("6. Borrowed certainty — deciding ¬∃ where search cannot go")
IO.puts(bar)

{m, l} = {5, 701}
charge = Integer.mod(RingRest.defect_sum(m, wild.(l)), m)
IO.puts("   (m=5, L=701): 5^701 states — unsearchable. One state's charge: #{charge}")
IO.puts("   rest_iff_charge_zero (trusted from Lean, not re-proved here)")
IO.puts("   ⇒ #{if charge == 0, do: "a rest state exists", else: "NO rest state exists"}.")
IO.puts("   The runtime can now SAY it, but only because the kernel SAW it.")
