#!/bin/bash
set -e

shopt -s dotglob

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}>>> Scanning for *.pid files (including hidden)...${NC}"

# Check if any .pid files exist
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

# If no .pid files were found
if [ "$FOUND_PID" = false ]; then
    echo -e "${YELLOW}No .pid files found in directory.${NC}"
else
    echo -e "${GREEN}>>> All PID-based port-forwards stopped.${NC}"
fi
