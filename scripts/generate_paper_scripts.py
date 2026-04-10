"""
Generate paper-specific simulation scripts for all 6 new papers.

Each script = paper-specific header (Config + paths + load + baseline)
            + verbatim engine from simulation_0005.py (lines after STEP 4).

Run from repo root:
  python scripts/generate_paper_scripts.py
"""

from pathlib import Path
import re

REPO_ROOT = Path(__file__).parent.parent
TEMPLATE_PATH = (
    REPO_ROOT
    / "paper_analysis_output"
    / "Paper_0005_MappingEntrepreneurial"
    / "scripts"
    / "simulation_0005.py"
)

# ── Extract the reusable engine block (STEP 4 onward, excluding main()) ─────
_template_text = TEMPLATE_PATH.read_text(encoding="utf-8")
# Engine starts at STEP 4 marker; main() is the last section
_engine_start = _template_text.index("# =============================================================================\n# STEP 4")
# Exclude main() – we write paper-specific main() below
_main_start = _template_text.index("# =============================================================================\n# MAIN")
ENGINE_BLOCK = _template_text[_engine_start:_main_start]


# ── Per-paper configuration ──────────────────────────────────────────────────
PAPERS = {
    "0018": {
        "folder": "Paper_0018_AntiCorruption",
        "title": "Anti-Corruption Subsidies and R&D Efficiency",
        "estimator_note": "pyfixest.feols(), CRV1 clustered on firm; Two-way FE: | firm + year",
        "table_ref": "Table 5, Panel A",
        "author_year": "AntiCorruption",
        "source_file": "source_artifacts/Paper_AntiCorruption/main_dataset.csv",
        "data_format": "csv",
        "sample_filter": None,
        "extra_preprocessing": None,
        # FOCAL_IV changed to the post-removal interaction (main published finding)
        # lrdefficiency alone is non-significant; lrdefficiency_postremoval (DID term) is the key result
        "DEPENDENT_VAR": "subsidy_s",
        "FOCAL_IV": "lrdefficiency_postremoval",
        # Full spec from .do: reghdfe subsidy_s lrdefficiency laetc_s lpostremoval
        # lrdefficiency_postremoval laetc_postremoval $ControlVar1, absorb(firm year) vce(cluster firm)
        "CONTROLS": [
            "laetc_s", "lpostremoval",
            "lrdefficiency_postremoval", "laetc_postremoval",
            "lsoe", "lpolitical", "lroa", "ltobinq", "lleverage",
        ],
        "FE_VARS": ["firm", "year"],
        "CLUSTER_VAR": "firm",
        "KEY_VARIABLES": ["lroa", "ltobinq", "lleverage"],
        "MAR_CONTROL": "age",
        "EXTRA_FORMULA_TERMS": None,
        "EXTRA_VARS": [],
    },
    "0019": {
        "folder": "Paper_0019_AntidiscrimLaws",
        "title": "Anti-Discrimination Laws and Firm Performance",
        "estimator_note": (
            "pyfixest.feols(), CRV1 clustered on cm_id; "
            "Two-way FE: | cm_id + fyear; state×year trend via i(state_id, fyear); "
            "Sample: census_region_south notna & randsamp1 notna"
        ),
        "table_ref": "Table 4, Operating Profitability",
        "author_year": "AntidiscrimLaws",
        "source_file": "source_artifacts/Paper_AntidiscriminationLawsPerformance/ad_dataset_ms1.dta",
        "data_format": "dta",
        "sample_filter": "census_region_south_notna_randsamp1_notna",
        "extra_preprocessing": None,
        "DEPENDENT_VAR": "oibdp_atw",
        "FOCAL_IV": "ad_law2",
        "CONTROLS": ["ln_at_adj", "ppent_at", "div_payer", "state_inc_growth"],
        "FE_VARS": ["cm_id", "fyear"],
        "CLUSTER_VAR": "cm_id",
        "KEY_VARIABLES": ["ln_at_adj", "ppent_at", "state_inc_growth"],
        "MAR_CONTROL": "lev_lt_at",
        "EXTRA_FORMULA_TERMS": "i(state_id, fyear)",
        "EXTRA_VARS": ["state_id"],
    },
    "0020": {
        "folder": "Paper_0020_CompetingAttention",
        "title": "Competing for Digital Attention",
        "estimator_note": "pyfixest.feols(), CRV1 clustered on metaID; Two-way FE: | metaID + monthtime",
        "table_ref": "Table 2, Column 4",
        "author_year": "CompetingAttention",
        "source_file": "source_artifacts/Paper_CompetingForAttention/SMJ_Final.dta",
        "data_format": "dta",
        "sample_filter": None,
        "extra_preprocessing": None,
        "DEPENDENT_VAR": "logTotalVisits",
        "FOCAL_IV": "afterXVGM",
        "CONTROLS": ["post_lav_Visits", "post_lav_Visits_VGM", "post_lHerfCont", "post_lHerfCont_VGM"],
        "FE_VARS": ["metaID", "monthtime"],
        "CLUSTER_VAR": "metaID",
        "KEY_VARIABLES": ["post_lav_Visits", "post_lHerfCont", "post_lav_Visits_VGM"],
        "MAR_CONTROL": "lHerfCont",
        "EXTRA_FORMULA_TERMS": None,
        "EXTRA_VARS": [],
    },
    "0022": {
        "folder": "Paper_0022_DemandPull",
        "title": "Demand-Pull Innovation and Startup Revenue",
        "estimator_note": (
            "pyfixest.feols(), robust SEs (hetero); Entity FE: | SN; "
            "DiD spec: RevenueLikert ~ Post + Post_x_Treatment + Age + WorkExp + EntrepExperience | SN; "
            "Post_x_Treatment = Post * Treatment (interaction created in preprocessing)"
        ),
        "table_ref": "Table 3, Panel A",
        "author_year": "DemandPull",
        "source_file": "source_artifacts/Paper_DemandPull/STATA CODE 3560.dta",
        "data_format": "dta",
        "sample_filter": None,
        "extra_preprocessing": "create_post_x_treatment",
        "DEPENDENT_VAR": "RevenueLikert",
        "FOCAL_IV": "Post_x_Treatment",
        "CONTROLS": ["Post", "Age", "WorkExp", "EntrepExperience"],
        "FE_VARS": ["SN"],
        "CLUSTER_VAR": None,
        "KEY_VARIABLES": ["Age", "WorkExp", "EntrepExperience"],
        "MAR_CONTROL": "TeamSize",
        "EXTRA_FORMULA_TERMS": None,
        "EXTRA_VARS": [],
    },
    "0023": {
        "folder": "Paper_0023_EffectIPO",
        "title": "Effect of IPO on Tax Avoidance",
        "estimator_note": "pyfixest.feols(), CRV1 clustered on gvkey; Year FE absorbed: | fyear",
        "table_ref": "Table 3, Column 1",
        "author_year": "EffectIPO",
        "source_file": "source_artifacts/Paper_EffectOfIPO/sample_full.xlsx",
        "data_format": "xlsx",
        "sample_filter": None,
        "extra_preprocessing": None,
        "DEPENDENT_VAR": "ch1_gaap_etr",
        "FOCAL_IV": "diff_laggaap_etr",
        "CONTROLS": [
            "diff_median_laggaap_etr",
            "ch1_s_rd", "ch1_s_ad", "ch1_s_sga", "ch1_s_capexp",
            "ch1_s_cash", "ch1_s_fi", "ch1_s_eqinc", "ch1_nol",
            "ch1_s_intangible", "ch1_s_ppent", "ch1_s_fcf",
            "ch1_size", "ch1_roa_pretax", "ch1_lev_lt",
        ],
        "FE_VARS": ["fyear"],
        "CLUSTER_VAR": "gvkey",
        "KEY_VARIABLES": ["ch1_s_rd", "ch1_s_sga", "ch1_roa_pretax", "ch1_size"],
        "MAR_CONTROL": "ln_mve",
        "EXTRA_FORMULA_TERMS": None,
        "EXTRA_VARS": [],
    },
    "0021": {
        "folder": "Paper_0021_CorporateBoards",
        "title": "Reshaping Corporate Boards Through Mandatory Gender Diversity Disclosures",
        "estimator_note": (
            "pyfixest.feols(), CRV1 clustered on gvkey; Two-way FE: | gvkey + fyear; "
            "DiD spec: n1pfdir1 ~ post1_x_treat1 + controls | gvkey + fyear; "
            "post1_x_treat1 = post1 * treat1 (interaction created in preprocessing); "
            "sizetausd logged in preprocessing"
        ),
        "table_ref": "Table 3, Column 4",
        "author_year": "CorporateBoards",
        "source_file": "source_artifacts/Paper_CorporateBoards/dirfin_main.dta",
        "data_format": "dta",
        "sample_filter": None,
        "extra_preprocessing": "corporate_boards_preprocessing",
        "DEPENDENT_VAR": "n1pfdir1",
        "FOCAL_IV": "post1_x_treat1",
        "CONTROLS": [
            "tio1", "fceo1", "ceocob", "pidir1", "lndirtenure",
            "bdsize1", "mb", "lev", "ln_sizetausd", "ptita", "aret", "lnfirmage",
        ],
        "FE_VARS": ["gvkey", "fyear"],
        "CLUSTER_VAR": "gvkey",
        "KEY_VARIABLES": ["ptita", "mb", "lev", "aret"],
        "MAR_CONTROL": "tio1",
        "EXTRA_FORMULA_TERMS": None,
        "EXTRA_VARS": [],
    },
    "0024": {
        "folder": "Paper_0024_HedingHill",
        "title": "Hedging on the Hill: Political Risk and Idiosyncratic Volatility",
        "estimator_note": "pyfixest.feols(), CRV1 clustered on gvkey; Two-way FE: | gvkey + year",
        "table_ref": "Table 2, Column 3",
        "author_year": "HedingHill",
        "source_file": "source_artifacts/Paper_HedingOnTheHill/firmcyclepanel.dta",
        "data_format": "dta",
        "sample_filter": None,
        "extra_preprocessing": None,
        "DEPENDENT_VAR": "idiovol",
        "FOCAL_IV": "politicalhedge",
        "CONTROLS": [
            "politicalconnections", "mktvol", "beta", "mve",
            "btm", "roa", "loss", "cash", "govtsales",
            "zscore", "leverage", "competition", "ppe",
        ],
        "FE_VARS": ["gvkey", "year"],
        "CLUSTER_VAR": "gvkey",
        "KEY_VARIABLES": ["mktvol", "beta", "btm", "competition"],
        "MAR_CONTROL": "roa",
        "EXTRA_FORMULA_TERMS": None,
        "EXTRA_VARS": [],
    },
    "0025": {
        "folder": "Paper_0025_PathwaysProfits",
        "title": "Pathways to Profits: Impact of Marketing vs. Finance Skills",
        "estimator_note": (
            "pyfixest.feols(), robust SEs (hetero); No entity FE (RCT); "
            "Industry dummies absorbed via | Ind2_SIC (see extra_preprocessing); "
            "Sample: Sample_endline == 1; "
            "pre_Profits3_composite_w1 included as control for baseline outcome"
        ),
        "table_ref": "Table 5, Column 6",
        "author_year": "PathwaysProfits",
        "source_file": "source_artifacts/Paper_PathwaysToProfits/P2P_dataset.dta",
        "data_format": "dta",
        "sample_filter": "endline_survey_round",
        "extra_preprocessing": None,
        "DEPENDENT_VAR": "Profits3_composite_w1",
        "FOCAL_IV": "Treatment_FIN",
        "CONTROLS": [
            "Treatment_MKT",
            "Gender", "Age", "Children_total",
            "Race_SAblackcolored", "Race_Foreigner", "Educ_high",
            "Operating_yearstotal", "Activity_Hours",
            "pre_Employees1_composite", "FormalReg",
            "pre_Profits3_composite_w1",
            "Ind2_SIC15", "Ind2_SIC17", "Ind2_SIC23", "Ind2_SIC25", "Ind2_SIC34",
            "Ind2_SIC41", "Ind2_SIC54", "Ind2_SIC56", "Ind2_SIC57", "Ind2_SIC58",
            "Ind2_SIC59", "Ind2_SIC72", "Ind2_SIC73", "Ind2_SIC75", "Ind2_SIC76",
            "Ind2_SIC83",
        ],
        "FE_VARS": [],  # Cross-section OLS: no FE (industry dummies in CONTROLS)
        "CLUSTER_VAR": None,
        "KEY_VARIABLES": ["Age", "Operating_yearstotal", "Activity_Hours", "pre_Profits3_composite_w1"],
        "MAR_CONTROL": "Distance2training_miles",
        "EXTRA_FORMULA_TERMS": None,
        "EXTRA_VARS": [],
    },
}


