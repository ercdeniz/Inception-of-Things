#!/bin/bash

# Stop script execution on error
set -e

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
NC="\033[0m"

echo -e "${GREEN}################################################################${NC}"
echo -e "${YELLOW}Starting Installation of Required Packages and Tools...${NC}"
echo -e "${GREEN}################################################################${NC}"

# 1. Update package list and install basic tools (curl, git, etc.)
echo -e "\n${GREEN}---> Step 1: Updating package list and installing basic tools...${NC}"

sudo apt-get update
sudo apt-get install -y curl wget git apt-transport-https

# 2. Docker Installation
echo -e "\n${GREEN}---> Step 2: Installing Docker...${NC}"
if ! command -v docker &> /dev/null
then
    echo -e "${YELLOW}Docker not found, installing...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    # Add user to docker group to use Docker without sudo
    sudo usermod -aG docker $USER
    echo -e "${GREEN}Docker successfully installed. You may need to open a new terminal session for changes to take effect.${NC}"
else
    echo -e "${CYAN}Docker is already installed.${NC}"
fi

# 3. kubectl Installation (Kubernetes CLI)
echo -e "\n${GREEN}---> Step 3: Installing kubectl...${NC}"
if ! command -v kubectl &> /dev/null
then
    echo "${YELLOW}kubectl not found, installing...${NC}"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    echo -e "${GREEN}kubectl successfully installed.${NC}"
else
    echo -e "${CYAN}kubectl is already installed.${NC}"
fi

# 4. k3d Installation
echo -e "\n${GREEN}---> Step 4: Installing k3d...${NC}"
if ! command -v k3d &> /dev/null
then
    echo -e "${YELLOW}k3d not found, installing...${NC}"
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    echo -e "${GREEN}k3d successfully installed.${NC}"
else
    echo -e "${CYAN}k3d is already installed.${NC}"
fi

echo -e "${GREEN}################################################################${NC}"
echo -e "${YELLOW}INSTALLATION COMPLETED!${NC}"
echo -e "${GREEN}################################################################${NC}"
echo -e "\n${YELLOW}Summary:${NC}"
echo "Docker version: $(docker --version)"
echo "kubectl version: $(kubectl version --client)"
echo "k3d version: $(k3d --version)"
echo -e "\n${RED}To use Docker commands without sudo, please close and reopen the terminal or run 'newgrp docker' command.${NC}"

