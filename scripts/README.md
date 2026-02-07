# Scripts

## PostgreSQL (pgvector) Test Helpers

- `start-postgres-test.sh`: Starts a local PostgreSQL 16 + pgvector container for verification.
- `verify-pgvector.sh`: Runs pgvector checks against the test container.
- `stop-postgres-test.sh`: Stops and removes the test container.

Example:

```bash
./scripts/start-postgres-test.sh
./scripts/verify-pgvector.sh
./scripts/stop-postgres-test.sh
```

Optional environment variables:

- `POSTGRES_PASSWORD`: Set a custom password (otherwise a random one is generated).
- `POSTGRES_PORT`: Set a custom host port (default `5432`).
- `SHOW_PASSWORD=1`: Print the password in the output.

## Guidelines

- Keep scripts small and focused.
- Prefer bash for portability unless there is a clear need for another language.
- Document usage in this file when you add a new script.