def _py_list(lst):
    """Format a Python list literal."""
    if not lst:
        return "[]"
    items = ",\n        ".join(f'"{v}"' for v in lst)
    return f"[\n        {items},\n    ]"


def _build_load_function(paper_id: str, p: dict) -> str:
    source_path = p["source_file"]
    fmt = p["data_format"]
    sample_filter = p["sample_filter"]
    extra_preproc = p["extra_preprocessing"]

    # Build loader body
    if fmt == "csv":
        loader = f"""
    if DATA_CSV.exists() and not force_reload:
        log.info(f"Loading from {{DATA_CSV}}")
        df = pd.read_csv(DATA_CSV)
        _print_inspection_report(df, source="DATA.csv")
        return df

    log.info(f"Loading source CSV from {{SOURCE_FILE}}")
    df = pd.read_csv(str(SOURCE_FILE))
    # Convert Stata-style categoricals to numeric where possible
    for _col in df.columns:
        if str(df[_col].dtype) in ('category', 'object'):
            _conv = pd.to_numeric(df[_col], errors='coerce')
            if _conv.notna().sum() >= 0.5 * len(df):
                df[_col] = _conv
"""
    elif fmt == "xlsx":
        loader = f"""
    if DATA_CSV.exists() and not force_reload:
        log.info(f"Loading from {{DATA_CSV}}")
        df = pd.read_csv(DATA_CSV)
        _print_inspection_report(df, source="DATA.csv")
        return df

    log.info(f"Loading source XLSX from {{SOURCE_FILE}}")
    df = pd.read_excel(str(SOURCE_FILE))
    # Convert Stata-style categoricals to numeric where possible
    for _col in df.columns:
        if str(df[_col].dtype) in ('category', 'object'):
            _conv = pd.to_numeric(df[_col], errors='coerce')
            if _conv.notna().sum() >= 0.5 * len(df):
                df[_col] = _conv
"""
    else:  # dta
        loader = f"""
    if DATA_CSV.exists() and not force_reload:
        log.info(f"Loading from {{DATA_CSV}}")
        df = pd.read_csv(DATA_CSV)
        _print_inspection_report(df, source="DATA.csv")
        return df

    log.info(f"Loading source .dta from {{SOURCE_FILE}}")
    try:
        import pyreadstat
        df, _ = pyreadstat.read_dta(str(SOURCE_FILE))
        log.info("Loaded with pyreadstat")
    except ImportError:
        log.warning("pyreadstat not found -- falling back to pandas.read_stata")
        df = pd.read_stata(str(SOURCE_FILE))
    # Convert Stata value-labeled (category) columns to numeric where possible
    for _col in df.columns:
        if str(df[_col].dtype) == 'category':
            _conv = pd.to_numeric(df[_col], errors='coerce')
            if _conv.notna().sum() >= 0.5 * len(df):
                df[_col] = _conv
"""

    # Sample filter
    if sample_filter == "endline_survey_round":
        filter_code = """
    # Sample restriction: endline survey round only (T_survey_round==3 & Sample_endline==1)
    before = len(df)
    max_round = int(df["T_survey_round"].max())
    df = df[(df["T_survey_round"] == max_round) & (df["Sample_endline"] == 1)].copy()
    log.info(f"Endline survey filter (T_survey_round=={max_round} & Sample_endline==1): {before:,} -> {len(df):,} rows")
"""
    elif sample_filter == "census_region_south_notna_randsamp1_notna":
        filter_code = """
    # Sample restriction: census_region_south!=. & randsamp1!=.
    before = len(df)
    df = df[df["census_region_south"].notna() & df["randsamp1"].notna()].copy()
    log.info(f"Sample restriction applied: {before:,} -> {len(df):,} rows")
"""
    else:
        filter_code = ""

    # Extra preprocessing
    if extra_preproc == "corporate_boards_preprocessing":
        extra_code = """
    # DiD interaction: post1 x treat1 (Post × Treat)
    df["post1_x_treat1"] = df["post1"].fillna(0) * df["treat1"].fillna(0)
    log.info("Created post1_x_treat1 interaction column")
    # Log transform firm size
    import numpy as np
    df["ln_sizetausd"] = np.log1p(df["sizetausd"].clip(lower=0))
    log.info("Created ln_sizetausd (log firm size)")
"""
    elif extra_preproc == "create_post_x_treatment":
        extra_code = """
    # DiD interaction: Post x Treatment
    df["Post_x_Treatment"] = df["Post"].fillna(0) * df["Treatment"].fillna(0)
    log.info("Created Post_x_Treatment interaction column")
"""
    else:
        extra_code = ""

    save_csv = """
    _print_inspection_report(df, source=str(SOURCE_FILE))
    df.to_csv(DATA_CSV, index=False)
    log.info(f"DATA.csv written ({len(df):,} rows x {len(df.columns)} cols)")
    return df
"""

    return f"""
# =============================================================================
# STEP 1 -- DATA LOADING
# =============================================================================
def load_and_inspect_data(force_reload: bool = False) -> pd.DataFrame:
    {loader}
    {filter_code}
    {extra_code}
    {save_csv}


def _print_inspection_report(df: pd.DataFrame, source: str) -> None:
    print("\\n" + "=" * 72)
    print(f"DATA INSPECTION  Source: {{source}}  Shape: {{df.shape[0]:,}} x {{df.shape[1]}}")
    print("=" * 72)
    miss = df.isnull().mean()
    miss_nonzero = miss[miss > 0]
    if miss_nonzero.empty:
        print("  No missing values detected.")
    else:
        for col, rate in miss_nonzero.items():
            print(f"  MISSING  {{col:<40}} {{rate:.4f}}")
    key_vars = [Config.DEPENDENT_VAR, Config.FOCAL_IV] + Config.CONTROLS
    for v in key_vars:
        if v in df.columns:
            try:
                s = df[v].describe()
                mean_v = float(s.get('mean', float('nan')))
                std_v = float(s.get('std', float('nan')))
                print(f"  OK  {{v:<40}} mean={{mean_v:9.4f}}  std={{std_v:9.4f}}  missing={{df[v].isnull().sum()}}")
            except Exception:
                print(f"  OK  {{v:<40}} dtype={{df[v].dtype}}  missing={{df[v].isnull().sum()}}")
        else:
            print(f"  ABSENT: {{v}}")
    print("=" * 72)
"""


