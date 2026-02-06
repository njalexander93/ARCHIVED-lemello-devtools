# Compose Stacks

## local-stack.yml

Full local stack: PostgreSQL (pgvector), Redis, backend, and frontend.

From the `devtools/` repo root:

```bash
cp .env.template .env
docker compose -f compose/local-stack.yml up --build
```

Notes:
- Default `BACKEND_CONTEXT` and `WEBAPP_CONTEXT` assume sibling repos (`../backend`, `../webapp`). Update `.env` if your paths differ.
- Set `DATABASE_URL` and `REDIS_URL` in `.env` to match your local credentials.

## Conventions

- `postgres.yml`: Postgres-only stack for local testing.
- `redis.yml`: Redis-only stack.

Update this file with each new compose stack, including usage examples.
