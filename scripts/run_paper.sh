#!/usr/bin/env bash
# run_paper.sh -- Run a paper simulation with the correct venv Python
# Usage: bash scripts/run_paper.sh PAPER_ID MODE [PAPER_ID_B MODE_B]
# Examples:
#   bash scripts/run_paper.sh 0019 smoke
#   bash scripts/run_paper.sh 0019 full 0022 full   # run two papers in parallel
#
# All output goes to paper_analysis_output/Paper_XXXX_*/logs/{MODE}.log
# Use: tail -f paper_analysis_output/Paper_XXXX_*/logs/{MODE}.log  to monitor

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_PYTHON="$REPO_ROOT/venv/Scripts/python.exe"

if [ ! -f "$VENV_PYTHON" ]; then
    echo "ERROR: venv not found at $VENV_PYTHON"
    echo "Run: python -m venv venv && source venv/Scripts/activate && pip install -r requirements.txt"
    exit 1
fi

run_paper() {
    local paper_id="$1"
    local mode="$2"
    local paper_dir
    paper_dir=$(ls -d "$REPO_ROOT/paper_analysis_output/Paper_${paper_id}_"*/ 2>/dev/null | head -1)
    if [ -z "$paper_dir" ]; then
        echo "ERROR: no folder found for paper $paper_id"
        return 1
    fi
    local script="$paper_dir/scripts/simulation_${paper_id}.py"
    local log_file="$paper_dir/logs/${mode}.log"
    mkdir -p "$paper_dir/logs"
    echo "[$(date '+%T')] Starting Paper $paper_id --mode $mode (log: $log_file)"
    nohup "$VENV_PYTHON" "$script" --mode "$mode" > "$log_file" 2>&1 &
    echo "[$(date '+%T')] Paper $paper_id PID: $!"
}

# Parse arguments: pairs of PAPER_ID MODE
while [ $# -ge 2 ]; do
    run_paper "$1" "$2"
    shift 2
done

echo "All jobs launched. Monitor with:"
echo "  tail -f paper_analysis_output/Paper_XXXX_*/logs/{mode}.log"
echo "  ps aux | grep simulation_"
