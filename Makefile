#!/bin/sh

MAKEFILE_UTILS_DIR := ./scripts/makefile/makefile-utils

include $(MAKEFILE_UTILS_DIR)/shell-tests.mk

# Print list of commands
.PHONY: help
help: shell-help
