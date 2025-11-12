# ============================================
# Docker Build Utility for Composer + NodeJS
# ============================================

.DEFAULT_GOAL := help

# Variables (overridable)
DEBIAN ?= bookworm
PHP_VERSION ?= 8.3
NODE_VERSION ?= 22

IMAGE_NAME ?= local/drupal-devcontainer
IMAGE_TAG ?= p$(PHP_VERSION)-n$(NODE_VERSION)-$(DEBIAN)

TIMESTAMP := $(shell date +'%Y%m%d')
IMAGE := $(IMAGE_NAME):$(IMAGE_TAG)

S ?= zsh

.PHONY: build run check help

## 🏗️ Build the Docker image
build:
	@echo "🛠️  Building Docker image: $(IMAGE)"
	docker build \
		--build-arg DEBIAN=$(DEBIAN) \
		--build-arg PHP=$(PHP_VERSION) \
		--build-arg NODE_VERSION=$(NODE_VERSION) \
		--build-arg CREATE_DATE="$(TIMESTAMP)" \
		--no-cache \
		-t $(IMAGE) . \
		-t $(IMAGE_NAME):latest

## 🚀 Run the container interactively
run:
	@echo "🚀 Starting $(IMAGE)..."
	docker run --rm -it \
	-h "drupal-dev" \
	-p 80:80 \
	-v "drupal-dev-html:/var/www/html" \
	-e "TESTING_1=⭐⭐⭐Hello World!⭐⭐⭐" \
	-e "TESTING_2=🚀🛸🛰️🕳️💫" \
	local/drupal-devcontainer:latest $(S)

## 🔍 Check installed versions inside the image
check:
	@echo "🔎 Checking versions in $(IMAGE)..."
	docker run --rm $(IMAGE) bash -c "\
		echo '✅ PHP Version:' && php --version && \
		echo && echo '✅ Composer Version:' && composer --version && \
		echo && echo '✅ Node Version:' && node --version && \
		echo && echo '✅ NPM Version:' && npm --version"

## 📘 Display help
help:
	@echo ""
	@echo "📘 Available Commands:"
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  make %-10s %s\n", $$1, $$2}'
	@echo ""
