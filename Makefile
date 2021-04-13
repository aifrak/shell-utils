#!/bin/sh

MAKEFILE_UTILS_DIR := ./scripts/makefile/makefile-utils

include $(MAKEFILE_UTILS_DIR)/shell-test.mk

# Print list of commands
.PHONY: help
help: shell-help
