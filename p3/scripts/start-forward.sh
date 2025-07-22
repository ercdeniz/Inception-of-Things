#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NO='\033[0m'

# Check if the correct number of arguments is provided
if [ $# -ne 4 ]; then
    echo -e "${RED}[ERROR] Usage: bash $0 <app-name> <namespace> <local-port> <remote-port>${NO}"
    exit 1
fi

APP_NAME="$1"
NAMESPACE="$2"
LOCAL_PORT="$3"
REMOTE_PORT="$4"

PID_FILE=".${APP_NAME}_port_forward.pid"

echo -e "${YELLOW}>>> Killing previous port-forward for ${APP_NAME} (if exists)...${NO}"
if [ -f "$PID_FILE" ]; then
    kill $(cat "$PID_FILE") 2>/dev/null || true
    rm -f "$PID_FILE"
fi

echo -e "${GREEN}>>> Starting port-forward for '${APP_NAME}' on http://localhost:${LOCAL_PORT}${NO}"
kubectl port-forward svc/${APP_NAME} -n ${NAMESPACE} ${LOCAL_PORT}:${REMOTE_PORT} &>/dev/null &

echo $! > "$PID_FILE"
