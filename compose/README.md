# Compose Stacks

## local-stack.yml

Full local stack: PostgreSQL (pgvector), Redis, backend, and frontend.

From the `devtools/` repo root:

```bash
cp .env.template .env
docker compose -f compose/local-stack.yml up --build
```

Notes:
- Default `BACKEND_CONTEXT` and `WEBAPP_CONTEXT` assume sibling repos. These paths are resolved relative to `compose/local-stack.yml`, so the defaults are `../../backend` and `../../webapp`. Update `.env` if your paths differ.
- Set `DATABASE_URL` and `REDIS_URL` in `.env` to match your local credentials.

## Conventions

For each compose stack file you add, document it here with:
- The filename (e.g. `local-stack.yml`)
- A short description of what it runs
- Example commands for how to start it (e.g. `docker compose -f compose/<file>.yml up`)

Update this file with each new compose stack, including usage examples.
