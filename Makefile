# LeHome Challenge Makefile
#
# Targets:
#   make build
#   make run
#   make run_gui
#   make download_assets
#   make download_dataset

IMAGE_NAME ?= lehome:latest
CONTAINER_REPO_PATH ?= /lehome/lehome-challenge

ASSETS_DIR := Assets
DATASETS_DIR := Datasets
DATASET_EXAMPLE_DIR := $(DATASETS_DIR)/example

.PHONY: build run run_gui download_assets download_dataset

# --------------------------------------------------
# Build image
# --------------------------------------------------
build:
	docker build -t $(IMAGE_NAME) .

# --------------------------------------------------
# Run (headless / server)
# --------------------------------------------------
run:
	docker run --rm -it --runtime nvidia --gpus all \
		-v "$(CURDIR)/$(ASSETS_DIR):$(CONTAINER_REPO_PATH)/$(ASSETS_DIR)" \
		-v "$(CURDIR)/$(DATASETS_DIR):$(CONTAINER_REPO_PATH)/$(DATASETS_DIR)" \
		$(IMAGE_NAME)

# --------------------------------------------------
# Run with GUI (IsaacSim / Omniverse window)
# --------------------------------------------------
run_gui:
	@echo "Enabling X11 access for Docker..."
	@xhost +local:docker >/dev/null 2>&1 || true
	docker run --rm -it --gpus all \
		-e DISPLAY=$(DISPLAY) \
		-e QT_X11_NO_MITSHM=1 \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v "$(CURDIR)/$(ASSETS_DIR):$(CONTAINER_REPO_PATH)/$(ASSETS_DIR)" \
		-v "$(CURDIR)/$(DATASETS_DIR):$(CONTAINER_REPO_PATH)/$(DATASETS_DIR)" \
		$(IMAGE_NAME)

# --------------------------------------------------
# Download Assets (guarded)
# --------------------------------------------------
download_assets:
	@mkdir -p "$(ASSETS_DIR)"
	@if [ "$$(ls -A "$(ASSETS_DIR)" 2>/dev/null | wc -l)" -ne 0 ]; then \
		echo "Skipping: '$(ASSETS_DIR)' is not empty."; \
		exit 0; \
	fi
	hf download lehome/asset_challenge \
		--repo-type dataset \
		--local-dir "$(ASSETS_DIR)"

# --------------------------------------------------
# Download Dataset (guarded)
# --------------------------------------------------
download_dataset:
	@mkdir -p "$(DATASET_EXAMPLE_DIR)"
	@if [ "$$(ls -A "$(DATASET_EXAMPLE_DIR)" 2>/dev/null | wc -l)" -ne 0 ]; then \
		echo "Skipping: '$(DATASET_EXAMPLE_DIR)' is not empty."; \
		exit 0; \
	fi
	hf download lehome/dataset_challenge_merged \
		--repo-type dataset \
		--local-dir "$(DATASET_EXAMPLE_DIR)"
	hf download lehome/dataset_challenge \
		--repo-type dataset \
		--local-dir "$(DATASET_EXAMPLE_DIR)"

