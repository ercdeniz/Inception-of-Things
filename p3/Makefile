SHELL := /bin/bash

.PHONY: setup start clean password

setup:
	@bash scripts/setup.sh

start:
	@bash scripts/start-argocd.sh

pass:
	@bash scripts/get-password.sh

clean:
	@bash scripts/clean.sh

status:
	@bash scripts/status.sh

forward:
	@bash scripts/forward.sh
help:
	@echo "Kullanılabilir komutlar:"
	@echo "  make setup     → Sistemi baştan kurar"
	@echo "  make start     → Argo CD'yi başlatır (port-forward)"
	@echo "  make pass      → Argo CD şifresini gösterir"
	@echo "  make status    → Cluster durumunu gösterir"
	@echo "  make clean     → Tüm yapıyı siler"
