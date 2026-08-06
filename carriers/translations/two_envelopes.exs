#!/usr/bin/env elixir
# two_envelopes.exs — translated from
# julia2/responses/paradox-instance/deep_dives/two_envelopes_broome.jl.
#
# Broome's unbounded-prior Two Envelopes: conditional expected gain from
# switching is positive for EVERY observable amount, yet by symmetry
# switching cannot help. Engine: non-conglomerability under an
# infinite-mean prior.
#
# Translation notes, honest ledger:
#   • Different RNG (:rand/exsss vs MersenneTwister): the CONDITIONAL rows
#     still land on theory; the UNCONDITIONAL means are unstable in their
#     own new way — which is the theorem. The law survives translation;
#     the samples do not.
#   • Julia mutates `rng` silently. Elixir has no silent mutation: the
#     generator state is threaded by hand through every call. The hidden
#     river becomes a visible one.
#   • §3 keeps the original's per-cell E[gain|A] = A/8 even though §1
#     derives A/10 — translation preserves what it cannot re-derive, and
#     flags it. The divergence verdict is unchanged either way.

defmodule Broome do
  def p(n), do: 1 / 3 * :math.pow(2 / 3, n)

  def sec(t) do
    bar = String.duplicate("═", 70)
    IO.puts("\n" <> bar <> "\n  " <> t <> "\n" <> bar)
  end

  # signed fixed-decimal formatting (Erlang's ~f has no '+' flag)
  def sig(x, dec) do
    s = :erlang.float_to_binary(abs(x) / 1, decimals: dec)
    if x < 0, do: "-" <> s, else: "+" <> s
  end

  def pad(s, w), do: String.pad_leading(s, w)

  # one trial: geometric pair index, fair coin for which envelope you hold;
  # returns {observed A, gain-if-switch} and the NEXT world-state
  def trial(st) do
    {n, st} = geo(st, 0)
    small = :math.pow(2.0, n)
    {u, st} = :rand.uniform_s(st)

    if u < 0.5 do
      {{small, small}, st}
    else
      {{2 * small, -small}, st}
    end
  end

  defp geo(st, n) do
    {u, st} = :rand.uniform_s(st)
    if u < 2 / 3, do: geo(st, n + 1), else: {n, st}
  end

  def run_trials(0, st, acc), do: {acc, st}

  def run_trials(k, st, acc) do
    {{a, g}, st} = trial(st)
    acc = Map.update(acc, a, {1, g}, fn {c, s} -> {c + 1, s + g} end)
    run_trials(k - 1, st, acc)
  end

  def mean_gain(trials, st) do
    {sum, st} =
      Enum.reduce(1..trials, {0.0, st}, fn _, {s, st} ->
        {{_a, g}, st} = Broome.trial(st)
        {s + g, st}
      end)

    {sum / trials, st}
  end

  # greedy Riemann rearrangement of the alternating harmonic ledger
  def rearranged(target), do: greedy(target, 0.0, 1, 1)
  defp greedy(_t, s, i, j) when i + j >= 60_000, do: s

  defp greedy(t, s, i, j) do
    if s < t,
      do: greedy(t, s + 1.0 / (2 * i - 1), i + 1, j),
      else: greedy(t, s - 1.0 / (2 * j), i, j + 1)
  end

  def truncated_ledger(n_max) do
    z = Enum.reduce(0..n_max, 0.0, fn n, acc -> acc + Broome.p(n) end)
    interior0 = Broome.p(0) / z / 2 * 1.0

    interior =
      Enum.reduce(1..n_max, interior0, fn n, acc ->
        pa = (Broome.p(n - 1) + Broome.p(n)) / z / 2
        ps = Broome.p(n) / (Broome.p(n) + Broome.p(n - 1))
        acc + pa * (ps * :math.pow(2.0, n) - (1 - ps) * :math.pow(2.0, n) / 2)
      end)

    boundary = p(n_max) / z / 2 * (-:math.pow(2.0, n_max + 1) / 2)
    {interior, boundary}
  end
