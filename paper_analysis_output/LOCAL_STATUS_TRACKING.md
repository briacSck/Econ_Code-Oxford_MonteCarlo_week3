# Local Status Tracking

Updated: 2026-04-10 ~02:11 UTC

| PaperID | ShortTitle | Status | Baseline | Notes |
|---------|-----------|--------|----------|-------|
| 0005 | MappingEntrepreneurial | FULL_IN_PROGRESS | 0.0307*** | Re-run with real feols txt. ~439/17,640 done. |
| 0018 | AntiCorruption | BASELINE_INVESTIGATION | lrdeff_postremoval ~0.006 p=0.10 | Focal IV changed; verify vs published table. Smoke not yet run. |
| 0019 | AntidiscrimLaws | FULL_IN_PROGRESS | -0.0110** | Smoke passed. Full run running. ~145/13,230 done. |
| 0020 | CompetingAttention | SMOKE_IN_PROGRESS | 1.137* | Baseline matched. Smoke running. |
| 0021 | CorporateBoards | SMOKE_IN_PROGRESS | 0.033*** (≈4.2pp) | Approximate match. Smoke running. |
| 0022 | DemandPull | FULL_IN_PROGRESS | 0.374~ | Smoke passed. Full run running. ~404/13,230 done. |
| 0023 | EffectIPO | SMOKE_IN_PROGRESS | -0.041*** | Baseline matched. Smoke running. |
| 0024 | HedingHill | SMOKE_IN_PROGRESS | -0.031*** | Baseline matched. Smoke running. |
| 0025 | PathwaysProfits | BASELINE_MATCHED | 2,231* (≈2,707 pub.) | Approximate match. Smoke not yet launched. |

## Active processes (2026-04-10 02:11)
- 0005 full run: nohup PID 1660
- 0019 full run: nohup PID 2067
- 0022 full run: nohup PID 2074
- 0020 smoke: PID 2198
- 0021 smoke: PID 2205
- 0023 smoke: PID 2215
- 0024 smoke: PID 2222

## Next steps when smokes complete
1. G2-verify smoke txt files for each paper
2. Launch full runs: 0020 + 0023 (Round 2), then 0021 + 0024 (Round 3)
3. Launch 0025 smoke, then 0025 full
4. Run 0018 smoke once focal IV confusion is resolved
5. After all fulls done: update generate_deliverables.py and run deliverables for each paper

## Helper commands
```bash
# Monitor all progress logs
for id in 0005 0019 0022; do echo "=== $id ==="; wc -l paper_analysis_output/Paper_${id}_*/logs/simulation_${id}_progress_full.log 2>/dev/null; done

# Check smoke completions
for id in 0020 0021 0023 0024; do echo "=== $id ==="; wc -l paper_analysis_output/Paper_${id}_*/logs/simulation_${id}_progress_smoke.log 2>/dev/null; done

# Launch next full run pair
bash scripts/run_paper.sh 0023 full 0020 full
bash scripts/run_paper.sh 0021 full 0024 full
bash scripts/run_paper.sh 0025 full   # alone (larger dataset)
```
