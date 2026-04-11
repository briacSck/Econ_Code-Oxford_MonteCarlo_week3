"""
Generate submission deliverables for both papers.

Primary output per paper: AuthorYearReport_XXXX.xlsx
  - Built on top of the existing 17-sheet full-run workbook
  - Inserts "00_PaperInfo" as the first tab
  - Appends "IterationDetail" sheet (one row per simulation iteration)
  - Copies to full_run/ folder AND repo root

Usage:
  python generate_deliverables.py              # process all papers
  python generate_deliverables.py --paper 0005 # process one paper
"""

from __future__ import annotations

import argparse
import re
import shutil
from itertools import product
from pathlib import Path

import numpy as np
import openpyxl
import pandas as pd
from openpyxl.styles import Alignment, Font, PatternFill
from openpyxl.utils import get_column_letter

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
REPO_ROOT = Path(__file__).parent
PAPER_OUTPUT = REPO_ROOT / "paper_analysis_output"

# ---------------------------------------------------------------------------
# Paper configuration
# ---------------------------------------------------------------------------
PAPERS = {
    "0005": {
        "paper_dir":          PAPER_OUTPUT / "Paper_0005_MappingEntrepreneurial",
        "workbook":           PAPER_OUTPUT / "Paper_0005_MappingEntrepreneurial" / "full_run" / "Stroube2025Report_0005.xlsx",
        "paper_info":         REPO_ROOT / "paper_info_0005.xlsx",
        "author_year":        "Stroube2025",
        "focal_iv":           "log_pop_black_aa",
        "baseline_coef":      0.0307,
        "baseline_se":        0.0054,
        "baseline_pval":      2.80e-08,
        "regression_outputs": PAPER_OUTPUT / "Paper_0005_MappingEntrepreneurial" / "regression_outputs",
        "key_vars": [
            "log_pop_black_aa",
            "log_total_bachelor_deg",
            "log_pop_total_poverty",
            "log_total_social_cap",
        ],
        "mechanisms":   ["MCAR", "MAR", "NMAR"],
        "pct_strings":  ["1pct", "5pct", "10pct", "20pct", "30pct", "40pct", "50pct"],
        "methods":      ["LD", "Mean", "Reg", "Iter", "RF", "DL", "MILGBM"],
        "n_iters":      30,
        "txt_has_data": False,  # .txt files are empty for this paper
    },
    "0017": {
        "paper_dir":          PAPER_OUTPUT / "Paper_0017_StatusConsensus",
        "workbook":           PAPER_OUTPUT / "Paper_0017_StatusConsensus" / "full_run" / "Stroube2024Report_0017.xlsx",
        "paper_info":         REPO_ROOT / "paper_info_0017.xlsx",
        "author_year":        "Stroube2024",
        "focal_iv":           "FLead",
        "baseline_coef":      0.0468,
        "baseline_se":        0.0080,
        "baseline_pval":      6.23e-09,
        "regression_outputs": PAPER_OUTPUT / "Paper_0017_StatusConsensus" / "regression_outputs",
        "key_vars": [
            "kim_violence_gore",
            "kim_sex_nudity",
            "kim_language",
            "log_bom_opening_theaters",
        ],
        "mechanisms":   ["MCAR", "MAR", "NMAR"],
        "pct_strings":  ["1pct", "5pct", "10pct", "20pct", "30pct", "40pct", "50pct"],
        "methods":      ["LD", "Mean", "Reg", "Iter", "RF", "DL", "MILGBM"],
        "n_iters":      30,
        "txt_has_data": True,   # .txt files have full OLS summaries
    },
    "0019": {
        "paper_dir":          PAPER_OUTPUT / "Paper_0019_AntidiscrimLaws",
        "workbook":           PAPER_OUTPUT / "Paper_0019_AntidiscrimLaws" / "full_run" / "AntidiscrimLawsReport_0019.xlsx",
        "paper_info":         REPO_ROOT / "paper_info_0019.xlsx",
        "author_year":        "AntidiscrimLaws",
        "focal_iv":           "ad_law2",
        "baseline_coef":      -0.0110,
        "baseline_se":        0.0034,
        "baseline_pval":      0.0013,
        "regression_outputs": PAPER_OUTPUT / "Paper_0019_AntidiscrimLaws" / "regression_outputs",
        "key_vars":           ["ln_at_adj", "ppent_at", "state_inc_growth"],
        "mechanisms":   ["MCAR", "MAR", "NMAR"],
        "pct_strings":  ["1pct", "5pct", "10pct", "20pct", "30pct", "40pct", "50pct"],
        "methods":      ["LD", "Mean", "Reg", "Iter", "RF", "DL", "MILGBM"],
        "n_iters":      30,
        "txt_has_data": True,
    },
    "0020": {
        "paper_dir":          PAPER_OUTPUT / "Paper_0020_CompetingAttention",
        "workbook":           PAPER_OUTPUT / "Paper_0020_CompetingAttention" / "full_run" / "CompetingAttentionReport_0020.xlsx",
        "paper_info":         REPO_ROOT / "paper_info_0020.xlsx",
        "author_year":        "CompetingAttention",
        "focal_iv":           "afterXVGM",
        "baseline_coef":      1.1369,
        "baseline_se":        0.4846,
        "baseline_pval":      0.020,
        "regression_outputs": PAPER_OUTPUT / "Paper_0020_CompetingAttention" / "regression_outputs",
        "key_vars":           ["post_lav_Visits", "post_lHerfCont", "post_lav_Visits_VGM"],
        "mechanisms":   ["MCAR", "MAR", "NMAR"],
        "pct_strings":  ["1pct", "5pct", "10pct", "20pct", "30pct", "40pct", "50pct"],
        "methods":      ["LD", "Mean", "Reg", "Iter", "RF", "DL", "MILGBM"],
        "n_iters":      30,
        "txt_has_data": True,
    },
    "0022": {
        "paper_dir":          PAPER_OUTPUT / "Paper_0022_DemandPull",
        "workbook":           PAPER_OUTPUT / "Paper_0022_DemandPull" / "full_run" / "DemandPullReport_0022.xlsx",
        "paper_info":         REPO_ROOT / "paper_info_0022.xlsx",
        "author_year":        "DemandPull",
        "focal_iv":           "Post_x_Treatment",
        "baseline_coef":      0.3739,
        "baseline_se":        0.1913,
        "baseline_pval":      0.052,
        "regression_outputs": PAPER_OUTPUT / "Paper_0022_DemandPull" / "regression_outputs",
        "key_vars":           ["Age", "WorkExp", "EntrepExperience"],
        "mechanisms":   ["MCAR", "MAR", "NMAR"],
        "pct_strings":  ["1pct", "5pct", "10pct", "20pct", "30pct", "40pct", "50pct"],
        "methods":      ["LD", "Mean", "Reg", "Iter", "RF", "DL", "MILGBM"],
        "n_iters":      30,
        "txt_has_data": True,
    },
}

