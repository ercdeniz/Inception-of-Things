#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Mevcut cluster sayısını kontrol et
CLUSTER_COUNT=$(k3d cluster list | tail -n +2 | wc -l)

if [ "$CLUSTER_COUNT" -eq 0 ]; then
  echo -e "${RED}[!] No K3D clusters found.${NC}"
  exit 0
fi

echo -e "${GREEN}[+] Cluster List:${NC}"
k3d cluster list
echo -e "\n-----------------------------\n"

echo -e "${GREEN}[+] Nodes:${NC}"
kubectl get nodes
echo -e "\n-----------------------------\n"

echo -e "${GREEN}[+] Argo CD Pods:${NC}"
kubectl get pods -n argocd
echo -e "\n-----------------------------\n"

echo -e "${GREEN}[+] App Pods:${NC}"
kubectl get pods -n dev
echo -e "\n-----------------------------\n"

echo -e "${GREEN}[+] ArgoCD Applications:${NC}"
kubectl get applications -n argocd
echo -e "\n-----------------------------\n"

echo -e "${GREEN}[+] Kubectl Listening Ports:${NC}"
lsof -i -P -n | grep LISTEN | grep kubectl || echo "No active kubectl port-forwards found."
echo -e "\n-----------------------------\n"
