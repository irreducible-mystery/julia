// setup.rs — translated from julia3claude/setup.sh.
//
// Installs the Julia and Lean toolchains on a sandboxed Linux x86_64 box
// whose egress allows github.com, conda.anaconda.org and the Ubuntu
// archive, but blocks the languages' own download hosts — so Julia comes
// from conda-forge via micromamba, and elan/Lean are side-loaded from
// GitHub release assets and registered with `elan toolchain link`.
//
// Translation notes, honest ledger:
//   • Bash edits the world in its own mother tongue; Rust must QUOTE it:
//     every action below is a string handed to Command::new("bash").
//   • `set -euo pipefail` was ambient law in the original; here failure
//     is a value (ExitStatus) the translation must remember to look at —
//     forgetting is a compiler warning, not a silent success.
//   • Each step is a struct { name, done, cmd }: the idempotence check
//     becomes first-class data, and --dry-run (absent in the original)
//     falls out for free — show every decision, touch nothing.

use std::path::Path;
use std::process::Command;

const LEAN_VERSION_DEFAULT: &str = "4.32.2";
const JULIA_ENV: &str = "/opt/julia-env";
const LEAN_ROOT: &str = "/opt/lean";

enum Done {
    Exec(&'static str),          // command -v NAME
    PathExists(String),          // [ -e PATH ]
    FileContains(&'static str, &'static str), // grep -q NEEDLE FILE
    Never,                       // bash ran it unconditionally (ln -sf, elan link)
}

struct Step {
    name: String,
    done: Done,
    cmd: String,
}

fn is_done(d: &Done) -> bool {
    match d {
        Done::Exec(name) => Command::new("bash")
            .args(["-c", &format!("command -v {name} >/dev/null")])
            .status()
            .map(|s| s.success())
            .unwrap_or(false),
        Done::PathExists(p) => Path::new(p).exists(),
        Done::FileContains(path, needle) => std::fs::read_to_string(path)
            .map(|body| body.contains(needle))
            .unwrap_or(false),
        Done::Never => false,
    }
}

fn steps(lean_version: &str) -> Vec<Step> {
    let lean_dir = format!("{LEAN_ROOT}/lean-{lean_version}-linux");
    vec![
        Step {
            name: "zstd (unpacks Lean's .tar.zst release assets)".into(),
            done: Done::Exec("zstd"),
            cmd: "apt-get install -y zstd".into(),
        },
        Step {
            name: "micromamba".into(),
            done: Done::Exec("micromamba"),
            cmd: r#"curl -sL -o /usr/local/bin/micromamba "https://github.com/mamba-org/micromamba-releases/releases/latest/download/micromamba-linux-64" && chmod +x /usr/local/bin/micromamba"#.into(),
        },
        Step {
            name: "Julia via micromamba + conda-forge".into(),
            done: Done::PathExists(format!("{JULIA_ENV}/bin/julia")),
            cmd: format!("micromamba create -y -r /opt/mamba -p {JULIA_ENV} -c conda-forge julia"),
        },
        Step {
            name: "julia symlink on PATH".into(),
            done: Done::Never, // ln -sf is its own idempotence
            cmd: format!("ln -sf {JULIA_ENV}/bin/julia /usr/local/bin/julia"),
        },
        Step {
            name: r#"JULIA_PKG_SERVER="" in .bashrc (Pkg falls back to GitHub clones)"#.into(),
            done: Done::FileContains("/root/.bashrc", "JULIA_PKG_SERVER"),
            cmd: r#"echo 'export JULIA_PKG_SERVER=""' >> /root/.bashrc"#.into(),
        },
        Step {
            name: "elan (installed with --default-toolchain none)".into(),
            done: Done::PathExists("/root/.elan/bin/elan".into()),
            cmd: r#"tmp=$(mktemp -d) && curl -sL -o "$tmp/elan.tar.gz" "https://github.com/leanprover/elan/releases/latest/download/elan-x86_64-unknown-linux-gnu.tar.gz" && tar xzf "$tmp/elan.tar.gz" -C "$tmp" && "$tmp/elan-init" -y --default-toolchain none && rm -rf "$tmp""#.into(),
        },
        Step {
            name: "elan on PATH in .bashrc".into(),
            done: Done::FileContains("/root/.bashrc", ".elan/bin"),
            cmd: r#"echo 'export PATH="$HOME/.elan/bin:$PATH"' >> /root/.bashrc"#.into(),
        },
        Step {
            name: format!("Lean {lean_version} side-loaded from GitHub"),
            done: Done::PathExists(lean_dir.clone()),
            cmd: format!(
                r#"mkdir -p {LEAN_ROOT} && curl -sL -o {LEAN_ROOT}/lean.tar.zst "https://github.com/leanprover/lean4/releases/download/v{lean_version}/lean-{lean_version}-linux.tar.zst" && tar --zstd -xf {LEAN_ROOT}/lean.tar.zst -C {LEAN_ROOT} && rm -f {LEAN_ROOT}/lean.tar.zst"#
            ),
        },
        Step {
            name: "toolchain registered + default".into(),
            done: Done::Never, // bash tolerated re-linking with `|| true`; so do we
            cmd: format!(
                r#"elan toolchain link "leanprover/lean4:v{lean_version}" "{lean_dir}" 2>/dev/null || true; elan default "leanprover/lean4:v{lean_version}""#
            ),
        },
        Step {
            name: "lean/lake/elan symlinks on PATH".into(),
            done: Done::Never,
            cmd: "ln -sf /root/.elan/bin/lean /root/.elan/bin/lake /root/.elan/bin/elan /usr/local/bin/".into(),
        },
    ]
}

fn main() {
    let dry = std::env::args().any(|a| a == "--dry-run");
    let lean_version =
        std::env::var("LEAN_VERSION").unwrap_or_else(|_| LEAN_VERSION_DEFAULT.into());

    // export PATH="/root/.elan/bin:$PATH" — reaches this process and its
    // children, exactly as far as bash's export ever reached
    let path = std::env::var("PATH").unwrap_or_default();
    std::env::set_var("PATH", format!("/root/.elan/bin:{path}"));

    println!(
        "setup.rs — Julia + Lean toolchains{}",
        if dry { "  (DRY RUN)" } else { "" }
    );

    for step in steps(&lean_version) {
        if is_done(&step.done) {
            println!("  [skip]      {}", step.name);
        } else if dry {
            println!("  [would run] {}", step.name);
            println!("              $ {}", step.cmd);
        } else {
            println!("  [run]       {}", step.name);
            let status = Command::new("bash")
                .args(["-c", &step.cmd])
                .status()
                .expect("failed to spawn bash");
            // set -e, reconstructed by hand:
            if !status.success() {
                eprintln!(
                    "  FAILED (exit {}) — stopping, as `set -e` would.",
                    status.code().unwrap_or(-1)
                );
                std::process::exit(status.code().unwrap_or(1));
            }
        }
    }

    println!();
    for tool in ["julia", "lean", "lake"] {
        let found = Command::new("bash")
            .args(["-c", &format!("command -v {tool} >/dev/null")])
            .status()
            .map(|s| s.success())
            .unwrap_or(false);
        if !found {
            if dry {
                println!("  {tool}: not installed (dry run — would report version here)");
            } else {
                println!("  {tool}: NOT FOUND after setup");
            }
        } else {
            let out = Command::new(tool).arg("--version").output();
            if let Ok(o) = out {
                print!("  {}", String::from_utf8_lossy(&o.stdout));
            }
        }
    }
}
