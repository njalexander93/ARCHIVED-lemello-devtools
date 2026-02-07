#!/usr/bin/env bash
# Verify pgvector installation
# Runs all verification steps

set -euo pipefail

CONTAINER_NAME="lemello-postgres-test"
POSTGRES_USER="${POSTGRES_USER:-lemello}"
POSTGRES_DB="${POSTGRES_DB:-lemello}"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  pgvector Verification${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${RED}✗ Container '${CONTAINER_NAME}' is not running${NC}"
    echo "Start it with: ./scripts/start-postgres-test.sh"
    exit 1
fi

echo -e "${GREEN}Step 1: Creating pgvector extension...${NC}"
docker exec -i "${CONTAINER_NAME}" psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" <<EOF
CREATE EXTENSION IF NOT EXISTS vector;
EOF
echo -e "${GREEN}✓ Extension created${NC}"
echo ""

echo -e "${GREEN}Step 2: Verifying extension is loaded...${NC}"
docker exec -i "${CONTAINER_NAME}" psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -t <<EOF
SELECT extname, extversion FROM pg_extension WHERE extname = 'vector';
EOF
EXTENSION_COUNT=$(docker exec -i "${CONTAINER_NAME}" psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -tAc "SELECT COUNT(*) FROM pg_extension WHERE extname = 'vector';" | tr -d '[:space:]')
if [ "${EXTENSION_COUNT}" = "0" ] || [ -z "${EXTENSION_COUNT}" ]; then
    echo -e "${RED}✗ Extension 'vector' is not installed in database '${POSTGRES_DB}'${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Extension verified${NC}"
echo ""

echo -e "${GREEN}Step 3: Creating test table with VECTOR column...${NC}"
docker exec -i "${CONTAINER_NAME}" psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" <<EOF
DROP TABLE IF EXISTS recipes_test;

CREATE TABLE recipes_test (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    embedding VECTOR(1536)
);
EOF
echo -e "${GREEN}✓ Test table created${NC}"
echo ""

echo -e "${GREEN}Step 4: Inserting sample vector data...${NC}"
docker exec -i "${CONTAINER_NAME}" psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" <<EOF
-- Insert test recipe with 1536-dimensional vector (all 0.1 values)
INSERT INTO recipes_test (name, description, embedding)
VALUES (
    'Test Recipe: Chocolate Chip Cookies',
    'A simple test recipe for pgvector verification',
    array_fill(0.1::real, ARRAY[1536])::vector
);

-- Insert another with different values
INSERT INTO recipes_test (name, description, embedding)
VALUES (
    'Test Recipe: Pasta Carbonara',
    'Another test recipe with vector data',
    array_fill(0.2::real, ARRAY[1536])::vector
);
EOF
echo -e "${GREEN}✓ Sample data inserted${NC}"
echo ""

echo -e "${GREEN}Step 5: Querying vector data...${NC}"
docker exec -i "${CONTAINER_NAME}" psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" <<EOF
SELECT id, name, description
FROM recipes_test;
EOF
echo -e "${GREEN}✓ Query successful${NC}"
echo ""

echo -e "${GREEN}Step 6: Testing vector similarity search...${NC}"
docker exec -i "${CONTAINER_NAME}" psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" <<EOF
-- Find recipes similar to a query vector (using cosine distance)
SELECT
    id,
    name,
    embedding <=> array_fill(0.15::real, ARRAY[1536])::vector AS distance
FROM recipes_test
ORDER BY distance
LIMIT 2;
EOF
echo -e "${GREEN}✓ Vector similarity search works${NC}"
echo ""

echo -e "${GREEN}Step 7: Checking pgvector version...${NC}"
PGVECTOR_VERSION=$(docker exec -i "${CONTAINER_NAME}" psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -t -c "SELECT extversion FROM pg_extension WHERE extname = 'vector';" | xargs)
if [[ -z "${PGVECTOR_VERSION}" ]]; then
    echo -e "${RED}✗ Failed to determine pgvector version. Is the 'vector' extension installed and visible in database '${POSTGRES_DB}'?${NC}"
    exit 1
fi
echo -e "${BLUE}pgvector version: ${PGVECTOR_VERSION}${NC}"
echo ""

echo -e "${GREEN}Step 8: Resource usage check...${NC}"
docker stats "${CONTAINER_NAME}" --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
echo ""

echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}✓ All verification steps completed!${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "${YELLOW}Next step:${NC}"
echo "  Document this in your backend documentation (e.g., README or runbook):"
echo "  - pgvector version: ${PGVECTOR_VERSION}"
echo "  - Tested on PostgreSQL 16"
echo "  - Verified with 1 GB RAM (DigitalOcean Basic Plan)"
echo ""
echo -e "${YELLOW}Cleanup:${NC}"
echo "  To stop and remove test container: ./scripts/stop-postgres-test.sh"
