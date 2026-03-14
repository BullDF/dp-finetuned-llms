# Memorization in DP Fine-Tuned LLMs

Empirical study of memorization in differentially privately fine-tuned LLMs (CSC2412, University of Toronto, Winter 2026).

**Current stage:** All experiments complete. Writing up.

## Progress

| Step | Status | Notes |
|---|---|---|
| Proposal | Done | |
| 1 — Data prep (`1_data.ipynb`) | Done | `solomonk/reddit_mental_health_posts`, 10k train / 1k val, MAX_LENGTH=128 |
| 2 — Baseline training (`2_train.ipynb`) | Done | ε = ∞, no canaries; perplexity = **23.76** |
| 3 — Canary insertion (`3_canaries.ipynb`) | Done | 4 datasets, one per frequency (1, 5, 10, 50×), seed=2412 |
| 4 — DP-SGD sweep (`4_dp_train.ipynb`) | Done | 24 runs; perplexity ε=0.5→34.1, ε=8→33.0, ε=∞→24.8 |
| 5 — Evaluation (`5_evaluate.ipynb`) | Done | Canary exposure scoring + plots |
| 6 — Ablation (`6_ablation.ipynb`) | Done | Base-rate check for freq=10 anomaly |

## Key Results

Exposure metric: log₂(900 000) − log₂(rank). Random = 0, perfect memorization ≈ 19.8 bits.

| ε | freq=1 | freq=5 | freq=10 | freq=50 |
|---|--------|--------|---------|---------|
| 0.5–8 (DP) | ~0.5 | ~0.75 | ~4.2 | ~0.67 |
| ∞ (no DP) | 4.30 | 7.73 | 19.78 | 19.78 |

- DP effectively suppresses memorization at all ε values tested.
- The freq=10 result (~4.2 bits under DP) is a **base-rate artifact**: secret `116632` already ranks 32k/900k on the domain-tuned model *without* any canary exposure (4.78 bits). DP models score below this baseline — no memorization.
- Perplexity cost of DP: ~33–34 vs 23.76 baseline (~40% degradation).

## Research Question

At what privacy budget ε does DP-SGD effectively prevent memorization of sensitive sequences in fine-tuned LLMs, and what is the accuracy cost?