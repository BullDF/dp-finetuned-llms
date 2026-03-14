# Memorization in DP Fine-Tuned LLMs

Empirical study of memorization in differentially privately fine-tuned LLMs (CSC2412, University of Toronto, Winter 2026).

**Current stage:** All 24 DP-SGD training runs complete. Canary exposure evaluation in progress.

## Progress

| Step | Status | Notes |
|---|---|---|
| Proposal | Done | |
| 1 — Data prep (`1_data.ipynb`) | Done | `solomonk/reddit_mental_health_posts`, 10k train / 1k val, MAX_LENGTH=128 |
| 2 — Baseline training (`2_train.ipynb`) | Done | ε = ∞, perplexity = **23.76**, log-perplexity = 3.168 |
| 3 — Canary insertion (`3_canaries.ipynb`) | Done | 4 datasets, one per frequency (1, 5, 10, 50×), seed=2412 |
| 4 — DP-SGD sweep (`4_dp_train.ipynb`) | Done | 24 runs complete; perplexity ε=0.5→34.1, ε=8→33.0, ε=∞→24.8 |
| 5 — Evaluation (`5_evaluate.ipynb`) | In progress | Canary exposure scoring + plots |

## Research Question

At what privacy budget ε does DP-SGD effectively prevent memorization of sensitive sequences in fine-tuned LLMs, and what is the accuracy cost?