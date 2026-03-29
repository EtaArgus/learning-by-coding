# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About This Repository

Personal learning repo exploring ML/DL algorithms through implementation. No formal project structure — notebooks are added incrementally as topics of interest arise. See README.md for the author's intent.

## Environment

- **Primary language**: Python (Jupyter Notebooks), with some R scripts
- **Python environment**: `.venv/` (gitignored) — activate with `source .venv/Scripts/activate` on Windows/bash
- **No build system or test suite** — this is an exploratory/educational repo

## Working with Notebooks

Launch Jupyter:
```bash
jupyter notebook
# or
jupyter lab
```

Run a notebook non-interactively:
```bash
jupyter nbconvert --to notebook --execute <notebook.ipynb>
```

Clear notebook outputs before committing:
```bash
jupyter nbconvert --clear-output --inplace <notebook.ipynb>
```

## Repository Structure

Each top-level folder is a self-contained topic area:

| Folder | Topic | Key libraries |
|--------|-------|---------------|
| `autoencoders/` | Variational Autoencoder on MNIST | PyTorch |
| `deep-learning/pytorch/` | PyTorch fundamentals tutorial | PyTorch |
| `genetic-algorithms/` | GA basic implementation | — |
| `graph-neural-networks/` | GNN concepts + production examples | PyTorch Geometric / DGL |
| `recommendation-systems/` | Collaborative filtering, ALS | — |
| `statistical-analysis/` | Regression-perspective stats (book exercises) | R |
| `time-series-analysis/` | N-HiTS forecasting | NeuralForecast |

## Data Files

Data directories are gitignored. Expected locations per folder:
- `autoencoders/data/`
- `recommendation-systems/data/`
- `deep-learning/pytorch/data/`
