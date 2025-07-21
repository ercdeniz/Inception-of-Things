#!/bin/bash
set -e

GREEN="\033[0;32m"
RESET="\033[0m"

printf "${GREEN}>>> Installing K3D, kubectl, and ArgoCD...${RESET}\n"
# Assuming dependencies are already installed in defense environment.

printf "${GREEN}>>> Creating K3D cluster...${RESET}\n"
k3d cluster create iot-cluster

printf "${GREEN}>>> Creating namespaces...${RESET}\n"
kubectl create namespace argocd || true
kubectl create namespace dev || true

printf "${GREEN}>>> Installing ArgoCD...${RESET}\n"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

printf "${GREEN}>>> Waiting for ArgoCD to become ready...${RESET}\\n"
until kubectl get pods -n argocd | grep argocd-server | grep Running; do
  printf "."; sleep 2
done
printf "\\n${GREEN}>>> ArgoCD is ready.${RESET}\\n"

bash scripts/start-argocd.sh

printf "${GREEN}>>> Setup complete.${RESET}\n"
