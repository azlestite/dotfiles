# -include .env
# export

# DOCKER_IMAGE_NAME=dotfiles
# DOCKER_ARCH=x86_64
# DOCKER_NUM_CPU=4
# DOKCER_RAM_GB=4
# HOST ?= 127.0.0.1
# PORT ?= 8000
# MKDOCS = uv run \
# 	--with mkdocs \
# 	--with mkdocs-material \
# 	--with mkdocs-toc-md \
# 	mkdocs

SHELL := /bin/bash
.DEFAULT_GOAL := help

.PHONY: help
help: ## Display this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

#
# Docker
#

.PHONY: docker-build docker-rebuild docker-up docker-down docker-shell
docker-build: ## Build the Docker image
	@ docker compose build

docker-rebuild: ## Rebuild the Docker image (without cache)
	@ docker compose build --no-cache

docker-up: ## Start the containers in detached mode and launch a shell
	@ docker compose up -d
	@ docker compose exec -it dotfiles /bin/bash --login

docker-down: ## Stop and remove containers
	@ docker compose down

docker-shell: ## Launch a shell inside the container
	@ echo "$(BW_CLIENTID)"
	@ $(MAKE) docker-up
	@ docker compose exec -it dotfiles /bin/bash --login


# .PHONY: d-docker
# d-docker: ## Build the Docker image and launch a shell
# 	@if ! docker inspect $(DOCKER_IMAGE_NAME) &>/dev/null; then \
# 		docker build -t $(DOCKER_IMAGE_NAME) . \
# 			--build-arg USERNAME="$$(whoami)"; \
# 	fi
# 	docker run -it --rm -v "$$(pwd):/home/$$(whoami)/.local/share/chezmoi" \
# 		-e BW_CLIENTID=$(BW_CLIENTID) \
# 		-e BW_CLIENTSECRET=$(BW_CLIENTSECRET) \
# 		--hostname $(DOCKER_IMAGE_NAME)-test \
# 		$(DOCKER_IMAGE_NAME) /bin/bash --login

# .PHONY: d-docker-rebuild
# d-docker-rebuild: ## Rebuild the Docker image and launch a shell
# 	docker build -t $(DOCKER_IMAGE_NAME) . \
# 		--no-cache \
# 		--build-arg USERNAME="$$(whoami)"

# Setup
.PHONY: setup
setup: ## Run the setup script to initialize the dotfiles
	source pre_setup.sh && echo $BW_SESSION

#
# Chezmoi
#

.PHONY: init
init: ## Initialize chezmoi and apply the configuration
# 	chezmoi init --apply
	chezmoi init --apply && \
	source ~/.profile && \
	chezmoi --source ~/.local/share/chezmoi-private \
		--config ~/.config/chezmoi-private/chezmoi.toml init --apply --ssh azlestite/dotfiles-private || \
	echo "Warning: failed to initialize dotfiles-private. Continuing setup."
# 	source ~/.bashrc && chezmoi --source ~/.local/share/chezmoi-private --config ~/.config/chezmoi-private/chezmoi.toml init --apply --ssh azlestite/dotfiles-private || \
		echo "Warning: failed to initialize dotfiles-private. Continuing setup."
# 	chezmoi-private init --apply --ssh azlestite/dotfiles-private || \
		echo "Warning: failed to initialize dotfiles-private. Continuing setup."

.PHONY: update
update:  ## Update the dotfiles from the source repository and apply the configuration
	chezmoi apply --verbose
	chezmoi-private apply --verbose

# .PHONY: watch
# watch:
# 	DOTFILES_DEBUG=1 watchexec -- chezmoi apply --verbose

# .PHONY: reset
# reset:
# 	chezmoi state delete-bucket --bucket=scriptState

# .PHONY: reset-config
# reset-config:
# 	chezmoi init --data=false

# .PHONY: format
# format:
# 	shfmt --indent 4 --space-redirects --diff .

#
# Documentation
#

# .PHONY: docs
# docs:
# 	@echo "==> Generating docs"
# 	./scripts/generate-docs.sh
# 	@echo "==> Refreshing TOC"
# 	$(MKDOCS) build --clean
# 	@echo "==> Building docs"
# 	$(MKDOCS) build --clean --strict

# .PHONY: serve
# serve: docs
# 	@echo "==> Serving docs"
# 	$(MKDOCS) serve -a $(HOST):$(PORT)

# .PHONY: deploy
# deploy: docs
# 	@echo "==> Deploying docs"
# 	$(MKDOCS) gh-deploy --force

# .PHONY: clean
# clean:
# 	@echo "==> Cleaning generated docs"
# 	rm -rf docs/reference site
# 	rm -f docs/index.md docs/catalog.md