# ---------------------------------------------------------------------------
# Styling helpers
# ---------------------------------------------------------------------------
HEADER_FONT  = Font(bold=True, color="FFFFFF")
HEADER_FILL  = PatternFill("solid", fgColor="1E50A0")
LABEL_FONT   = Font(bold=True)
LABEL_FILL   = PatternFill("solid", fgColor="F0F0F8")
ALT_ROW_FILL = PatternFill("solid", fgColor="F5F5F5")


def _style_header_row(ws, row_idx: int = 1) -> None:
    for cell in ws[row_idx]:
        cell.font = HEADER_FONT
        cell.fill = HEADER_FILL
        cell.alignment = Alignment(wrap_text=False, vertical="center")


# ---------------------------------------------------------------------------
# Fix A — read 00_PaperInfo rows from paper_info_XXXX.xlsx
# ---------------------------------------------------------------------------
def _load_paper_info_rows(paper_info_path: Path) -> list[tuple[str, str]]:
    df = pd.read_excel(paper_info_path, sheet_name=0)
    rows = []
    for _, row in df.iterrows():
        field = str(row.iloc[0]) if pd.notna(row.iloc[0]) else ""
        value = str(row.iloc[1]) if pd.notna(row.iloc[1]) else ""
        if field and field != "Field":
            rows.append((field, value))
    return rows


def _build_paper_info_sheet(wb: openpyxl.Workbook, rows: list[tuple[str, str]]) -> None:
    ws = wb.create_sheet("00_PaperInfo")

    ws.append(["Field", "Value"])
    _style_header_row(ws)

    for field, value in rows:
        ws.append([field, value])
        r = ws.max_row
        ws[f"A{r}"].font  = LABEL_FONT
        ws[f"A{r}"].fill  = LABEL_FILL
        ws[f"A{r}"].alignment = Alignment(wrap_text=True)
        ws[f"B{r}"].alignment = Alignment(wrap_text=True)

    ws.column_dimensions["A"].width = 28
    ws.column_dimensions["B"].width = 80
    ws.freeze_panes = "A2"

    # Move to position 0 (first tab)
    wb.move_sheet("00_PaperInfo", offset=-len(wb.sheetnames) + 1)


