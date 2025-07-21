#!/bin/bash
set -e

GREEN="\033[0;32m"
RESET="\033[0m"

printf "${GREEN}>>> Retrieving ArgoCD admin password...${RESET}\n"

if ! kubectl get secret -n argocd argocd-initial-admin-secret &>/dev/null; then
  echo -e "\033[0;31m[!] ArgoCD admin secret not found.\033[0m"
  exit 1
fi

PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo -e "\033[0;35mUSERNAME: admin\033[0m"
echo -e "\033[0;35mPASSWORD: $PASSWORD\033[0m"

echo "ArgoCD Login Information" > "Argo Authentication Info.auth"
echo "USERNAME: admin" >> "Argo Authentication Info.auth"
echo "PASSWORD: $PASSWORD" >> "Argo Authentication Info.auth"
