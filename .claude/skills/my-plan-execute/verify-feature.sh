#!/usr/bin/env bash
# Verify one plan feature commit: exactly one commit since the start ref, only allowed
# files changed, and the gate log records exit 0.
# Usage: verify-feature.sh <start-ref> <gate-log> <allowed-files-file> [end-ref]
# end-ref defaults to HEAD; pass the feature commit when reconciling an earlier run.
set -euo pipefail

if [ $# -lt 3 ] || [ $# -gt 4 ]; then
  echo "usage: $0 <start-ref> <gate-log> <allowed-files-file> [end-ref]" >&2
  exit 2
fi

start_ref=$1
gate_log=$2
allowed=$3
end_ref=${4:-HEAD}
failed=0

commits=$(git rev-list --count "$start_ref".."$end_ref")
if [ "$commits" -ne 1 ]; then
  echo "FAIL commits: expected 1 since $start_ref, found $commits"
  failed=1
fi

if [ "$end_ref" = HEAD ] && [ -n "$(git status --porcelain)" ]; then
  echo "FAIL tree: uncommitted changes remain"
  git status --short
  failed=1
fi

# An allowed entry ending in "/" permits everything under that directory.
outside=$(git diff --name-only "$start_ref".."$end_ref" | awk '
  NR == FNR { if ($0 != "") allowed[++n] = $0; next }
  {
    for (i = 1; i <= n; i++) {
      a = allowed[i]
      if ($0 == a || (substr(a, length(a)) == "/" && index($0, a) == 1)) next
    }
    print
  }' "$allowed" -)
if [ -n "$outside" ]; then
  echo "FAIL scope: files changed outside Files: and amendments"
  echo "$outside"
  failed=1
fi

if [ ! -f "$gate_log" ]; then
  echo "FAIL gate: no gate log at $gate_log"
  failed=1
elif ! tail -n 1 "$gate_log" | grep -qx "exit=0"; then
  echo "FAIL gate: last line is '$(tail -n 1 "$gate_log")', expected exit=0"
  failed=1
fi

if [ "$failed" -eq 0 ]; then
  echo "PASS $(git rev-parse --short "$end_ref")"
fi
exit "$failed"
