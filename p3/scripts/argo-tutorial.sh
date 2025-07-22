#!/bin/bash

BLUE='\033[1;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${BLUE}Go to ARGO${NC}\n"

echo "   URL: https://localhost:8080"

echo -e "${GREEN}2. Giriş yap:${NC}"
echo "   USER: admin"
echo "   PASS: (look at the file 'Argo Authentication Info.auth')"

echo -e "${GREEN}3. + NEW APP → formu şu şekilde doldur:${NC}"

echo -e "   NAME      : test-app (example)"
echo -e "   PROJECT   : default"

echo -e "   REPO URL  : https://github.com/TufanKurukaya/tkurukay"
echo -e "   REVISION  : HEAD"
echo -e "   PATH      : ."

echo -e "   CLUSTER   : https://kubernetes.default.svc"
echo -e "   NAMESPACE : dev"

echo -e "${GREEN}4. CREATE → ardından SYNC → APPLY yap${NC}"
echo -e "${GREEN}5. Uygulama pod’unu kontrol et:${NC}"
echo "   kubectl get pods -n dev"

echo -e "${GREEN}6. Servis varsa port yönlendir:${NC}"
echo "   kubectl port-forward svc/test-app -n dev 9999:80"
echo "   http://localhost:9999"

echo -e "\n${GREEN}✅ Uygulama başarıyla deploy edildi!${NC}"