def _build_regression_functions(paper_id: str, p: dict) -> str:
    cluster_var = p["CLUSTER_VAR"]
    extra_terms = p["EXTRA_FORMULA_TERMS"]
    extra_vars = p["EXTRA_VARS"]
    table_ref = p["table_ref"]

    # vcov logic (no leading spaces — the f-string template provides indentation)
    if cluster_var:
        vcov_line = 'vcov = {"CRV1": Config.CLUSTER_VAR}'
    else:
        vcov_line = 'vcov = "hetero"'

    # formula extra terms logic
    if extra_terms:
        formula_line = (
            '    formula_extra = getattr(Config, "EXTRA_FORMULA_TERMS", None)\n'
            '    x_str = " + ".join(x)\n'
            '    if formula_extra:\n'
            '        x_str += " + " + formula_extra\n'
            '    formula = f"{y} ~ {x_str} | {fe}"'
        )
        # cols for dropna: exclude formula-level terms like i(...)
        dropna_line = (
            '    real_cols = [c for c in ([y] + x + Config.FE_VARS) if not c.startswith("i(")]\n'
            '    for ev in getattr(Config, "EXTRA_VARS", []):\n'
            '        if ev not in real_cols and ev in df.columns:\n'
            '            real_cols.append(ev)\n'
            '    df_clean = df[[c for c in real_cols if c in df.columns]].dropna()'
        )
    else:
        formula_line = '    formula = f"{y} ~ {chr(32).join(x)} | {fe}"'
        dropna_line = (
            '    df_clean = df[[c for c in ([y] + x + Config.FE_VARS) if c in df.columns]].dropna()'
        )

    return f"""
# =============================================================================
# STEP 2 -- BASELINE REGRESSION (pyfixest)
# =============================================================================
def _run_simulation_regression(df: pd.DataFrame):
    \"\"\"Run regression on imputed/reduced dataset. Same spec as baseline.\"\"\"
    import pyfixest as pf
    y = Config.DEPENDENT_VAR
    x = [Config.FOCAL_IV] + Config.CONTROLS
    x_str = " + ".join(x)
    formula_extra = getattr(Config, "EXTRA_FORMULA_TERMS", None)
    if formula_extra:
        x_str += " + " + formula_extra
    if Config.FE_VARS:
        fe = " + ".join(Config.FE_VARS)
        formula = f"{{y}} ~ {{x_str}} | {{fe}}"
    else:
        formula = f"{{y}} ~ {{x_str}}"
    real_cols = [c for c in ([y] + x + Config.FE_VARS) if not c.startswith("i(")]
    # Always include cluster var and extra vars in the subset for pyfixest
    for ev in ([Config.CLUSTER_VAR] if Config.CLUSTER_VAR else []) + getattr(Config, "EXTRA_VARS", []):
        if ev and ev not in real_cols and ev in df.columns:
            real_cols.append(ev)
    df_clean = df[[c for c in real_cols if c in df.columns]].dropna()
    if len(df_clean) < 50:
        raise ValueError(f"Too few observations: {{len(df_clean)}}")
    {vcov_line}
    fit = pf.feols(formula, data=df_clean, vcov=vcov)
    return fit


def run_baseline_regression(df: pd.DataFrame):
    import pyfixest as pf
    log.info("Running baseline regression (pyfixest)...")
    y = Config.DEPENDENT_VAR
    x = [Config.FOCAL_IV] + Config.CONTROLS
    x_str = " + ".join(x)
    formula_extra = getattr(Config, "EXTRA_FORMULA_TERMS", None)
    if formula_extra:
        x_str += " + " + formula_extra
    if Config.FE_VARS:
        fe = " + ".join(Config.FE_VARS)
        formula = f"{{y}} ~ {{x_str}} | {{fe}}"
    else:
        formula = f"{{y}} ~ {{x_str}}"
    real_cols = [c for c in ([y] + x + Config.FE_VARS) if not c.startswith("i(")]
    for ev in ([Config.CLUSTER_VAR] if Config.CLUSTER_VAR else []) + getattr(Config, "EXTRA_VARS", []):
        if ev and ev not in real_cols and ev in df.columns:
            real_cols.append(ev)
    df_reg = df[[c for c in real_cols if c in df.columns]].dropna()
    log.info(f"Regression sample N = {{len(df_reg):,}}")
    {vcov_line}
    fit = pf.feols(formula, data=df_reg, vcov=vcov)
    _print_baseline_table(fit, len(df_reg))
    return fit


def _print_baseline_table(fit, n_obs: int) -> None:
    sep = "=" * 72
    print(sep)
    print(f"BASELINE REGRESSION -- {table_ref}  N={{n_obs:,}}")
    print(sep)
    tidy = fit.tidy()
    for var in [Config.FOCAL_IV] + Config.CONTROLS:
        if var in tidy.index:
            c = float(tidy.loc[var, "Estimate"])
            s = float(tidy.loc[var, "Std. Error"])
            pv = float(tidy.loc[var, "Pr(>|t|)"])
            sig = "***" if pv < 0.001 else "**" if pv < 0.01 else "*" if pv < 0.05 else ""
            print(f"  {{var:<43}} {{c:10.4f}} {{s:10.4f}} {{pv:10.4f}} {{sig}}")
    try:
        for line in str(fit.summary()).splitlines():
            if "R2" in line or "r2" in line.lower():
                print(f"  {{line.strip()}}")
    except Exception:
        pass
    print(sep)
"""


