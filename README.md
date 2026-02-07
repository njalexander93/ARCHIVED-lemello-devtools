<h1><img src=".github/assets/lemello-horizontal-yellow.svg" alt="Lemello" height="28px"> Devtools</h1>

Local development tooling for Lemello. This repo centralizes Docker Compose stacks and helper scripts used across backend, webapp, and infra for development purposes.

## Repo Layout

- `compose/`: Docker Compose definitions for local stacks.
- `scripts/`: Helper scripts for local development and verification.

## Related Repositories

- `lemello-app/backend`: FastAPI backend and AI services
- `lemello-app/webapp`: Next.js Progressive Web App
- `lemello-app/infra`: Infrastructure as Code (Terraform, DigitalOcean)

## Getting Started

1. Install Docker and Docker Compose v2.
2. Copy `.env.template` to `.env` and adjust values if needed.
3. See `compose/README.md` for available stacks and how to run them.

## Pre-commit

This repo uses pre-commit hooks for basic hygiene checks.

- Install: `python -m pip install pre-commit`
- Setup: `pre-commit install`

## Contributing

See `CONTRIBUTING.md`.

## Security

See `SECURITY.md`.
