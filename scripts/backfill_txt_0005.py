"""
Backfill .txt files for Paper 0005.

The original simulation run used pyfixest and _save_iter_txt wrote str(fit.summary())
which returned "None" for pyfixest objects, leaving 17,640 empty 4-byte files.

This script reconstructs each .txt file with the correct header format and marks
the coefficient fields as N/A (data was not retained from the original run).

Run from repo root:
  python scripts/backfill_txt_0005.py
"""

from itertools import product
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent
REG_DIR = REPO_ROOT / "paper_analysis_output" / "Paper_0005_MappingEntrepreneurial" / "regression_outputs"

KEY_VARS   = ["log_pop_black_aa", "log_total_bachelor_deg", "log_pop_total_poverty", "log_total_social_cap"]
MECHANISMS = ["MCAR", "MAR", "NMAR"]
PCT_STRS   = ["1pct", "5pct", "10pct", "20pct", "30pct", "40pct", "50pct"]
METHODS    = ["LD", "Mean", "Reg", "Iter", "RF", "DL", "MILGBM"]
N_ITERS    = 30
FOCAL_IV   = "log_pop_black_aa"


TEMPLATE = """\
Paper: 0005
KeyVar: {key_var}
Mechanism: {mechanism}
Proportion: {pct_str}
Method: {method}
Iteration: {iteration}
---
FocalIV: {focal_iv}
Coef: N/A (Reconstructed — coefficient data not retained from original simulation run)
SE: N/A
pval: N/A
Nobs: N/A
Sign: N/A
Significant: N/A
---
Reconstructed from stored results — full pyfixest summary not available.
The original _save_iter_txt called str(fit.summary()) on a pyfixest object,
which returned "None", producing empty 4-byte files.
Coefficient-level data was aggregated before workbook export and is no longer
recoverable from stored outputs.
"""


def main() -> None:
    written = 0
    skipped = 0

    for mechanism, pct_str, key_var, method, iteration in product(
        MECHANISMS, PCT_STRS, KEY_VARS, METHODS, range(N_ITERS)
    ):
        path = REG_DIR / mechanism / pct_str / key_var / method / f"iter{iteration}_model_{key_var}.txt"
        path.parent.mkdir(parents=True, exist_ok=True)

        content = TEMPLATE.format(
            key_var=key_var,
            mechanism=mechanism,
            pct_str=pct_str,
            method=method,
            iteration=iteration,
            focal_iv=FOCAL_IV,
        )
        path.write_text(content, encoding="utf-8")
        written += 1

    print(f"Files written: {written:,}")
    print(f"Files skipped: {skipped:,}")

    # Spot-check
    sample = REG_DIR / "MCAR" / "1pct" / KEY_VARS[0] / "LD" / f"iter0_model_{KEY_VARS[0]}.txt"
    if sample.exists():
        size = sample.stat().st_size
        print(f"Sample file size: {size} bytes (expected >100)")
        if size > 100:
            print("PASS: sample file > 100 bytes")
        else:
            print("FAIL: sample file too small")
    else:
        print(f"FAIL: sample file not found at {sample}")

    expected = len(KEY_VARS) * len(MECHANISMS) * len(PCT_STRS) * len(METHODS) * N_ITERS
    print(f"Expected total: {expected:,} | Written: {written:,}")
    if written == expected:
        print("PASS: all files written")
    else:
        print(f"WARN: count mismatch")


if __name__ == "__main__":
    main()
