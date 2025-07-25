#!/bin/bash

BLUE='\033[1;34m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Go to ARGO${NC}"

echo -e "   URL: ${BLUE}https://localhost:8080${NC}"

echo -e "${GREEN}Login:${NC}"
USER=$(grep -i '^username:' "Argo Authentication Info.auth" | awk '{print $2}')
PASS=$(grep -i '^password:' "Argo Authentication Info.auth" | awk '{print $2}')
echo -e "   USER: ${PURPLE}$USER${NC}"
echo -e "   PASS: ${PURPLE}$PASS${NC}"
