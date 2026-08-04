#!/usr/bin/env elixir
# setup.exs — translated from julia3claude/setup.sh.
#
# Installs the Julia and Lean toolchains on a sandboxed Linux x86_64 box
# whose egress allows github.com, conda.anaconda.org and the Ubuntu
# archive, but blocks the languages' own download hosts — so Julia comes
# from conda-forge via micromamba, and elan/Lean are side-loaded from
# GitHub release assets and registered with `elan toolchain link`.
#
# Translation notes, honest ledger:
#   • Bash edits the world in its own mother tongue; Elixir must QUOTE it:
#     every action below is a string handed to System.cmd("bash", ...).
#     The bash never left — it moved inside quotation marks.
#   • `set -euo pipefail` was ambient law in the original; here failure
#     handling is rebuilt by hand, one step at a time (see run_steps/2).
#   • What bash left implicit, the translation makes a data structure:
#     each step is {name, done?, command} — the idempotence check is now
#     first-class, and --dry-run (which the original does not have) falls
#     out for free: show every decision, touch nothing.

defmodule Setup do
  @lean_version System.get_env("LEAN_VERSION") || "4.32.2"
  @julia_env "/opt/julia-env"
  @lean_root "/opt/lean"

  defp exec?(name), do: System.find_executable(name) != nil

  defp file_contains?(path, needle) do
    case File.read(path) do
      {:ok, body} -> String.contains?(body, needle)
      _ -> false
    end
  end

  def steps do
    lean_dir = "#{@lean_root}/lean-#{@lean_version}-linux"

    [
      {"zstd (unpacks Lean's .tar.zst release assets)",
       fn -> exec?("zstd") end,
       "apt-get install -y zstd"},

      {"micromamba",
       fn -> exec?("micromamba") end,
       ~s{curl -sL -o /usr/local/bin/micromamba "https://github.com/mamba-org/micromamba-releases/releases/latest/download/micromamba-linux-64" && chmod +x /usr/local/bin/micromamba}},

      {"Julia via micromamba + conda-forge",
       fn -> File.exists?("#{@julia_env}/bin/julia") end,
       "micromamba create -y -r /opt/mamba -p #{@julia_env} -c conda-forge julia"},

      {"julia symlink on PATH",
       fn -> false end, # ln -sf is its own idempotence; bash ran it unconditionally
       "ln -sf #{@julia_env}/bin/julia /usr/local/bin/julia"},

      {"JULIA_PKG_SERVER=\"\" in .bashrc (Pkg falls back to GitHub clones)",
       fn -> file_contains?("/root/.bashrc", "JULIA_PKG_SERVER") end,
       ~s{echo 'export JULIA_PKG_SERVER=""' >> /root/.bashrc}},

      {"elan (installed with --default-toolchain none)",
       fn -> File.exists?("/root/.elan/bin/elan") end,
       ~s{tmp=$(mktemp -d) && curl -sL -o "$tmp/elan.tar.gz" "https://github.com/leanprover/elan/releases/latest/download/elan-x86_64-unknown-linux-gnu.tar.gz" && tar xzf "$tmp/elan.tar.gz" -C "$tmp" && "$tmp/elan-init" -y --default-toolchain none && rm -rf "$tmp"}},

      {"elan on PATH in .bashrc",
       fn -> file_contains?("/root/.bashrc", ".elan/bin") end,
       ~s{echo 'export PATH="$HOME/.elan/bin:$PATH"' >> /root/.bashrc}},

      {"Lean #{@lean_version} side-loaded from GitHub",
       fn -> File.dir?(lean_dir) end,
       ~s{mkdir -p #{@lean_root} && curl -sL -o #{@lean_root}/lean.tar.zst "https://github.com/leanprover/lean4/releases/download/v#{@lean_version}/lean-#{@lean_version}-linux.tar.zst" && tar --zstd -xf #{@lean_root}/lean.tar.zst -C #{@lean_root} && rm -f #{@lean_root}/lean.tar.zst}},

      {"toolchain registered + default",
       fn -> false end, # bash tolerated re-linking with `|| true`; so do we
       ~s{elan toolchain link "leanprover/lean4:v#{@lean_version}" "#{lean_dir}" 2>/dev/null || true; elan default "leanprover/lean4:v#{@lean_version}"}},

      {"lean/lake/elan symlinks on PATH",
       fn -> false end,
       "ln -sf /root/.elan/bin/lean /root/.elan/bin/lake /root/.elan/bin/elan /usr/local/bin/"}
    ]
  end

  def run_steps(steps, dry?) do
    # export PATH="/root/.elan/bin:$PATH" — true to the original, this only
    # reaches THIS process and its children, exactly as far as bash's export
    System.put_env("PATH", "/root/.elan/bin:" <> System.get_env("PATH"))

    Enum.each(steps, fn {name, done?, cmd} ->
      cond do
        done?.() ->
          IO.puts("  [skip]      #{name}")

        dry? ->
          IO.puts("  [would run] #{name}")
          IO.puts("              $ #{cmd}")

        true ->
          IO.puts("  [run]       #{name}")
          {out, status} = System.cmd("bash", ["-c", cmd], stderr_to_stdout: true)
          IO.write(out)
          # set -e, reconstructed by hand:
          if status != 0 do
            IO.puts("  FAILED (exit #{status}) — stopping, as `set -e` would.")
            System.halt(status)
          end
      end
    end)
  end

  def report(dry?) do
    IO.puts("")
    for tool <- ["julia", "lean", "lake"] do
      cond do
        dry? and System.find_executable(tool) == nil ->
          IO.puts("  #{tool}: not installed (dry run — would report version here)")

        System.find_executable(tool) == nil ->
          IO.puts("  #{tool}: NOT FOUND after setup")

        true ->
          {out, _} = System.cmd(tool, ["--version"], stderr_to_stdout: true)
          IO.write("  " <> out)
      end
    end
  end
end

dry? = "--dry-run" in System.argv()
IO.puts("setup.exs — Julia + Lean toolchains#{if dry?, do: "  (DRY RUN)", else: ""}")
Setup.run_steps(Setup.steps(), dry?)
Setup.report(dry?)
