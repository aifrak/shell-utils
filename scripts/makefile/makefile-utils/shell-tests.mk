#!/bin/sh

include $(MAKEFILE_UTILS_DIR)/makefile-utils.mk

SHELL := sh

DOCKER := docker

# Docker image for ShellCheck
SHELLCHECK := koalaman/shellcheck:v0.7.1
# Path of the project inside Docker container
SHELLCHECK_PATH := ./src/**.sh
# Path of the project on the host when ShellCheck
SHELLCHECK_HOST_DIR := ${PWD}

# Docker image for ShellSpec
SHELLSPEC := shellspec/shellspec:0.28.1
# Path of the project on the host when ShellSpec
SHELLSPEC_HOST_DIR := ${PWD}

# Print list of commands
.PHONY: shell-help
shell-help:
	@echo ""
	@echo "Shell test commands:"
	@echo "  shell-test-all:         Run all unit tests and lint for Shell scripts"
	@echo "  shell-lint:             Lint Shell scripts"
	@echo "  shell-test:             Run Shell unit tests"
	@echo "  shell-test-format:      Lint Shell unit tests (ShellSpec)"

# Run all unit tests and linter for shell scripts
.PHONY: shell-test-all
shell-test-all: shell-lint shell-lint-tests shell-test

# Lint Shell scripts
.PHONY: shell-lint
shell-lint:
	@echo ""
	@echo "- Lint Shell scripts:"
	@echo ""
	@$(DOCKER) run --rm -v "${SHELLCHECK_HOST_DIR}:/mnt" ${SHELLCHECK} ${SHELLCHECK_PATH} \
		--shell=$(SHELL) --format=tty -x
	@echo ""
	@echo $(call print_success, "✔ Lint Shell scripts: OK")

# RunShell unit tests
.PHONY: shell-test
shell-test:
	@echo ""
	@echo "- Run Shell unit tests:"
	@echo ""
	@$(DOCKER) run --rm -v "${SHELLSPEC_HOST_DIR}:/src" ${SHELLSPEC} \
	--format progress --jobs 10
	@echo $(call print_success, "✔ Run Shell unit tests: OK")

# Lint Shell unit tests (ShellSpec)
.PHONY: shell-lint-tests
shell-lint-tests:
	@echo ""
	@echo "- Lint Shell unit tests (ShellSpec):"
	@echo ""
	@$(DOCKER) run --rm -v "${SHELLSPEC_HOST_DIR}:/src" ${SHELLSPEC} \
		--syntax-check
	@echo ""
	@echo $(call print_success, "✔ Lint Shell unit tests \(ShellSpec\): OK")