# ---------------------------------------------------------------------------
# Fix B — IterationDetail sheet
# ---------------------------------------------------------------------------

def _parse_ols_txt(path: Path, focal_iv: str) -> dict | None:
    """
    Parse a regression output .txt file.
    Handles two formats:
      1. statsmodels OLS summary table (FLead row in coefficients block)
      2. MI Pooled Result format (Pooled Coef: / Pooled SE: / Pooled pval: / N (mean):)
    Returns dict with coef, se, pval, nobs or None on failure.
    """
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return None

    if not text or text.strip() in ("None", ""):
        return None

    # --- Try MI Pooled format first ---
    if "Pooled Coef:" in text:
        try:
            coef = float(re.search(r'Pooled Coef:\s*([-\d.e+]+)', text).group(1))
            se   = float(re.search(r'Pooled SE:\s*([-\d.e+]+)', text).group(1))
            pval = float(re.search(r'Pooled pval:\s*([-\d.e+]+)', text).group(1))
            m_n  = re.search(r'N \(mean\):\s*([\d.]+)', text)
            nobs = int(float(m_n.group(1))) if m_n else None
            return {"coef": coef, "se": se, "pval": pval, "nobs": nobs}
        except (AttributeError, ValueError):
            pass

    # --- Try OLS summary table format ---
    # Extract nobs
    nobs = None
    m = re.search(r'No\.\s+Observations:\s+([\d,]+)', text)
    if m:
        nobs = int(m.group(1).replace(",", ""))

    # Find focal IV row in coefficient table
    # Format: "FLead                        0.0477      0.008      5.934      0.000 ..."
    pattern = re.compile(
        r'^\s*' + re.escape(focal_iv) + r'\s+([-\d.e+]+)\s+([-\d.e+]+)\s+([-\d.e+]+)\s+([-\d.e+]+)',
        re.MULTILINE
    )
    m = pattern.search(text)
    if not m:
        return None

    try:
        coef = float(m.group(1))
        se   = float(m.group(2))
        # group(3) is t-stat; group(4) is P>|t|
        pval = float(m.group(4))
    except (ValueError, IndexError):
        return None

    return {"coef": coef, "se": se, "pval": pval, "nobs": nobs}


def _build_iteration_detail_0017(cfg: dict) -> pd.DataFrame:
    """
    Build IterationDetail for paper 0017 by parsing .txt files.
    """
    reg_dir = cfg["regression_outputs"]
    focal_iv = cfg["focal_iv"]
    baseline_coef = cfg["baseline_coef"]
    baseline_se   = cfg["baseline_se"]
    baseline_pval = cfg["baseline_pval"]

    records = []
    total_expected = (
        len(cfg["key_vars"]) * len(cfg["mechanisms"]) *
        len(cfg["pct_strings"]) * len(cfg["methods"]) * cfg["n_iters"]
    )
    print(f"    Parsing .txt files (expected {total_expected:,} files)...")

    parsed_ok = 0
    parsed_fail = 0

    for mechanism, pct_str, key_var, method, iteration in product(
        cfg["mechanisms"], cfg["pct_strings"], cfg["key_vars"],
        cfg["methods"], range(cfg["n_iters"])
    ):
        txt_path = reg_dir / mechanism / pct_str / key_var / method / f"iter{iteration}_model_{key_var}.txt"
        parsed = _parse_ols_txt(txt_path, focal_iv)

        if parsed:
            coef = parsed["coef"]
            se   = parsed["se"]
            pval = parsed["pval"]
            nobs = parsed["nobs"]
            sign = int(np.sign(coef)) if not np.isnan(coef) else np.nan
            significant = int(pval < 0.05) if not np.isnan(pval) else np.nan
            coef_delta  = coef - baseline_coef
            sign_match  = int(np.sign(coef) == np.sign(baseline_coef))
            sig_match   = int((pval < 0.05) == (baseline_pval < 0.05))
            both_match  = int(bool(sign_match) and bool(sig_match))
            parsed_ok += 1
        else:
            coef = se = pval = coef_delta = np.nan
            nobs = np.nan
            sign = significant = sign_match = sig_match = both_match = np.nan
            parsed_fail += 1

        records.append({
            "key_var":       key_var,
            "mechanism":     mechanism,
            "pct_str":       pct_str,
            "method":        method,
            "iteration":     iteration,
            "coef":          coef,
            "se":            se,
            "pval":          pval,
            "nobs":          nobs,
            "sign":          sign,
            "significant":   significant,
            "baseline_coef": baseline_coef,
            "baseline_se":   baseline_se,
            "baseline_pval": baseline_pval,
            "coef_delta":    coef_delta,
            "sign_match":    sign_match,
            "sig_match":     sig_match,
            "both_match":    both_match,
        })

    print(f"    Parsed OK: {parsed_ok:,} | Failed/empty: {parsed_fail:,}")
    df = pd.DataFrame(records)
    df = df.sort_values(["mechanism", "pct_str", "key_var", "method", "iteration"]).reset_index(drop=True)
    return df


