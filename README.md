# Oxford Missing Data Study — Monte Carlo Simulation

This repository contains a Monte Carlo simulation study evaluating how seven missing-data imputation methods affect core regression conclusions across ten published management papers. For each paper, artificial missingness is introduced into key control variables, seven imputation methods are applied, the original regression is re-estimated, and coefficient stability is tracked across 30 iterations per cell.

**Research question:** When data contain varying missingness under different mechanisms (MCAR, MAR, NMAR), do different imputation strategies alter a study's core regression conclusions — sign, magnitude, or significance?

---

## Repository Structure

```
.
├── generate_deliverables.py      # Produces AuthorYear_Report.xlsx + Paper_Info_Record.pdf for all papers
├── generate_figures.py           # Publication-quality stability figures (3 per paper)
├── qc_audit.py                   # Automated QC verification (all 10 QC items per manual Table 6)
├── requirements.txt              # Python dependencies
├── RA_MISSING_DATA.pdf           # Operations manual v2.0 (authoritative specification)
├── qc_audit_results.csv          # QC audit output (all 10 papers x 10 checks)
│
├── paper_info_{id}.xlsx          # Input metadata for each paper (10 files, ids 0005-0025)
│
├── {AuthorYear}_Report.xlsx      # Root-level copies of main simulation workbooks (10 files)
├── Paper_Info_Record_{AuthorYear}.pdf  # Root-level copies of Paper Info Records (10 files)
│
├── scripts/
│   └── run_paper.sh              # Runs baseline -> smoke -> full simulation for a single paper
│
└── paper_analysis_output/
    └── Paper_{id}_{ShortName}/   # Per-paper output directory (10 directories)
        ├── DATA.csv                    # Preprocessed data used in simulation
        ├── Paper_Info_Record.pdf       # Paper Information Record (Appendix A template)
        ├── confignotes.txt             # Baseline validation log + setup decisions
        ├── scripts/
        │   └── simulation_{id}.py      # Paper-specific simulation script
        ├── full_run/
        │   ├── {AuthorYear}_Report.xlsx     # Main simulation workbook (19 sheets, Appendix B)
        │   └── figures/                      # Stability figures (3 PNGs)
        └── regression_outputs/
            ├── MCAR/{1pct..50pct}/{VarName}/{method}/iter{n}_model_{key}.txt
            ├── MAR/
            └── NMAR/
```

---

## Completed Papers

| Paper ID | AuthorYear | Short Title | N Runs | Focal IV | Baseline p |
|----------|-----------|-------------|--------|----------|-----------|
| 0005 | Stroube2025 | Mapping Entrepreneurial Inclusion (Shopify/ZCTA) | 17,640 | log_pop_black_aa | <0.001*** |
| 0017 | Stroube2024 | Status and Consensus (Film Ratings) | 17,640 | FLead | <0.001*** |
| 0018 | Fang2022 | Anti-Corruption, R&D Efficiency, and Subsidies | 13,230 | lrdefficiency_postremoval | 0.096* |
| 0019 | Greene2021 | Anti-Discrimination Laws and Firm Performance | 13,230 | ad_law2 | 0.001** |
| 0020 | Meyer2024 | Competing for Attention on Digital Platforms | 13,230 | afterXVGM | 0.020* |
| 0021 | Hu2025 | Reshaping Corporate Boards (Gender Diversity) | 17,640 | post1_x_treat1 | <0.001*** |
| 0022 | Santamaria2024 | Demand-Pull vs. Resource-Push Entrepreneurship Training | 13,230 | Post_x_Treatment | 0.052 |
| 0023 | Chyz2023 | Effect of IPO Firms on Industry Tax Planning | 17,640 | diff_laggaap_etr | <0.001*** |
| 0024 | Christensen2021 | Hedging on the Hill (Political Hedging) | 17,640 | politicalhedge | <0.001*** |
| 0025 | Anderson2018 | Pathways to Profits (Marketing vs. Finance Skills) | 17,640 | Treatment_FIN | 0.035* |

