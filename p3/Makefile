SHELL := /bin/bash

CLUSTER_NAME ?= iot-cluster
APP_NAME ?= wil-playground
APP_NAMESPACE ?= dev
APP_LOCAL_PORT ?= 8888
APP_REMOTE_PORT ?= 80
ARGOCD_PORT ?= 8080

.PHONY: setup start clean pass status fw sfw guide help

setup:
	@bash scripts/setup.sh $(CLUSTER_NAME) $(ARGOCD_PORT)

start:
	@bash scripts/start-argocd.sh $(CLUSTER_NAME)

pass:
	@bash scripts/get-password.sh $(CLUSTER_NAME)

clean:
	@bash scripts/clean.sh $(CLUSTER_NAME)

status:
	@bash scripts/status.sh $(CLUSTER_NAME)

fw:
	@bash scripts/start-forward.sh $(APP_NAME) $(APP_NAMESPACE) $(APP_LOCAL_PORT) $(APP_REMOTE_PORT)

sfw:
	@bash scripts/stop-forward.sh

guide:
	@bash scripts/argo-guide.sh

help:
	@echo "🧪 Kullanılabilir komutlar:"
	@echo ""
	@echo "  make setup                      → Sistemi kurar (cluster: $(CLUSTER_NAME))"
	@echo "  make setup CLUSTER_NAME=abc    → Belirli cluster adıyla kurar"
	@echo ""
	@echo "  make start                      → Argo CD port-forward başlatır"
	@echo "  make pass                       → Argo CD şifresini gösterir"
	@echo ""
	@echo "  make fw                         → Uygulama port yönlendirmesini başlatır"
	@echo "      Varsayılan: $(APP_NAME) @ $(APP_NAMESPACE) → localhost:$(APP_LOCAL_PORT) → svc:$(APP_REMOTE_PORT)"
	@echo "      Örnek: make fw APP_NAME=api APP_NAMESPACE=prod APP_LOCAL_PORT=9999 APP_REMOTE_PORT=8080"
	@echo ""
	@echo "  make sfw                        → Port yönlendirmesini durdurur"
	@echo "  make status                     → Cluster ve pod durumlarını gösterir"
	@echo "  make clean                      → Cluster’ı ve tüm geçici işlemleri siler (cluster: $(CLUSTER_NAME))"
	@echo "  make clean CLUSTER_NAME=abc     → Belirli cluster’ı siler"
	@echo ""
	@echo "  make guide                      → Argo CD üzerinden uygulama ekleme rehberi"
	@echo "  make help                       → Bu yardım mesajını gösterir"