def _build_iteration_detail_0005(cfg: dict) -> pd.DataFrame:
    """
    Build IterationDetail skeleton for paper 0005.
    Coefficient data was not retained in the simulation outputs (.txt files are empty).
    Structural columns are populated; coef/se/pval are NaN.
    """
    baseline_coef = cfg["baseline_coef"]
    baseline_se   = cfg["baseline_se"]
    baseline_pval = cfg["baseline_pval"]

    records = []
    for mechanism, pct_str, key_var, method, iteration in product(
        cfg["mechanisms"], cfg["pct_strings"], cfg["key_vars"],
        cfg["methods"], range(cfg["n_iters"])
    ):
        records.append({
            "key_var":       key_var,
            "mechanism":     mechanism,
            "pct_str":       pct_str,
            "method":        method,
            "iteration":     iteration,
            "coef":          np.nan,
            "se":            np.nan,
            "pval":          np.nan,
            "nobs":          np.nan,
            "sign":          np.nan,
            "significant":   np.nan,
            "baseline_coef": baseline_coef,
            "baseline_se":   baseline_se,
            "baseline_pval": baseline_pval,
            "coef_delta":    np.nan,
            "sign_match":    np.nan,
            "sig_match":     np.nan,
            "both_match":    np.nan,
            "note":          "Coefficient data not retained in simulation outputs (pyfixest .summary() returned None)",
        })

    df = pd.DataFrame(records)
    df = df.sort_values(["mechanism", "pct_str", "key_var", "method", "iteration"]).reset_index(drop=True)
    print(f"    Built structural skeleton: {len(df):,} rows (coef columns are NaN)")
    return df


def _write_iteration_detail_sheet(wb: openpyxl.Workbook, df: pd.DataFrame) -> None:
    """Append IterationDetail sheet to workbook with formatting."""
    ws = wb.create_sheet("IterationDetail")

    # Write header
    cols = list(df.columns)
    ws.append(cols)
    _style_header_row(ws)
    ws.freeze_panes = "A2"
    ws.auto_filter.ref = f"A1:{get_column_letter(len(cols))}1"

    # Write rows with alternate shading
    for i, row in enumerate(df.itertuples(index=False), start=2):
        ws.append(list(row))
        if i % 2 == 0:
            for cell in ws[i]:
                cell.fill = ALT_ROW_FILL

    # Set column widths
    width_map = {
        "key_var": 26, "mechanism": 10, "pct_str": 8, "method": 8,
        "iteration": 9, "coef": 12, "se": 12, "pval": 12, "nobs": 8,
        "sign": 6, "significant": 11, "baseline_coef": 14, "baseline_se": 12,
        "baseline_pval": 14, "coef_delta": 12, "sign_match": 11,
        "sig_match": 10, "both_match": 11, "note": 55,
    }
    for col_idx, col_name in enumerate(cols, start=1):
        ws.column_dimensions[get_column_letter(col_idx)].width = width_map.get(col_name, 12)

    print(f"    IterationDetail: {len(df):,} rows written")


