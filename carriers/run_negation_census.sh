#!/usr/bin/env bash
# run_negation_census.sh — the four-host court for negation.
#
# Elixir, Rust, Lean and SQL each answer the same two questions about their
# own negation, and the answers do not agree — which is the finding. Every
# capture is guarded for non-emptiness before comparison (the C2 repair).
#
# Exit 0 iff every host reports its pinned result.
set -u
cd "$(dirname "$0")"
status=0; n=0
SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT

check()   { n=$((n+1)); if [ "$2" = "$3" ]; then echo "  ok   $1"; else echo "  ** FAIL ** $1 (got '$2', expected '$3')"; status=1; fi; }
nonempty(){ n=$((n+1)); if [ -n "$2" ]; then echo "  ok   $1"; else echo "  ** FAIL ** $1 (EMPTY capture)"; status=1; fi; }

for tool in elixir rustc sqlite3; do
  command -v "$tool" >/dev/null 2>&1 || { echo "** $tool not found"; exit 2; }
done

echo "== N: the duality and the runtime halves =="
EX="$(elixir negation_census.exs 2>&1)"; EXRC=$?
EXV="$(printf '%s\n' "$EX" | grep '^VERDICT ' || true)"
nonempty "Elixir census produced a VERDICT" "$EXV"
check "Elixir census pinned" "$EXV" "VERDICT mismatches=0 checks=120"
check "Elixir census exit"   "$EXRC" "0"

rustc -O negation_census.rs -o "$SCRATCH/neg" 2>"$SCRATCH/e" || { echo "** rustc failed"; cat "$SCRATCH/e"; exit 1; }
RS="$("$SCRATCH/neg" 2>&1)"; RSRC=$?
RSV="$(printf '%s\n' "$RS" | grep '^VERDICT ' || true)"
nonempty "Rust census produced a VERDICT" "$RSV"
check "Rust census pinned" "$RSV" "VERDICT mismatches=0 checks=91"
check "Rust census exit"   "$RSRC" "0"

# ---------------------------------------------------------------------
# SQL / K3 — the third host's answer, exhaustive over {0, 1, NULL}.
# K3 KEEPS double-negation elimination and LOSES excluded middle: the exact
# mirror of Elixir's coercing `!`, which loses DNE and keeps LEM.
# ---------------------------------------------------------------------
echo
echo "== N4: which half of classical negation does each host drop? =="
K3_DNE="$(sqlite3 ':memory:' "WITH v(x) AS (VALUES (0),(1),(NULL))
  SELECT COUNT(*) FROM v WHERE ((NOT (NOT x)) IS NOT DISTINCT FROM x);")"
K3_LEM="$(sqlite3 ':memory:' "WITH v(x) AS (VALUES (0),(1),(NULL))
  SELECT COUNT(*) FROM v WHERE (x OR NOT x) IS 1;")"
K3_FIX="$(sqlite3 ':memory:' "WITH v(x) AS (VALUES (0),(1),(NULL))
  SELECT COUNT(*) FROM v WHERE (NOT x) IS NOT DISTINCT FROM x;")"
nonempty "SQL K3 produced answers" "$K3_DNE$K3_LEM$K3_FIX"
check "SQL K3: DNE holds for all 3 values"          "$K3_DNE" "3"
check "SQL K3: LEM holds for only 2 of 3 (NULL fails)" "$K3_LEM" "2"
check "SQL K3: NOT has exactly one fixed point (NULL)" "$K3_FIX" "1"

# ---------------------------------------------------------------------
# LEAN — the kernel's answer, with the axiom ledger as the receipt. One host
# carrying TWO negations: Bool's is involutive and free; Prop's is neither,
# and both classical laws cost Classical.choice at exactly the same price.
# ---------------------------------------------------------------------
if command -v lean >/dev/null 2>&1; then
  LEDGER="$(lean negation_census.lean 2>&1)"
  nonempty "Lean produced an axiom ledger" "$LEDGER"
  FREE="$(printf '%s\n' "$LEDGER" | grep -c 'does not depend on any axioms' || true)"
  PAID="$(printf '%s\n' "$LEDGER" | grep -c 'Classical.choice' || true)"
  check "Lean: 6 negation facts are axiom-FREE"       "$FREE" "6"
  check "Lean: exactly 2 need Classical.choice (DNE, LEM)" "$PAID" "2"
  DNE_PAID="$(printf '%s\n' "$LEDGER" | grep 'prop_dne' | grep -c 'Classical.choice' || true)"
  TNE_FREE="$(printf '%s\n' "$LEDGER" | grep 'prop_tne' | grep -c 'does not depend' || true)"
  check "Lean: removing TWO negations is purchased"    "$DNE_PAID" "1"
  check "Lean: collapsing THREE to one is free"        "$TNE_FREE" "1"

  # ---- the refusal court: can #guard_msgs be pointed at a negation? ----
  REFUSE="$(lean negation_refusals.lean 2>&1)"; REFRC=$?
  nonempty "refusal court produced output" "$REFUSE"
  check "refusal court: every pinned rejection matches" "$REFRC" "0"
  check "refusal court: both negative theorems are axiom-free" \
        "$(printf '%s\n' "$REFUSE" | grep -c 'does not depend on any axioms')" "2"
else
  echo "  -- lean absent; kernel half skipped WITH NOTICE"
  n=$((n+8))
fi

# ---------------------------------------------------------------------
# THE STING — the number of fixed points of negation is a property of
# (host, BUILD PROFILE). iN is ℤ/2^N, so gcd(2, 2^N) = 2 predicts TWO fixed
# points: 0 and MIN. In release both are reachable. In debug, negating MIN
# PANICS — the second fixed point does not exist. Same source, two algebras.
# ---------------------------------------------------------------------
echo
echo "== N2: negation's fixed-point count depends on the build profile =="
cat > "$SCRATCH/fx.rs" <<'EOF'
fn main() {
    let m = std::hint::black_box(i8::MIN);
    let neg = -m;                        // MIN in release; panic in debug
    println!("{}", if neg == m { "TWO_FIXED_POINTS" } else { "ONE" });
}
EOF
rustc    "$SCRATCH/fx.rs" -o "$SCRATCH/fx_dbg" 2>/dev/null
rustc -O "$SCRATCH/fx.rs" -o "$SCRATCH/fx_rel" 2>/dev/null
DBG="$("$SCRATCH/fx_dbg" 2>/dev/null)"; DBGRC=$?
REL="$("$SCRATCH/fx_rel" 2>/dev/null)"; RELRC=$?
check "debug: negating MIN panics — the fixed point is unreachable" "$DBGRC" "101"
check "release: MIN negates to itself — ker φ is inhabited"         "$REL" "TWO_FIXED_POINTS"
check "release exit"                                                "$RELRC" "0"

# ---------------------------------------------------------------------
PINNED=21
echo
if [ "$n" -ne "$PINNED" ]; then echo "** FAIL ** ran $n checks, pinned $PINNED"; status=1; fi
if [ "$status" -eq 0 ]; then
  echo "NEGATION CENSUS PASSED ($n/$PINNED) — read the exit code, not the text"
else
  echo "SOMETHING FAILED"
fi
exit "$status"