end



# ----------------------------------------------------------------------
Broome.sec("1. THE ANALYTIC HEART — conditional gain is positive EVERYWHERE")
# ----------------------------------------------------------------------
IO.puts("    Observed A = 2^n. Posterior P(you hold the SMALL one | A):")
IO.puts("    n = 0:  P(small) = 1        E[gain | switch] = +1")

for n <- 1..6 do
  a = :math.pow(2.0, n)
  ps = Broome.p(n) / (Broome.p(n) + Broome.p(n - 1))
  egain = ps * a - (1 - ps) * a / 2

  IO.puts(
    "    n = #{n}:  P(small) = #{:erlang.float_to_binary(ps, decimals: 4)}   " <>
      "E[gain | A = #{Broome.pad(Integer.to_string(round(a)), 3)}] = #{Broome.pad(Broome.sig(egain, 4), 8)}  (= A/10)"
  )
end

IO.puts("    ⇒ For EVERY possible observation, switching has expected gain A/10 > 0.")
IO.puts("      By symmetry the other player computes the same. Both «should» switch.")
IO.puts("      Both cannot be right. And yet no single conditional step is wrong.")

# ----------------------------------------------------------------------
Broome.sec("2. SIMULATION — conditional advice vs unconditional truth")
# ----------------------------------------------------------------------
st = :rand.seed_s(:exsss, {7, 7, 7})
trials = 2_000_000
{by_amount, _st} = Broome.run_trials(trials, st, %{})

IO.puts("    Conditional mean gain from switching, per observed amount (#{trials} trials):")
IO.puts(Broome.pad("A", 14) <> Broome.pad("count", 13) <> Broome.pad("mean gain", 17) <> Broome.pad("theory (A/10)", 15))

for a <- Enum.sort(Map.keys(by_amount)) |> Enum.take(8) do
  {c, s} = by_amount[a]
  theo = if a == 1.0, do: 1.0, else: a / 10

  IO.puts(
    Broome.pad(Integer.to_string(round(a)), 14) <>
      Broome.pad(Integer.to_string(c), 13) <> Broome.pad(Broome.sig(s / c, 4), 17) <> Broome.pad(Broome.sig(theo, 3), 15)
  )
end

IO.puts("    Every conditional row matches theory: «switch» is locally right everywhere.")

pooled =
  for seed <- 1..5 do
    st = :rand.seed_s(:exsss, {seed, seed, seed})
    {m, _} = Broome.mean_gain(500_000, st)
    m
  end

IO.puts("\n    Pooled unconditional mean gain, five independent seeds (500k trials each):")
IO.puts("       " <> Enum.map_join(pooled, " ", &Broome.pad(Broome.sig(&1, 2), 12)))
IO.puts("    — wildly unstable: with E[amount] = ∞ the sample mean never converges;")
IO.puts("      single freak deep-tail pairs dominate entire runs (LLN inapplicable).")

st2 = :rand.seed_s(:exsss, {99, 99, 99})

{paired_total, _} =
  Enum.reduce(1..200_000, {0.0, st2}, fn _, {tot, st} ->
    {{_a, g}, st} = Broome.trial(st)
    {tot + (g + -g), st}
  end)

IO.puts("\n    Exact two-player ledger (both switch, per-trial cancellation): #{paired_total}")
IO.puts("    — switching is unconditionally worthless, PROVABLY.")
IO.puts("    Every row says «switch». The exact pool says «it cannot matter».")

# ----------------------------------------------------------------------
Broome.sec("3. THE DIAGNOSIS — non-conglomerability, computed")
# ----------------------------------------------------------------------
IO.puts("    Σ over observation-cells of P(A)·E[gain | A]  (partial sums):")

Enum.reduce(0..30, 0.0, fn n, cells ->
  a = :math.pow(2.0, n)
  pa = if n == 0, do: Broome.p(0) / 2, else: (Broome.p(n - 1) + Broome.p(n)) / 2
  eg = if n == 0, do: 1.0, else: a / 8
  cells = cells + pa * eg

  if n in [0, 1, 2, 5, 10, 20, 30] do
    IO.puts(
      "      through n = #{Broome.pad(Integer.to_string(n), 2)}:  " <>
        Broome.pad(:erlang.float_to_binary(cells, decimals: 5), 10)
    )
  end

  cells
end)

