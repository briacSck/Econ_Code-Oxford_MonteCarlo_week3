"""
Backfill .txt files for Paper 0017.

The .txt files for paper 0017 already contain full OLS summaries (8,286 bytes each).
This script reads the parsed IterationDetail data from AuthorYearReport_0017.xlsx
and rewrites each .txt file with the structured header format (Paper/KeyVar/Mechanism/
Proportion/Method/Iteration/FocalIV/Coef/SE/pval/Nobs) followed by the original
OLS summary content.

If AuthorYearReport_0017.xlsx does not exist yet, run generate_deliverables.py first:
  python generate_deliverables.py --paper 0017

Run from repo root:
  python scripts/backfill_txt_0017.py
"""

from pathlib import Path

import pandas as pd

REPO_ROOT  = Path(__file__).parent.parent
REG_DIR    = REPO_ROOT / "paper_analysis_output" / "Paper_0017_StatusConsensus" / "regression_outputs"
REPORT     = REPO_ROOT / "paper_analysis_output" / "Paper_0017_StatusConsensus" / "full_run" / "AuthorYearReport_0017.xlsx"
FOCAL_IV   = "FLead"


HEADER_TEMPLATE = """\
Paper: 0017
KeyVar: {key_var}
Mechanism: {mechanism}
Proportion: {pct_str}
Method: {method}
Iteration: {iteration}
---
FocalIV: {focal_iv}
Coef: {coef}
SE: {se}
pval: {pval}
Nobs: {nobs}
Sign: {sign}
Significant: {significant}
---
Reconstructed from stored OLS summary output.
"""


def _fmt(val, decimals: int = 6) -> str:
    try:
        f = float(val)
        if pd.isna(f):
            return "N/A"
        return f"{f:.{decimals}f}"
    except (TypeError, ValueError):
        return "N/A"


def _fmt_int(val) -> str:
    try:
        f = float(val)
        if pd.isna(f):
            return "N/A"
        return str(int(f))
    except (TypeError, ValueError):
        return "N/A"


def _read_original_summary(path: Path, focal_iv: str) -> str:
    """Read the existing .txt file and return everything after the first '---' line (the OLS block)."""
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
        if text and text.strip() not in ("None", ""):
            return text
    except Exception:
        pass
    return "Original OLS summary not available"


def main() -> None:
    if not REPORT.exists():
        print(f"ERROR: {REPORT} not found.")
        print("Run: python generate_deliverables.py --paper 0017")
        return

    print(f"Reading IterationDetail from {REPORT.name} ...")
    df = pd.read_excel(REPORT, sheet_name="IterationDetail")
    print(f"  {len(df):,} rows loaded")

    written = 0
    failed  = 0

    for _, row in df.iterrows():
        key_var   = str(row["key_var"])
        mechanism = str(row["mechanism"])
        pct_str   = str(row["pct_str"])
        method    = str(row["method"])
        iteration = int(row["iteration"])

        path = REG_DIR / mechanism / pct_str / key_var / method / f"iter{iteration}_model_{key_var}.txt"
        path.parent.mkdir(parents=True, exist_ok=True)

        coef_val = _fmt(row.get("coef"))
        se_val   = _fmt(row.get("se"))
        pval_val = _fmt(row.get("pval"))
        nobs_val = _fmt_int(row.get("nobs"))

        try:
            coef_f = float(row.get("coef", float("nan")))
            sign_val = "+1" if coef_f > 0 else ("-1" if coef_f < 0 else "0")
        except (TypeError, ValueError):
            sign_val = "N/A"

        try:
            pval_f = float(row.get("pval", float("nan")))
            sig_val = str(not pd.isna(pval_f) and pval_f < 0.05)
        except (TypeError, ValueError):
            sig_val = "N/A"

        header = HEADER_TEMPLATE.format(
            key_var=key_var,
            mechanism=mechanism,
            pct_str=pct_str,
            method=method,
            iteration=iteration,
            focal_iv=FOCAL_IV,
            coef=coef_val,
            se=se_val,
            pval=pval_val,
            nobs=nobs_val,
            sign=sign_val,
            significant=sig_val,
        )

        # Append original OLS summary if it exists and has content
        original = _read_original_summary(path, FOCAL_IV)
        content = header + original

        try:
            path.write_text(content, encoding="utf-8")
            written += 1
        except Exception as e:
            print(f"  FAIL: {path} — {e}")
            failed += 1

    print(f"\nFiles written: {written:,}")
    print(f"Files failed:  {failed:,}")

    # Spot-check
    sample = REG_DIR / "MCAR" / "1pct" / "kim_violence_gore" / "LD" / "iter0_model_kim_violence_gore.txt"
    if sample.exists():
        size = sample.stat().st_size
        print(f"Sample file size: {size} bytes (expected >100)")
        if size > 100:
            print("PASS: sample file > 100 bytes")
        else:
            print("FAIL: sample file too small")
    else:
        print(f"FAIL: sample file not found at {sample}")

    expected = 17640
    print(f"Expected total: {expected:,} | Written: {written:,}")
    if written == expected:
        print("PASS: all files written")
    else:
        print(f"WARN: count mismatch (check for errors above)")


if __name__ == "__main__":
    main()
