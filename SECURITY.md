# Security Policy

This is a private internal repository.

## Reporting

If you discover a vulnerability or suspect a secret was committed:

1. Notify the Lemello maintainers via your internal channel (Linear issue or direct message).
2. Do not open public issues or share details externally.
3. Rotate any exposed credentials immediately.

## Handling Secrets

- Never commit `.env` files or credentials.
- If a secret is committed, revoke it immediately and scrub it from git history if needed.
