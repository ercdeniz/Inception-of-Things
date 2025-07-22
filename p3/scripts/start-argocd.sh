#!/bin/bash
set -e

GREEN="\033[0;32m"
RESET="\033[0m"

printf "${GREEN}>>> Starting port-forward for ArgoCD on 8080...${RESET}\n"

kill $(ps aux | grep '[k]ubectl port-forward svc/argocd-server' | awk '{print $2}') 2>/dev/null || true

kubectl port-forward svc/argocd-server -n argocd 8080:443 &>/dev/null &

echo $! > .argocd_port_forward.pid

printf "${GREEN}>>> ArgoCD is accessible at https://localhost:8080${RESET}\n"

bash scripts/get-password.sh
