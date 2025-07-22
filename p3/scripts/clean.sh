#!/bin/bash
set -e

RED="\033[0;31m"
RESET="\033[0m"

printf "${RED}>>> Deleting ArgoCD port-forward if exists...${RESET}\n"

rm -rf "Argo Authentication Info.auth"

if [ -f .argocd_port_forward.pid ]; then
  kill $(cat .argocd_port_forward.pid) 2>/dev/null || true
  rm -rf .argocd_port_forward.pid
fi

echo -e "${RED}>>> Stopping app port-forward if exists...${RESET}"
if [ -f .app_port_forward.pid ]; then
    kill $(cat .app_port_forward.pid) 2>/dev/null || true
    rm -f .app_port_forward.pid
fi

printf "${RED}>>> Deleting K3D cluster...${RESET}\n"

k3d cluster delete iot-cluster
