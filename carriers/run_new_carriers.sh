#!/usr/bin/env bash
# run_new_carriers.sh — the court for carriers #12 (Elixir) and #13 (Rust),
# plus the two fingerprints that are only observable at BUILD time and so
# cannot live inside either carrier file.
#
# Exit 0 iff every carrier passes, each ran its pinned number of checks, AND
# every host actually produced output.
#
# THE EMPTINESS GUARD (why this driver is not a copy of run_carriers.sh):
# ieee_court.sh compares "$JBITS" to "$LBITS" and passes when they match —
# including when BOTH ARE EMPTY, which is what happens if julia or sbcl is
# present but failing (its stderr is sent to /dev/null on the sbcl line). A
# court that certifies agreement between two silences has an unfalsifiable
# pass. See audits/carrier_sweep_by_translator.sh (C2). Every capture below
# is checked for non-emptiness before it is compared to anything.
set -u
cd "$(dirname "$0")"
status=0; n=0
SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT

check()  { n=$((n+1)); if [ "$2" = "$3" ]; then echo "  ok   $1"; else echo "  ** FAIL ** $1 (got '$2', expected '$3')"; status=1; fi; }
nonempty(){ n=$((n+1)); if [ -n "$2" ]; then echo "  ok   $1"; else echo "  ** FAIL ** $1 (EMPTY capture — the vacuous-pass guard fired)"; status=1; fi; }

for tool in elixir rustc; do
  command -v "$tool" >/dev/null 2>&1 || { echo "** $tool not found"; exit 2; }
done

# ---------------------------------------------------------------------
echo "== carrier #12: ring/charge algebra in Elixir =="
EX_OUT="$(elixir ring_charge_elixir.exs 2>&1)"; EX_RC=$?
printf '%s\n' "$EX_OUT" | tail -3
EX_VERDICT="$(printf '%s\n' "$EX_OUT" | grep '^VERDICT ' || true)"
nonempty "#12 produced a VERDICT line at all" "$EX_VERDICT"
check    "#12 verdict is pinned"  "$EX_VERDICT" "VERDICT mismatches=0 checks=123"
check    "#12 exit code"          "$EX_RC"      "0"

# ---------------------------------------------------------------------
echo
echo "== carrier #13: ring/charge algebra in Rust =="
rustc -O ring_charge_rust.rs -o "$SCRATCH/rc13" 2>"$SCRATCH/rustc.err" || {
  echo "** rustc failed:"; cat "$SCRATCH/rustc.err"; exit 1; }
RS_OUT="$("$SCRATCH/rc13" 2>&1)"; RS_RC=$?
printf '%s\n' "$RS_OUT" | tail -3
RS_VERDICT="$(printf '%s\n' "$RS_OUT" | grep '^VERDICT ' || true)"
nonempty "#13 produced a VERDICT line at all" "$RS_VERDICT"
check    "#13 verdict is pinned"  "$RS_VERDICT" "VERDICT mismatches=0 checks=120"
check    "#13 exit code"          "$RS_RC"      "0"

# ---------------------------------------------------------------------
# CROSS-CARRIER: #12 and #13 must agree on every shared law. Different
# hosts, different integer models (bignum vs i128), same object.
# ---------------------------------------------------------------------
echo
echo "== cross-carrier agreement (#12 vs #13) =="
EX_LAWS="$(printf '%s\n' "$EX_OUT" | grep -E '^(star|rest_iff_dvd|P10|dial|P20|P26|P21)' \
           | sed 's/  */ /g' | awk '{print $1, $2, $3}' | sort)"
RS_LAWS="$(printf '%s\n' "$RS_OUT" | grep -E '^(star|rest_iff_dvd|P10|dial|P20|P26|P21)' \
           | sed 's/  */ /g' | awk '{print $1, $2, $3}' | sort)"
nonempty "#12 emitted law rows" "$EX_LAWS"
nonempty "#13 emitted law rows" "$RS_LAWS"
check "the two carriers agree row-for-row on every shared law" \
      "$(printf '%s' "$EX_LAWS" | md5sum)" "$(printf '%s' "$RS_LAWS" | md5sum)"

# ---------------------------------------------------------------------
# FPRINT-BUILD 1 — overflow policy is a property of (host, BUILD PROFILE).
# The census records four hosts with four policies, each fixed by the host.
# Rust breaks that schema: THE SAME SOURCE panics in debug and wraps in
# release. Proven here by compiling one file twice.
# ---------------------------------------------------------------------
echo
echo "== FPRINT-BUILD: Rust overflow depends on the BUILD PROFILE =="
cat > "$SCRATCH/ovf.rs" <<'EOF'
fn main() {
    let m: i64 = i64::MAX;
    let x = std::hint::black_box(m) + std::hint::black_box(1);
    println!("wrapped_to {x}");
}
EOF
rustc     "$SCRATCH/ovf.rs" -o "$SCRATCH/ovf_debug"   2>/dev/null
rustc -O  "$SCRATCH/ovf.rs" -o "$SCRATCH/ovf_release" 2>/dev/null
DBG_OUT="$("$SCRATCH/ovf_debug" 2>&1)"; DBG_RC=$?
REL_OUT="$("$SCRATCH/ovf_release" 2>&1)"; REL_RC=$?
nonempty "debug build produced output" "$DBG_OUT"
nonempty "release build produced output" "$REL_OUT"
check "debug profile PANICS on i64 overflow"   "$DBG_RC" "101"
check "release profile WRAPS silently"         "$REL_RC" "0"
check "release wraps to i64::MIN"              "$REL_OUT" "wrapped_to -9223372036854775808"

# ---------------------------------------------------------------------
# FPRINT-BUILD 2 — the compile-time refusal. Rust is the only host in the
# census that declines a program because equality on its key type is not
# reflexive. `HashMap<f64, _>` is not a runtime error to be caught; it is a
# program that does not exist. Proven by a build that MUST fail.
# ---------------------------------------------------------------------
echo
echo "== FPRINT-BUILD: the compile-time refusal (f64 is PartialEq but not Eq) =="
cat > "$SCRATCH/noeq.rs" <<'EOF'
use std::collections::HashMap;
fn main() { let mut m: HashMap<f64, i32> = HashMap::new(); m.insert(0.1 + 0.2, 1); }
EOF
if rustc "$SCRATCH/noeq.rs" -o "$SCRATCH/noeq" 2>"$SCRATCH/noeq.err"; then
  n=$((n+1)); echo "  ** FAIL ** HashMap<f64,_> COMPILED (the refusal did not happen)"; status=1
else
  n=$((n+1)); echo "  ok   HashMap<f64,_> is refused at compile time"
  if grep -q "Eq" "$SCRATCH/noeq.err"; then
    n=$((n+1)); echo "  ok   ...and the compiler names Eq as the missing bound"
  else
    n=$((n+1)); echo "  ** FAIL ** refused, but not for the Eq reason"; status=1
  fi
fi

# ---------------------------------------------------------------------
PINNED=16
echo
if [ "$n" -ne "$PINNED" ]; then echo "** FAIL ** ran $n checks, pinned $PINNED"; status=1; fi
if [ "$status" -eq 0 ]; then
  echo "CARRIERS #12 AND #13 PASSED ($n/$PINNED) — read the exit code, not the text"
else
  echo "SOMETHING FAILED"
fi
exit "$status"
