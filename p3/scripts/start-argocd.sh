#!/bin/bash
set -e

# Check if the first argument is provided
if [ -z "$1" ]; then
  echo -e "\033[0;31m[ERROR] Port is required as the first argument.\033[0m"
  echo -e "\033[1;33mUsage: bash scripts/start-forward.sh <port> <namespace>\033[0m"
  exit 1
fi

# Get the port from the first argument
PORT="$1"

# Check if the second argument is provided, otherwise use default namespace
NAMESPACE="$2"
if [ -z "$NAMESPACE" ]; then
  NAMESPACE="argocd"
fi

GREEN="\033[0;32m"
NC="\033[0m"

# Stopping previous port-forwarding if exists
printf "${GREEN}>>> Stopping previous port-forwarding...${NC}\n"
kill $(ps aux | grep "[k]ubectl port-forward" | awk '{print $2}') 2>/dev/null || true

# Starting port-forwarding for ArgoCD
printf "${GREEN}>>> Starting port-forward for ArgoCD on port ${PORT}...${NC}\n"
kubectl port-forward svc/argocd-server -n $NAMESPACE $PORT:443 &>/dev/null &

# Save the PID of the port-forward process
echo $! > .argocd_port_forward.pid

printf "${GREEN}>>> ArgoCD is accessible at https://localhost:${PORT}${NC}\n"

# Get ArgoCD password
bash scripts/get-password.sh
