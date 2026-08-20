# Iteration Metrics History

Longitudinal tracking of team health metrics. Updated every retro. Trends matter more than individual values.

**Two-iteration degradation rule:** Any metric that worsens for two consecutive iterations requires a root-cause action item.

## Metrics Dashboard

| Metric | Target | Iter 1 | Iter 2 | Iter 3 | Trend |
|---|---|---|---|---|---|
| Token efficiency ratio | >60% | | | | |
| Refinement-to-rework ratio | <20% | | | | |
| Test-to-green ratio | <2:1 | | | | |
| Regression introduction rate | 0% | | | | |
| Ceremony automation conversion | >80% | | | | |
| Sessions per feature | ≤2 | | | | |
| Debugging % of cycle time | <10% | | | | |
| User engagement ratio | 20-40% | | | | |

## Definitions

| Metric | How to Measure |
|---|---|
| **Token efficiency ratio** | Estimate: what % of the session produced code, design, or test artifacts vs. debugging/ceremony/rework |
| **Refinement-to-rework ratio** | Items needing mid-build clarification / total items built |
| **Test-to-green ratio** | Average: (total test invocations to reach green) / (number of test files written) |
| **Regression introduction rate** | Full-suite breaks caused by new code / features added |
| **Ceremony automation conversion** | Ceremonies with automated alternatives / total ceremonies identified |
| **Sessions per feature** | Context windows consumed / features completed |
| **Debugging % of cycle time** | Estimated debugging effort / total effort |
| **User engagement ratio** | (User modifications + rejections + initiated changes) / total approval gates |

## Iteration Notes

_Add a section per iteration with context for anomalous values._