# ---------------------------------------------------------------------------
# Main per-paper builder
# ---------------------------------------------------------------------------
def process_paper(paper_id: str, cfg: dict) -> Path:
    print(f"\n=== Paper {paper_id} ({cfg['author_year']}) ===")

    source_wb_path = cfg["workbook"]
    if not source_wb_path.exists():
        raise FileNotFoundError(f"Source workbook not found: {source_wb_path}")

    print(f"  Loading source workbook: {source_wb_path.name}")
    wb = openpyxl.load_workbook(source_wb_path)
    print(f"  Sheets in source: {wb.sheetnames}")

    # Fix A — insert 00_PaperInfo as first sheet
    print("  Building 00_PaperInfo sheet...")
    if not cfg["paper_info"].exists():
        raise FileNotFoundError(f"paper_info not found: {cfg['paper_info']}")
    pir_rows = _load_paper_info_rows(cfg["paper_info"])
    _build_paper_info_sheet(wb, pir_rows)
    print(f"    00_PaperInfo: {len(pir_rows)} rows")

    # Fix B — build IterationDetail
    print("  Building IterationDetail sheet...")
    if cfg["txt_has_data"]:
        df_iter = _build_iteration_detail_0017(cfg)
    else:
        df_iter = _build_iteration_detail_0005(cfg)
    _write_iteration_detail_sheet(wb, df_iter)

    # Save to full_run/
    out_name = f"AuthorYearReport_{paper_id}.xlsx"
    full_run_dir = cfg["paper_dir"] / "full_run"
    full_run_dir.mkdir(parents=True, exist_ok=True)
    out_path = full_run_dir / out_name
    print(f"  Saving to {out_path} ...")
    wb.save(str(out_path))

    size_mb = out_path.stat().st_size / 1_048_576
    print(f"  Saved: {out_path.name} ({size_mb:.1f} MB)")

    # Copy to repo root
    root_copy = REPO_ROOT / out_name
    shutil.copy2(out_path, root_copy)
    print(f"  Root copy: {root_copy.name} ({root_copy.stat().st_size / 1_048_576:.1f} MB)")

    return root_copy


# ---------------------------------------------------------------------------
# Verification
# ---------------------------------------------------------------------------
def verify_output(paper_id: str, cfg: dict) -> None:
    out_name = f"AuthorYearReport_{paper_id}.xlsx"
    root_path = REPO_ROOT / out_name
    full_run_path = cfg["paper_dir"] / "full_run" / out_name

    ok = True
    for p in [root_path, full_run_path]:
        if not p.exists():
            print(f"  FAIL: {p} not found")
            ok = False
        elif p.stat().st_size < 2 * 1_048_576:
            print(f"  WARN: {p.name} is only {p.stat().st_size / 1_048_576:.1f} MB (expected >2 MB)")
        else:
            print(f"  OK:   {p.name} — {p.stat().st_size / 1_048_576:.1f} MB")

    if root_path.exists():
        wb = openpyxl.load_workbook(root_path, read_only=True)
        sheets = wb.sheetnames
        if sheets[0] != "00_PaperInfo":
            print(f"  FAIL: First sheet is '{sheets[0]}', expected '00_PaperInfo'")
            ok = False
        else:
            print(f"  OK:   First sheet = '00_PaperInfo'")

        if "IterationDetail" not in sheets:
            print(f"  FAIL: 'IterationDetail' sheet missing")
            ok = False
        else:
            ws_iter = wb["IterationDetail"]
            n_rows = ws_iter.max_row - 1  # exclude header
            if n_rows != 17640:
                print(f"  WARN: IterationDetail has {n_rows:,} rows (expected 17,640)")
            else:
                print(f"  OK:   IterationDetail — {n_rows:,} rows")

        for sheet in ["Mean_Stability_MCAR", "Mean_Stability_MAR", "Mean_Stability_NMAR"]:
            if sheet in sheets:
                print(f"  OK:   {sheet} present (unchanged)")
            else:
                print(f"  WARN: {sheet} not found in output workbook")

        wb.close()

    if ok:
        print(f"  Verification PASSED for paper {paper_id}")
    else:
        print(f"  Verification had issues for paper {paper_id}")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------
def main() -> None:
    parser = argparse.ArgumentParser(description="Generate AuthorYearReport deliverables")
    parser.add_argument("--paper", choices=list(PAPERS.keys()), default=None,
                        help="Process only this paper (default: all)")
    args = parser.parse_args()

    papers_to_run = {args.paper: PAPERS[args.paper]} if args.paper else PAPERS

    for paper_id, cfg in papers_to_run.items():
        process_paper(paper_id, cfg)

    print("\n--- Verification ---")
    for paper_id, cfg in papers_to_run.items():
        verify_output(paper_id, cfg)

    print("\nDone.")


if __name__ == "__main__":
    main()
