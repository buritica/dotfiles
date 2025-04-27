#!/usr/bin/env bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building test container...${NC}"
docker build -t dotfiles-test .

echo -e "${GREEN}Running tests in container...${NC}"
docker run --rm dotfiles-test

echo -e "${GREEN}Tests completed!${NC}" 