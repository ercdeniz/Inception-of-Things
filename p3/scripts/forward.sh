#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NO='\033[0m'

APP_NAME="wil-playground"
NAMESPACE="dev"
LOCAL_PORT=8888
REMOTE_PORT=80
PID_FILE=".app_port_forward.pid"

echo -e "${YELLOW}>>> Killing previous port-forward (if exists)...${NO}"
if [ -f "$PID_FILE" ]; then
    kill $(cat $PID_FILE) 2>/dev/null || true
    rm -f "$PID_FILE"
fi

echo -e "${GREEN}>>> Starting port-forward for '${APP_NAME}' on http://localhost:${LOCAL_PORT}${NO}"
kubectl port-forward svc/${APP_NAME} -n ${NAMESPACE} ${LOCAL_PORT}:${REMOTE_PORT} &>/dev/null &

echo $! > "$PID_FILE"
