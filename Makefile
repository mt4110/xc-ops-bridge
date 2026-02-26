.PHONY: help bootstrap doctor clean build test open
.DEFAULT_GOAL := help

help: ## Show this help message
	@echo "Usage: make [command]"
	@echo ""
	@echo "Commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

bootstrap: ## Initialize the project (create xcode.env, install git hooks)
	bash ./ops/bootstrap.sh

doctor: ## Diagnose toolchain and environment setup
	bash ./ops/xc doctor

clean: ## Clean build artifacts in .local/
	bash ./ops/xc clean $(ARGS)

build: ## Build the project or SPM package
	bash ./ops/xc build $(ARGS)

test: ## Run tests for the project or SPM package
	bash ./ops/xc test $(ARGS)

open: ## Open the project or Package.swift in Xcode
	bash ./ops/xc open
