# Contributing

Thanks for helping improve Lemello devtools. Keep changes focused and easy to reuse across repos.

## Workflow

- Create a feature branch from `main`.
- Open a PR for review.
- Keep PRs small and scoped.

## Repository Conventions

- Docker Compose files live in `compose/`.
- Helper scripts live in `scripts/`.
- Update the relevant README when you add or change a tool.
- Do not commit secrets. Use `.env` locally and keep templates in `.env.template`.

## Pre-commit

Install and run pre-commit before submitting:

```bash
python -m pip install pre-commit
pre-commit install
pre-commit run -a
```
