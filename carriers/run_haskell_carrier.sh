#!/usr/bin/env bash
# run_haskell_carrier.sh — driver for carrier #14.
# Exit 0 iff the VERDICT line reports mismatches=0, checks=125, and the
# pinned name-digest. Emptiness-guarded (C2 lesson from PR #9).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v runghc >/dev/null 2>&1 && ! command -v ghc >/dev/null 2>&1; then
  echo "FAIL: neither runghc nor ghc on PATH"
  exit 1
fi

OUT="$(mktemp)"
trap 'rm -f "$OUT"' EXIT

if command -v runghc >/dev/null 2>&1; then
  runghc carriers/ring_charge_haskell.hs >"$OUT" 2>&1 || true
else
  BIN="$(mktemp)"
  ghc -O0 -o "$BIN" carriers/ring_charge_haskell.hs >/dev/null 2>&1 || true
  if [[ -x "$BIN" ]]; then "$BIN" >"$OUT" 2>&1 || true; fi
  rm -f "$BIN" "$BIN.o" "$BIN.hi" carriers/ring_charge_haskell.o carriers/ring_charge_haskell.hi 2>/dev/null || true
fi

if [[ ! -s "$OUT" ]]; then
  echo "FAIL: carrier produced no output (host present but silent — C2 shape)"
  exit 1
fi

cat "$OUT"
VERDICT="$(grep -E '^VERDICT ' "$OUT" || true)"
if [[ -z "$VERDICT" ]]; then
  echo "FAIL: no VERDICT line"
  exit 1
fi

echo "$VERDICT" | grep -q 'mismatches=0' || { echo "FAIL: mismatches nonzero"; exit 1; }
echo "$VERDICT" | grep -q 'checks=125' || { echo "FAIL: check-count pin"; exit 1; }
echo "$VERDICT" | grep -q 'digest=7cf171fe3381f827' || { echo "FAIL: name-digest pin"; exit 1; }

echo "HASKELL CARRIER PASSED"
exit 0
