#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m'

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
lsof -i -P -n | grep LISTEN | grep kubectl
echo -e "\n-----------------------------\n"
