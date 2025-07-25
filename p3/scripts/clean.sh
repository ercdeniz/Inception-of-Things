#!/bin/bash
set -e

RED="\033[0;31m"
NC="\033[0m"

# Check if the first argument is provided
if [ -z "$1" ]; then
  echo -e "\033[0;31m[ERROR] Cluster name is required as the first argument.\033[0m"
  echo -e "\033[1;33mUsage: bash scripts/clean.sh <cluster-name>\033[0m"
  exit 1
fi

# Get the cluster name from the first argument
CLUSTER_NAME="$1"

# Delete the ArgoCD authentication info file
printf "${RED}>>> Deleting Argo Authentication Info...${NC}\n"
rm -f *.auth

# Check if any .pid files exist
shopt -s dotglob

FOUND_PID=false

for pidfile in *.pid; do
    if [ -f "$pidfile" ]; then
        PID=$(cat "$pidfile" 2>/dev/null)
        if [ -n "$PID" ] && ps -p "$PID" > /dev/null 2>&1; then
            echo -e "${YELLOW}>>> Killing process $PID from $pidfile...${NC}"
            kill "$PID" && echo -e "${GREEN}✔ Killed process $PID${NC}"
        else
            echo -e "${RED}✘ Process $PID not found or already terminated.${NC}"
        fi

        rm -f "$pidfile" && echo -e "${GREEN}✔ Removed $pidfile${NC}"
        FOUND_PID=true
    fi
done

if [ "$FOUND_PID" = false ]; then
    echo -e "${YELLOW}No .pid files found in directory.${NC}"
else
    echo -e "${GREEN}>>> All PID-based port-forwards stopped.${NC}"
fi

# Delete the K3D cluster
printf "${RED}>>> Deleting K3D cluster '${CLUSTER_NAME}'...${NC}\n"
k3d cluster delete "${CLUSTER_NAME}"
