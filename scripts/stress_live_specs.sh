#!/usr/bin/env bash
# Stress the real-browser specs to reproduce intermittent failures under load.
#
#   ./scripts/stress_live_specs.sh [rounds] [workers]
#
# Builds the heavy live spec files once, then runs the mixed examples in
# parallel for several rounds and reports the per-run summaries. Logs stay in
# temp/stress/. Exits non-zero when any run failed.
set -uo pipefail

ROUNDS="${1:-5}"
WORKERS="${2:-8}"
OUT=temp/stress

mkdir -p "$OUT"
rm -f "$OUT"/*.log

crystal build spec/live_browser_parity_spec.cr -o "$OUT/live_spec"
crystal build spec/cdp_client_parity_spec.cr -o "$OUT/client_spec"

run_example() {
  local name="$1" binary="$2" round="$3" worker="$4"
  "$binary" -e "$name" > "$OUT/${name}_${round}_${worker}.log" 2>&1
}

for round in $(seq 1 "$ROUNDS"); do
  for worker in $(seq 1 "$WORKERS"); do
    if [ $((worker % 2)) -eq 0 ]; then
      run_example "TestCrash" "$OUT/client_spec" "$round" "$worker" &
    else
      run_example "TestSearchIframes" "$OUT/live_spec" "$round" "$worker" &
    fi
  done
  wait
done

echo "== summaries"
grep -h "examples," "$OUT"/*.log | sort | uniq -c

failed=$(grep -lE "[1-9][0-9]* (failures|errors)" "$OUT"/*.log 2>/dev/null || true)
if [ -n "$failed" ]; then
  echo "== failed runs" >&2
  echo "$failed" >&2
  exit 1
fi

echo "all stress runs passed"
