#!/usr/bin/env bash
# Start PostgreSQL 16 with pgvector for LMLO-9 verification
# Resource limits match DigitalOcean Basic Plan ($15/month tier)

set -euo pipefail

CONTAINER_NAME="lemello-postgres-test"
POSTGRES_USER="lemello"
POSTGRES_PASSWORD="test123"
POSTGRES_DB="lemello"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  LMLO-9: PostgreSQL 16 + pgvector Test Setup${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if container already exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${YELLOW}Container '${CONTAINER_NAME}' already exists.${NC}"
    echo -e "${YELLOW}Removing existing container...${NC}"
    docker rm -f "${CONTAINER_NAME}" > /dev/null 2>&1
fi

echo -e "${GREEN}Starting PostgreSQL container with resource limits:${NC}"
echo "  • RAM: 1 GB (matches DO Basic Plan)"
echo "  • CPU: 1 core (matches DO Basic Plan)"
echo "  • Storage: 10 GB (Docker volume, no hard limit)"
echo "  • Max Connections: 22 (matches DO Basic Plan)"
echo "  • Image: pgvector/pgvector:pg16"
echo ""

docker run --name "${CONTAINER_NAME}" \
  -e POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
  -e POSTGRES_USER="${POSTGRES_USER}" \
  -e POSTGRES_DB="${POSTGRES_DB}" \
  -e POSTGRES_INITDB_ARGS="-c max_connections=22" \
  -p 5432:5432 \
  --memory="1g" \
  --cpus="1.0" \
  --shm-size=256m \
  -d \
  pgvector/pgvector:pg16

echo ""
echo -e "${GREEN}Waiting for PostgreSQL to be ready...${NC}"
sleep 3

# Check if container is running
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${GREEN}✓ Container started successfully${NC}"
    echo ""
    echo -e "${BLUE}Connection details:${NC}"
    echo "  Host: localhost"
    echo "  Port: 5432"
    echo "  Database: ${POSTGRES_DB}"
    echo "  User: ${POSTGRES_USER}"
    echo "  Password: ${POSTGRES_PASSWORD}"
    echo ""
    echo -e "${BLUE}Connection string:${NC}"
    echo "  postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost:5432/${POSTGRES_DB}"
    echo ""
    echo -e "${GREEN}Next steps:${NC}"
    echo "  1. Run verification script: ./scripts/verify-pgvector.sh"
    echo "  2. Or connect manually: docker exec -it ${CONTAINER_NAME} psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}"
else
    echo -e "${YELLOW}✗ Container failed to start${NC}"
    echo "Check logs with: docker logs ${CONTAINER_NAME}"
    exit 1
fi
