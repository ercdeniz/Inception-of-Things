#!/bin/bash
set -e

GREEN="\033[0;32m"
NC="\033[0m"

# Check if the ArgoCD namespace exists
printf "${GREEN}>>> Retrieving ArgoCD admin password...${NC}\n"

if ! kubectl get secret -n argocd argocd-initial-admin-secret &>/dev/null; then
  echo -e "\033[0;31m[!] ArgoCD admin secret not found.\033[0m"
  exit 1
fi

# Get the password from the secret
PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Save the credentials to a file
echo "ArgoCD Login Information" > "Argo Authentication Info.auth"
echo "USERNAME: admin" >> "Argo Authentication Info.auth"
echo "PASSWORD: $PASSWORD" >> "Argo Authentication Info.auth"