---

## Deliverables Per Paper

Each paper produces two primary deliverables:

**`{AuthorYear}_Report.xlsx`** — 19-sheet simulation workbook (Appendix B):
- `00_PaperInfo` — paper metadata
- `Baseline_Descriptives`, `Baseline_Correlations`, `Baseline_Regression`
- `Mean_Stability_MCAR/MAR/NMAR` — B-proportion and Wilson CIs by method x proportion
- `Model_Comparison`, `Stats_Features`, `Coef_Stability_Summary`, `Benchmark_Methods`
- `MI_Diagnostics`, `MI_Trace`, `MI_Overimputation`, `MI_Distribution`
- `Missingness_Patterns`, `NMAR_Residual`, `NMAR_Delta`
- `IterationDetail` — one row per simulation iteration (mechanism x proportion x key_var x method x iter) with coef, SE, p-value, sign/significance match flags; full traceability

**`Paper_Info_Record.pdf`** — structured record matching Appendix A template (6 sections: General Information, Data Structure, Core Regression Model, Simulation Configuration, Baseline Validation, Run Log).

---

## Simulation Design

| Parameter | Value |
|-----------|-------|
| Mechanisms | MCAR, MAR, NMAR |
| Missingness proportions | 1%, 5%, 10%, 20%, 30%, 40%, 50% |
| Imputation methods | LD, Mean, Reg, Iter, RF, DL, MI-LGBM |
| Iterations per cell | 30 |
| MAR/NMAR strength | 1.5 |
| MI datasets (M) | 5 (Rubin's Rules pooling) |
| Key variables per paper | 3-4 |
| Total runs (4 key vars) | 3 x 7 x 4 x 7 x 30 = 17,640 |
| Total runs (3 key vars) | 3 x 7 x 3 x 7 x 30 = 13,230 |

**Primary metric:** `B_prop` (Both Same) — fraction of iterations where the focal coefficient maintains both its sign and significance level relative to the baseline.

---

## How to Reproduce

```bash
# Install dependencies
pip install -r requirements.txt

# Regenerate all deliverables (xlsx + PDFs) for all 10 papers
python generate_deliverables.py

# Single paper
python generate_deliverables.py --paper 0005

# Generate figures
python generate_figures.py

# Run QC audit (all 10 QC items, all 10 papers)
python qc_audit.py

# Run simulation from scratch for a paper (baseline -> smoke -> full)
bash scripts/run_paper.sh 0005 full
```

**Note on raw regression outputs:** Coefficient-level results per iteration are stored as `.txt` files in `regression_outputs/` and summarized in the `IterationDetail` sheet of each workbook. Standalone `regression_results_{id}.xlsx` files are not included — all their content appears in `Baseline_Regression` and `Coef_Stability_Summary` sheets of the main workbook.

---

## QC Notes

All 10 papers pass all 10 QC items from the operations manual (verified by `qc_audit.py`). Notable paper-specific findings documented in each paper's `confignotes.txt`:

- **Fang2022 (0018):** Focal IV is borderline significant (p=0.096, one-star) by design in the most demanding FE spec. B_prop at 1% MCAR is ~93-100% (expected).
- **Greene2021 (0019):** 313 singularity errors at high missingness + LD (regression estimation failed when removed observations caused near-collinearity). Documented as benign; minimum N_iters per combo is 22.
- **Hu2025 (0021):** One null-byte file (MAR/1pct/aret/MILGBM/iter4) due to interrupted write. N_iters=29 for that combo; all others N_iters=30.
- **Santamaria2024 (0022):** Focal IV p=0.052 (not significant at 5%). B_prop at 1% MCAR is 60-80% (expected given marginal baseline significance and N=394).
- **Meyer2024 (0020) / Anderson2018 (0025):** MILGBM shows B_prop=0 at 1% MCAR for some key vars — Rubin's Rules SE inflation on small/borderline datasets, documented and expected.
