# Orkestra Registry — build, push, and test all patterns
#
# Usage:
#   make push-motifs                        push all motifs at MOTIF_VERSION
#   make push-motif NAME=redis              push one motif
#   make push-katalogs                      push all katalogs at KATALOG_VERSION
#   make push-katalog NAME=postgres         push one katalog (runs e2e gate)
#   make push-katalog NAME=postgres FORCE=1 push one katalog, skip e2e
#   make e2e NAME=postgres                  run e2e for one katalog
#   make e2e-all                            run e2e for every katalog in sequence
#   make push-all                           push motifs then katalogs
#   make help                               show this message

MOTIF_VERSION   ?= v0.1.0
KATALOG_VERSION ?= v1.0.0
NAME            ?=
FORCE           ?= 0

MOTIFS_DIR   := patterns/motifs
KATALOGS_DIR := patterns/katalogs

ORK := $(shell which ork 2>/dev/null || echo "$(HOME)/.orkestra/bin/ork")

# ── helpers ──────────────────────────────────────────────────────────────────

_require_name:
	@test -n "$(NAME)" || (echo "ERROR: NAME is required  (e.g. make $(MAKECMDGOALS) NAME=redis)"; exit 1)

# list all motif names (directories that contain motif.yaml)
MOTIF_NAMES := $(notdir $(shell find $(MOTIFS_DIR) -mindepth 1 -maxdepth 1 -type d))

# list all katalog names (directories that have a versioned subdirectory)
KATALOG_NAMES := $(notdir $(shell find $(KATALOGS_DIR) -mindepth 1 -maxdepth 1 -type d))

_force_flag := $(if $(filter 1,$(FORCE)),--force,)

# ── motifs ───────────────────────────────────────────────────────────────────

.PHONY: push-motifs
push-motifs:
	@echo "Pushing all motifs at $(MOTIF_VERSION)..."
	@for name in $(MOTIF_NAMES); do \
	  echo ""; \
	  echo "→ $$name:$(MOTIF_VERSION)"; \
	  $(ORK) registry push "$$name:$(MOTIF_VERSION)" "$(MOTIFS_DIR)/$$name" || exit 1; \
	done
	@echo ""
	@echo "✓ All motifs pushed at $(MOTIF_VERSION)"

.PHONY: push-motif
push-motif: _require_name
	@echo "→ Pushing motif $(NAME):$(MOTIF_VERSION)..."
	$(ORK) registry push "$(NAME):$(MOTIF_VERSION)" "$(MOTIFS_DIR)/$(NAME)"

# ── katalogs ─────────────────────────────────────────────────────────────────

.PHONY: push-katalogs
push-katalogs:
	@echo "Pushing all katalogs at $(KATALOG_VERSION)..."
	@for name in $(KATALOG_NAMES); do \
	  dir="$(KATALOGS_DIR)/$$name/$(KATALOG_VERSION)"; \
	  [ -d "$$dir" ] || continue; \
	  echo ""; \
	  echo "→ $$name:$(KATALOG_VERSION)"; \
	  $(ORK) registry push "$$name:$(KATALOG_VERSION)" "$$dir" $(_force_flag) || exit 1; \
	done
	@echo ""
	@echo "✓ All katalogs pushed at $(KATALOG_VERSION)"

.PHONY: push-katalog
push-katalog: _require_name
	@echo "→ Pushing katalog $(NAME):$(KATALOG_VERSION)..."
	$(ORK) registry push "$(NAME):$(KATALOG_VERSION)" \
	  "$(KATALOGS_DIR)/$(NAME)/$(KATALOG_VERSION)" $(_force_flag)

# ── e2e ──────────────────────────────────────────────────────────────────────

.PHONY: e2e
e2e: _require_name
	@e2e_file="$(KATALOGS_DIR)/$(NAME)/$(KATALOG_VERSION)/e2e.yaml"; \
	[ -f "$$e2e_file" ] || (echo "ERROR: $$e2e_file not found"; exit 1); \
	echo "→ Running e2e for $(NAME) $(KATALOG_VERSION)..."; \
	$(ORK) e2e -f "$$e2e_file"

.PHONY: e2e-all
e2e-all:
	@echo "Running e2e for all katalogs at $(KATALOG_VERSION)..."
	@failed=""; \
	for name in $(KATALOG_NAMES); do \
	  e2e_file="$(KATALOGS_DIR)/$$name/$(KATALOG_VERSION)/e2e.yaml"; \
	  [ -f "$$e2e_file" ] || continue; \
	  echo ""; \
	  echo "══════════════════════════════════════"; \
	  echo "  $$name"; \
	  echo "══════════════════════════════════════"; \
	  if ! $(ORK) e2e -f "$$e2e_file"; then \
	    failed="$$failed $$name"; \
	  fi; \
	done; \
	echo ""; \
	if [ -n "$$failed" ]; then \
	  echo "✗ Failed:$$failed"; exit 1; \
	else \
	  echo "✓ All katalog e2e tests passed"; \
	fi

# ── combined ─────────────────────────────────────────────────────────────────

.PHONY: push-all
push-all: push-motifs push-katalogs
	@echo ""
	@echo "✓ All patterns pushed (motifs $(MOTIF_VERSION), katalogs $(KATALOG_VERSION))"

# ── help ─────────────────────────────────────────────────────────────────────

.PHONY: help
help:
	@echo ""
	@echo "Orkestra Registry"
	@echo ""
	@echo "  Motifs ($(MOTIF_VERSION)):"
	@echo "    make push-motifs                        push all motifs"
	@echo "    make push-motif  NAME=<name>            push one motif"
	@echo ""
	@echo "  Katalogs ($(KATALOG_VERSION)):"
	@echo "    make push-katalogs                      push all katalogs (runs e2e gate)"
	@echo "    make push-katalog  NAME=<name>          push one katalog"
	@echo "    make push-katalog  NAME=<name> FORCE=1  push, skip e2e gate"
	@echo ""
	@echo "  E2E:"
	@echo "    make e2e      NAME=<name>               run e2e for one katalog"
	@echo "    make e2e-all                            run e2e for all katalogs"
	@echo ""
	@echo "  Combined:"
	@echo "    make push-all                           push motifs then katalogs"
	@echo ""
	@echo "  Versions:"
	@echo "    MOTIF_VERSION=$(MOTIF_VERSION)  KATALOG_VERSION=$(KATALOG_VERSION)"
	@echo "    Override: make push-motifs MOTIF_VERSION=v0.2.0"
	@echo ""

.DEFAULT_GOAL := help
