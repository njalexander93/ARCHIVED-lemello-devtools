#!/usr/bin/env bash
# Stop and remove PostgreSQL test container

set -euo pipefail

CONTAINER_NAME="lemello-postgres-test"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Stopping and removing container: ${CONTAINER_NAME}${NC}"

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    docker rm -f "${CONTAINER_NAME}" > /dev/null 2>&1
    echo -e "${GREEN}✓ Container removed${NC}"
else
    echo -e "${YELLOW}Container '${CONTAINER_NAME}' does not exist${NC}"
fi

# No named volume is created by default.
# To remove data from a custom named volume, run:
# docker volume rm <your_volume_name> 2>/dev/null || true
# echo -e "${GREEN}✓ Volume removed (if it existed)${NC}"