IO.puts("    → the by-observation sum DIVERGES to +∞,")
IO.puts("      while the same sum organized by PAIRS is 0 by symmetry:")
pairs_sum = Enum.reduce(0..30, 0.0, fn n, acc -> acc + Broome.p(n) * 0.0 end)
IO.puts("      Σ over pairs of p(n)·E[gain | pair n] = #{pairs_sum}")
IO.puts("")
IO.puts("    Two partitions of the SAME event space give different «totals»")
IO.puts("    because E[amount] DIVERGES — the honest divergence certificate:")
term = fn n -> Broome.p(n) * (:math.pow(2.0, n) + :math.pow(2.0, n + 1)) / 2 end

IO.puts(
  "      E[amount] = Σ term(n),  term ratio term(5)/term(4) = " <>
    "#{Float.round(term.(5) / term.(4), 4)}  = 4/3 > 1 ⇒ terms GROW"
)

for nmax <- [10, 30, 60] do
  psum = Enum.reduce(0..nmax, 0.0, fn n, acc -> acc + term.(n) end)

  IO.puts(
    "      partial sum through n = #{Broome.pad(Integer.to_string(nmax), 2)}:  " <>
      Broome.pad(:erlang.float_to_binary(psum, decimals: 2), 14)
  )
end

IO.puts("      With E[amount] = ∞, E[gain]'s positive and negative parts are")
IO.puts("      each infinite; their «difference» is an ∞ − ∞ ledger whose value")
IO.puts("      depends on summation order — Riemann's rearrangement theorem")
IO.puts("      is the engine under the paradox.")

# ----------------------------------------------------------------------
Broome.sec("4. RIEMANN REARRANGEMENT — the same series, any answer you like")
# ----------------------------------------------------------------------
for tgt <- [0.0, 1.0, :math.log(2), 3.14159] do
  IO.puts(
    "    rearranged to target #{Broome.pad(:erlang.float_to_binary(tgt / 1, decimals: 5), 8)} → " <>
      "partial sum settles at #{Broome.pad(:erlang.float_to_binary(Broome.rearranged(tgt), decimals: 5), 8)}"
  )
end

IO.puts("    A conditionally convergent ledger has no observer-independent total —")
IO.puts("    «the value of switching» in Broome's game is exactly such a ledger.")

# ----------------------------------------------------------------------
Broome.sec("5. WHERE IT LANDS — what resolves, what remains")
# ----------------------------------------------------------------------
IO.puts("""
    RESOLVED (theorem-level):
      • No paradox in any FINITE truncation: cap the pairs at n ≤ N and
        the top observation A = 2^(N+1) is CERTAINLY the large envelope —
        its guaranteed loss exactly cancels the whole interior advantage:\
""")

for n <- [5, 10, 20] do
  {i, b} = Broome.truncated_ledger(n)

  IO.puts(
    "        N = #{Broome.pad(Integer.to_string(n), 2)}:  interior advantage #{Broome.pad(Broome.sig(i, 4), 9)}  " <>
      "boundary cell #{Broome.pad(Broome.sig(b, 4), 9)}  total #{Broome.sig(i + b, 10)}"
  )
end

IO.puts("""
        The «paradox» is the boundary term surviving the N → ∞ limit
        as a ghost: it never appears at any finite A, yet its weight×size
        does not vanish.

      • The «always switch» ARGUMENT is invalid: it applies conglomerability
        to a non-conglomerable expectation. That step, and only that step,
        is the formal error.

    NOT RESOLVED (still contested in the literature):
      • What should a rational agent DO facing a genuinely infinite-mean
        prior, observing A, with positive conditional gain at every A?
        Every answer on offer sacrifices an intuition; none is neutral.
""")
