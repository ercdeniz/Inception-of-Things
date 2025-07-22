#!/bin/bash
set -e

RED="\033[0;31m"
RESET="\033[0m"

# Check if the first argument is provided
if [ -z "$1" ]; then
  echo -e "\033[0;31m[ERROR] Cluster name is required as the first argument.\033[0m"
  echo -e "\033[1;33mUsage: bash scripts/clean.sh <cluster-name>\033[0m"
  exit 1
fi

# Get the cluster name from the first argument
CLUSTER_NAME="$1"

# Stop all port-forward processes
printf "${RED}>>> Stopping all port-forwards...${RESET}\n"
bash scripts/stop-forward.sh

# Delete the ArgoCD authentication info file
printf "${RED}>>> Deleting Argo Authentication Info...${RESET}\n"
rm -f "*.auth"

# Delete the K3D cluster
printf "${RED}>>> Deleting K3D cluster '${CLUSTER_NAME}'...${RESET}\n"
k3d cluster delete "${CLUSTER_NAME}"
