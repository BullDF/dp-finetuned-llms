# Memorization in DP Fine-Tuned LLMs

Empirical study of memorization in differentially privately fine-tuned LLMs (CSC2412, University of Toronto, Winter 2026).

**Current stage:** Baseline training complete. Canary insertion and DP-SGD runs in progress.

## Progress

| Step | Status | Notes |
|---|---|---|
| Proposal | Done | |
| 1 — Data prep (`1_data.ipynb`) | Done | `solomonk/reddit_mental_health_posts`, 10k train / 1k val, MAX_LENGTH=128 |
| 2 — Baseline training (`2_train.ipynb`) | Done | ε = ∞, perplexity = **23.76**, log-perplexity = 3.168 |
| 3 — Canary insertion | Not started | |
| 4 — DP-SGD sweep | Not started | ε ∈ {0.5, 1, 2, 4, 8, ∞}, canary freq ∈ {1, 5, 10, 50} |
| 5 — Analysis & report | Not started | |

## Research Question

At what privacy budget ε does DP-SGD effectively prevent memorization of sensitive sequences in fine-tuned LLMs, and what is the accuracy cost?