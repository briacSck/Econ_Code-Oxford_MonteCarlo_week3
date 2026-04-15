# Local Status Tracking

Updated: 2026-04-12

| PaperID | ShortTitle | Status | Baseline | Notes |
|---------|-----------|--------|----------|-------|
| 0005 | MappingEntrepreneurial | DELIVERABLE_DONE | 0.0307*** | Re-run complete. 17,640/17,640, 0 errors. AuthorYearReport_0005.xlsx (3.7 MB, 19 sheets, 17,640 real coef rows). Committed + pushed. |
| 0017 | StatusConsensus | DELIVERABLE_DONE | 0.0468*** | Finalized in Week 2. |
| 0018 | AntiCorruption | DELIVERABLE_DONE | 0.006* (p=0.096) | 13,230/13,230. 0 errors. AuthorYearReport_0018.xlsx (2.8 MB, 19 sheets). 441/441 N_iters=30. Committed + pushed. |
| 0019 | AntidiscrimLaws | DELIVERABLE_DONE | -0.0110** | 13,230/13,230. 313 singularity errors (benign). Committed + pushed. |
| 0020 | CompetingAttention | DELIVERABLE_DONE | 1.137* | 13,230/13,230. 0 errors. Committed + pushed. |
| 0021 | CorporateBoards | DELIVERABLE_DONE | 0.033*** | 17,640/17,640. 0 errors. AuthorYearReport_0021.xlsx (2.7 MB, 19 sheets, rebuild_summary). 1 null-byte txt (MAR/1pct/aret/MILGBM/iter4) — benign. Committed + pushed. |
| 0022 | DemandPull | DELIVERABLE_DONE | 0.374~ | 13,230/13,230. 0 errors. Committed + pushed. |
| 0023 | EffectIPO | DELIVERABLE_DONE | -0.041*** | 17,640/17,640. 0 errors. AuthorYearReport_0023.xlsx (1.7 MB, 19 sheets). Summary sheets rebuilt from txt (resumed run). Committed + pushed. |
| 0024 | HedingHill | DELIVERABLE_DONE | -0.031*** | 17,640/17,640. 0 errors. AuthorYearReport_0024.xlsx (3.7 MB, 19 sheets). 588/588 N_iters=30. Committed + pushed. |
| 0025 | PathwaysProfits | DELIVERABLE_DONE | 2,231* | 17,640/17,640. 0 errors. AuthorYearReport_0025.xlsx (1.7 MB, 19 sheets, rebuild_summary). Committed + pushed. |

## Active processes (2026-04-12)
- 0021 full run: ~37% (large panel, N=21,898)
- 0023 full run: ~83%

## Queue
- **When 0023 finishes → launch 0024 full**
- **When another slot frees → launch 0025 full**
- 0018: hold pending focal IV verification

## QC + deliverables done
| Paper | AuthorYearReport | Size | Committed |
|-------|-----------------|------|-----------|
| 0005 | AuthorYearReport_0005.xlsx | 3.7 MB | ✓ |
| 0017 | AuthorYearReport_0017.xlsx | 3.6 MB | ✓ |
| 0019 | AuthorYearReport_0019.xlsx | 2.7 MB | ✓ |
| 0020 | AuthorYearReport_0020.xlsx | 2.8 MB | ✓ |
| 0022 | AuthorYearReport_0022.xlsx | 2.8 MB | ✓ |

## Helper commands
```bash
# Check all active runs
for id in 0005 0021 0023; do echo -n "$id: "; wc -l paper_analysis_output/Paper_${id}_*/logs/simulation_${id}_progress_full.log; done

# Launch next pair when ready
bash scripts/run_paper.sh 0024 full   # when a slot frees
bash scripts/run_paper.sh 0025 full   # last paper
```
