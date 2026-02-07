#!/usr/bin/env bash
# Start PostgreSQL 16 with pgvector for verification
# Resource limits match DigitalOcean Basic Plan ($15/month tier)

set -euo pipefail

CONTAINER_NAME="lemello-postgres-test"
POSTGRES_USER="${POSTGRES_USER:-lemello}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-}"
POSTGRES_DB="${POSTGRES_DB:-lemello}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"
POSTGRES_BIND_HOST="${POSTGRES_BIND_HOST:-127.0.0.1}"
SHOW_PASSWORD="${SHOW_PASSWORD:-0}"
GENERATED_PASSWORD=0

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  PostgreSQL 16 + pgvector Test Setup${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

if [ -z "${POSTGRES_PASSWORD}" ]; then
    if command -v python3 >/dev/null 2>&1; then
        POSTGRES_PASSWORD="$(python3 - <<'PY'
import secrets
print(secrets.token_hex(12))
PY
)"
        GENERATED_PASSWORD=1
    elif command -v openssl >/dev/null 2>&1; then
        POSTGRES_PASSWORD="$(openssl rand -hex 12)"
        GENERATED_PASSWORD=1
    else
        echo -e "${YELLOW}No password generator found and POSTGRES_PASSWORD is not set.${NC}"
        echo -e "${YELLOW}Please set POSTGRES_PASSWORD in the environment and re-run this script.${NC}"
        exit 1
    fi
fi

# Check if container already exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${YELLOW}Container '${CONTAINER_NAME}' already exists.${NC}"
    echo -e "${YELLOW}Removing existing container...${NC}"
    docker rm -f "${CONTAINER_NAME}" > /dev/null 2>&1
fi

echo -e "${GREEN}Starting PostgreSQL container with resource limits:${NC}"
echo "  • RAM: 1 GB (matches DO Basic Plan)"
echo "  • CPU: 1 core (matches DO Basic Plan)"
echo "  • Storage: container filesystem (ephemeral)"
echo "  • Max Connections: 22 (matches DO Basic Plan)"
echo "  • Image: pgvector/pgvector:pg16"
echo "  • Host Bind: ${POSTGRES_BIND_HOST}:${POSTGRES_PORT}"
if [ "${GENERATED_PASSWORD}" -eq 1 ]; then
    echo "  • Password: generated (set POSTGRES_PASSWORD to override)"
fi
echo ""

docker run --name "${CONTAINER_NAME}" \
  -e POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
  -e POSTGRES_USER="${POSTGRES_USER}" \
  -e POSTGRES_DB="${POSTGRES_DB}" \
  -p "${POSTGRES_BIND_HOST}:${POSTGRES_PORT}:5432" \
  --memory="1g" \
  --cpus="1.0" \
  --shm-size=256m \
  -d \
  pgvector/pgvector:pg16 postgres -c max_connections=22

echo ""
echo -e "${GREEN}Waiting for PostgreSQL to be ready...${NC}"

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${YELLOW}✗ Container failed to start${NC}"
    echo "Check logs with: docker logs ${CONTAINER_NAME}"
    exit 1
fi

READY=0
for i in $(seq 1 30); do
    if docker exec "${CONTAINER_NAME}" pg_isready -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" > /dev/null 2>&1; then
        READY=1
        break
    fi
    sleep 1
done

if [ "${READY}" -ne 1 ]; then
    echo -e "${YELLOW}✗ PostgreSQL did not become ready in time${NC}"
    echo "Check logs with: docker logs ${CONTAINER_NAME}"
    exit 1
fi

echo -e "${GREEN}✓ Container started successfully${NC}"
echo ""
echo -e "${BLUE}Connection details:${NC}"
echo "  Host: ${POSTGRES_BIND_HOST}"
echo "  Port: ${POSTGRES_PORT}"
echo "  Database: ${POSTGRES_DB}"
echo "  User: ${POSTGRES_USER}"
if [ "${SHOW_PASSWORD}" = "1" ]; then
    echo "  Password: ${POSTGRES_PASSWORD}"
else
    echo "  Password: <redacted> (set SHOW_PASSWORD=1 to print)"
fi
echo ""
echo -e "${BLUE}Connection string:${NC}"
if [ "${SHOW_PASSWORD}" = "1" ]; then
    echo "  postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost:${POSTGRES_PORT}/${POSTGRES_DB}"
else
    echo "  postgresql://${POSTGRES_USER}:<redacted>@localhost:${POSTGRES_PORT}/${POSTGRES_DB}"
fi
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "  1. Run verification script: ./scripts/verify-pgvector.sh"
echo "  2. Or connect manually: docker exec -it ${CONTAINER_NAME} psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}"
