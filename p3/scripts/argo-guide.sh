#!/bin/bash

BLUE='\033[1;34m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Go to ARGO${NC}"

echo -e "   URL: ${BLUE}https://localhost:8080${NC}"

echo -e "${GREEN}2. Giriş yap:${NC}"
USER=$(grep -i '^username:' "Argo Authentication Info.auth" | awk '{print $2}')
PASS=$(grep -i '^password:' "Argo Authentication Info.auth" | awk '{print $2}')
echo -e "   USER: ${PURPLE}$USER${NC}"
echo -e "   PASS: ${PURPLE}$PASS${NC}"

echo -e "${GREEN}3. + NEW APP → formu şu şekilde doldur:${NC}"

echo -e "   NAME        : test-app (example)"
echo -e "   PROJECT     : default"
echo -e "   Sync Policy : Automatic"

echo -e "   REPO URL    : ${BLUE}https://github.com/TufanKurukaya/tkurukay${NC}"
echo -e "   REVISION    : HEAD"
echo -e "   PATH        : /conf"

echo -e "   CLUSTER     : https://kubernetes.default.svc"
echo -e "   NAMESPACE   : dev"

echo -e "${GREEN}4. CREATE → ardından SYNC → APPLY yap${NC}"
echo -e "${GREEN}5. Uygulama pod’unu kontrol et:${NC}"
echo "   kubectl get pods -n dev"

echo -e "${GREEN}6. Port yönlendir => scripts/forward.sh${NC}"
