#!/bin/bash
set -e

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

if [ ! -x "$(command -v k3d)" ] || [ ! -x "$(command -v docker)" ] || [ ! -x "$(command -v kubectl)" ]; then
  read -p "$(echo -e "${YELLOW}>>> Should the required programs be installed (y/n): ${NC}")" answer
  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    bash scripts/install.sh
  else
    echo -e "${RED}>>> Installation cancelled. Please install the required programs.${NC}"
    exit 1
  fi
fi

# Check if the first argument is provided
if [ -z "$1" ]; then
    echo -e "${RED}ERROR: Cluster name must be provided as the first argument.${NC}"
    echo -e "${YELLOW}Usage: bash scripts/setup.sh <cluster-name> [argo-port] [argo-namespace]${NC}"
    exit 1
fi

# Get the cluster name and optional parameters
CLUSTER_NAME="$1"
ARGOCD_PORT="${2:-8080}"

echo -e "${GREEN}>>> Starting setup for cluster: ${CLUSTER_NAME}${NC}"

# Check if the cluster already exists
if k3d cluster list | grep -q "${CLUSTER_NAME}"; then
    echo -e "${YELLOW}>>> Cluster '${CLUSTER_NAME}' already exists.${NC}"
    read -p "$(echo -e "${YELLOW}>>> Do you want to delete and recreate it? (y/n): ${NC}")" answer
    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
        bash scripts/clean.sh "${CLUSTER_NAME}"
    else
        echo -e "${YELLOW}>>> Setup aborted.${NC}"
        exit 0
    fi
fi

# Create a new K3D cluster
echo -e "${GREEN}>>> Creating cluster '${CLUSTER_NAME}'...${NC}"
k3d cluster create "${CLUSTER_NAME}" --port "8888:30080"

# Create namespaces
echo -e "${GREEN}>>> Creating namespaces...${NC}"
kubectl create namespace "argocd" || true
kubectl create namespace dev || true

# Install ArgoCD
echo -e "${GREEN}>>> Installing ArgoCD...${NC}"
kubectl apply -n "argocd" -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo -e "${GREEN}>>> Waiting for ArgoCD to be ready...${NC}"

spinner="/|\\-"
while ! kubectl get pods -n "argocd" | grep argocd-server | grep Running &>/dev/null; do
  for i in $(seq 0 3); do
    printf "\r${spinner:$i:1}"
    sleep 0.2
  done
done

printf "\n${GREEN}>>> ArgoCD is ready.${NC}\n"

# Start port-forwarding for ArgoCD
bash scripts/start-argocd.sh "${ARGOCD_PORT}" "argocd"

# Create ArgoCD application
kubectl apply -f ./confs/app.yaml -n argocd


# Wait for ArgoCD application to become Synced and Healthy
echo -e "${GREEN}>>> Waiting for ArgoCD application to become Synced and Healthy...${NC}"

ARGO_APP_NAME="test-app"
TIMEOUT=300
INTERVAL=10
ELAPSED=0

while true; do
  SYNC_STATUS=$(kubectl get application ${ARGO_APP_NAME} -n argocd -o jsonpath='{.status.sync.status}' 2>/dev/null || echo "NotFound")
  HEALTH_STATUS=$(kubectl get application ${ARGO_APP_NAME} -n argocd -o jsonpath='{.status.health.status}' 2>/dev/null || echo "NotFound")

  if [[ "${SYNC_STATUS}" == "Synced" && "${HEALTH_STATUS}" == "Healthy" ]]; then
    echo -e "${GREEN}>>> ArgoCD application is Synced and Healthy.${NC}"
    break
  fi

  if [[ ${ELAPSED} -ge ${TIMEOUT} ]]; then
    echo -e "${RED}>>> Timeout: ArgoCD application did not reach Synced & Healthy state in 5 minutes.${NC}"
    echo -e "${YELLOW}>>> Last known status: Sync=${SYNC_STATUS}, Health=${HEALTH_STATUS}${NC}"
    exit 1
  fi

  echo -e "${YELLOW}>>> Waiting... (Current Status: Sync=${SYNC_STATUS}, Health=${HEALTH_STATUS})${NC}"
  sleep ${INTERVAL}
  ELAPSED=$((ELAPSED + INTERVAL))
done

# Display guidance for accessing ArgoCD
bash scripts/argo-guide.sh

echo -e "${GREEN}>>> Setup complete for '${CLUSTER_NAME}'${NC}"