def build_script(paper_id: str, p: dict) -> str:
    controls_repr = _py_list(p["CONTROLS"])
    fe_vars_repr = _py_list(p["FE_VARS"])
    key_vars_repr = _py_list(p["KEY_VARIABLES"])
    cluster_repr = f'"{p["CLUSTER_VAR"]}"' if p["CLUSTER_VAR"] else "None"
    extra_terms_repr = f'"{p["EXTRA_FORMULA_TERMS"]}"' if p["EXTRA_FORMULA_TERMS"] else "None"
    extra_vars_repr = _py_list(p["EXTRA_VARS"])
    predictor_pool = (
        [p["DEPENDENT_VAR"], p["FOCAL_IV"]]
        + p["CONTROLS"]
        + [p["MAR_CONTROL"]]
    )
    # Remove duplicates while preserving order
    seen = set()
    predictor_pool_dedup = []
    for v in predictor_pool:
        if v not in seen:
            seen.add(v)
            predictor_pool_dedup.append(v)
    # Add EXTRA_VARS to predictor pool
    for v in p["EXTRA_VARS"]:
        if v not in seen:
            seen.add(v)
            predictor_pool_dedup.append(v)
    predictor_pool_repr = _py_list(predictor_pool_dedup)

    header = f'''"""
Paper {paper_id} -- {p["title"]}
Simulation script: baseline replication + Monte Carlo missing-data analysis
Governing manual: RA_MISSING_DATA.pdf

USAGE:
  Phase 1 (baseline only):   python simulation_{paper_id}.py --mode baseline
  Phase 2 (smoke test):      python simulation_{paper_id}.py --mode smoke
  Phase 3 (full run):        python simulation_{paper_id}.py --mode full

Estimator: {p["estimator_note"]}
"""

import argparse
import hashlib
import logging
import sys
import warnings
from collections import defaultdict
from pathlib import Path
from types import SimpleNamespace

import numpy as np
import pandas as pd
from scipy import stats as sp_stats
from scipy.stats import t as t_dist
from sklearn.experimental import enable_iterative_imputer  # noqa: F401
from sklearn.impute import IterativeImputer
from sklearn.linear_model import BayesianRidge, LinearRegression
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import StandardScaler

warnings.filterwarnings("ignore")

# ---- Paths ------------------------------------------------------------------
SCRIPT_DIR = Path(__file__).parent
PAPER_DIR = SCRIPT_DIR.parent          # paper root (one level above scripts/)
SOURCE_FILE = (
    PAPER_DIR.parent.parent
    / "{p["source_file"]}"
)
DATA_CSV = PAPER_DIR / "DATA.csv"
LOG_FILE = PAPER_DIR / "logs" / "simulation_{paper_id}.log"

# ---- Logging ----------------------------------------------------------------
LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)s  %(message)s",
    handlers=[
        logging.FileHandler(LOG_FILE, encoding="utf-8"),
        logging.StreamHandler(sys.stdout),
    ],
)
log = logging.getLogger(__name__)


# =============================================================================
# CONFIG
# =============================================================================
class Config:
    MISSINGNESS_LEVELS = [0.01, 0.05, 0.10, 0.20, 0.30, 0.40, 0.50]
    SMOKE_MISSINGNESS_LEVELS = [0.01, 0.10]
    NUM_ITERATIONS_PER_SCENARIO = 30
    SMOKE_ITERATIONS = 2
    N_IMPUTATIONS = 5
    MICE_ITERATIONS = 5
    MAR_NMAR_STRENGTH = 1.5
    ALPHA = 0.05
    RANDOM_SEED = 42
    ADD_RESIDUAL_NOISE = True
    DL_EPOCHS = 30
    DL_PATIENCE = 5
    MICE_LGBM_N_ESTIMATORS = 30
    MICE_LGBM_MAX_DEPTH = 4
    MICE_LGBM_LEARNING_RATE = 0.05
    MICE_LGBM_NUM_LEAVES = 10

    # Regression specification
    DEPENDENT_VAR = "{p["DEPENDENT_VAR"]}"
    FOCAL_IV = "{p["FOCAL_IV"]}"
    CONTROLS = {controls_repr}
    FE_VARS = {fe_vars_repr}
    CLUSTER_VAR = {cluster_repr}
    WEIGHTS = None

    # Optional pyfixest formula extras (e.g. state-year trends)
    EXTRA_FORMULA_TERMS = {extra_terms_repr}
    EXTRA_VARS = {extra_vars_repr}

    # Locked
    KEY_VARIABLES = {key_vars_repr}
    MAR_CONTROL = "{p["MAR_CONTROL"]}"
    PREDICTOR_POOL = {predictor_pool_repr}

    MECHANISMS = ["MCAR", "MAR", "NMAR"]
    METHODS = ["LD", "Mean", "Reg", "Iter", "RF", "DL", "MILGBM"]

    REPORT_WORKBOOK = PAPER_DIR / "full_run" / "{p["author_year"]}Report_{paper_id}.xlsx"
    SMOKE_WORKBOOK = PAPER_DIR / "smoke" / "SMOKE_{p["author_year"]}Report_{paper_id}.xlsx"
    REGRESSION_TXT_DIR = PAPER_DIR / "regression_outputs"
    PROGRESS_LOG = PAPER_DIR / "logs" / "simulation_{paper_id}_progress.log"
'''

    load_fn = _build_load_function(paper_id, p)
    reg_fns = _build_regression_functions(paper_id, p)

    # Extract coefficient extraction + save_iter_txt from 0005 (lines 218-309)
    coef_extract_start = _template_text.index("# =============================================================================\n# STEP 3")
    coef_extract_end = _engine_start
    coef_block = _template_text[coef_extract_start:coef_extract_end]
    # Replace hard-coded paper ID in the txt header (f"Paper: 0005\n" → f"Paper: XXXX\n")
    coef_block = coef_block.replace("Paper: 0005", f"Paper: {paper_id}")

    main_fn = f"""

# =============================================================================
# MAIN
# =============================================================================
def main():
    parser = argparse.ArgumentParser(description="Paper {paper_id} simulation")
    parser.add_argument("--mode", choices=["baseline", "smoke", "full"], default="baseline")
    parser.add_argument("--reload", action="store_true")
    args = parser.parse_args()

    Config.PROGRESS_LOG = PAPER_DIR / "logs" / f"simulation_{paper_id}_progress_{{args.mode}}.log"

    log.info("=" * 60)
    log.info(f"Paper {paper_id} -- Mode: {{args.mode.upper()}}")
    log.info("=" * 60)

    df = load_and_inspect_data(force_reload=args.reload)
    baseline_fit = run_baseline_regression(df)

    if args.mode == "baseline":
        log.info("Baseline mode complete. Check output above.")
        return

    run_simulation(df, baseline_fit, mode=args.mode)


if __name__ == "__main__":
    main()
"""

    return header + "\n" + load_fn + "\n" + reg_fns + "\n" + coef_block + "\n" + ENGINE_BLOCK + "\n" + main_fn


def main():
    for paper_id, paper in PAPERS.items():
        out_dir = REPO_ROOT / "paper_analysis_output" / paper["folder"] / "scripts"
        out_dir.mkdir(parents=True, exist_ok=True)
        out_path = out_dir / f"simulation_{paper_id}.py"
        script = build_script(paper_id, paper)
        out_path.write_text(script, encoding="utf-8")
        print(f"Written ({len(script):,} chars): {out_path.relative_to(REPO_ROOT)}")

    print("\nAll scripts generated.")


if __name__ == "__main__":
    main()
