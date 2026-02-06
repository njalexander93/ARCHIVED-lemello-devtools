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

## Guidelines

- Keep scripts small and focused.
- Prefer bash for portability unless there is a clear need for another language.
- Document usage in this file when you add a new script.
