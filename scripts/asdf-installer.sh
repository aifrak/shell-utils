#!/usr/bin/env bash

set -e

# ---------------------------------------------- #
#
# Install/Uninstall asdf plugins and versions from .tool-versions.
#
# "asdf-installer.sh --help" for more information.
#
# ---------------------------------------------- #

# ---------------------------------------------- #
#                   shell-utils                  #
# ---------------------------------------------- #

# Colors
red="\e[31m"
green="\e[32m"
yellow="\e[33m"
normal="\e[0m"

function alert_die() {
  local error="$1"

  print_new_line
  alert "Error: $error"
  die
}

function print() {
  echo -e "$*"
}

function print_error() {
  print >&2 "$*"
}

function print_new_line() {
  print ""
}

# Prints a green success message.
function success() {
  print "${green}$*${normal}"
}

# Prints a yellow warning message.
function warning() {
  print "${yellow}$*${normal}"
}

# Prints a red error message.
function alert() {
  print_error "${red}$*${normal}"
}

# Wrapper for "exit" when error.
function die() {
  exit 1
}

# ---------------------------------------------- #
#                 asdf installer                 #
# ---------------------------------------------- #

function help() {
  cat <<EOF

Install/Uninstall asdf plugins and versions from .tool-versions.

Syntax:
  $0 install [local|global|shell]     Install plugins and versions from .tool-versions
  $0 uninstall [versions|plugins]     Uninstall plugins and versions from .tool-versions

Options:
  -h, --help:     Show this message"

EOF
}

function is_plugin_installed() {
  local plugin=$1

  print "$all_plugins" | grep -Fxq "$plugin" >/dev/null 2>&1
}

function is_version_installed() {
  local plugin=$1

  ! asdf where "$plugin" "$version" |
    grep -Fxq "Version not installed" >/dev/null 2>&1
}

function plugin_from_line() {
  local line=$1

  print "$line" | cut -d " " -f1
}

function version_from_line() {
  local line=$1

  print "$line" | cut -d " " -f2
}

function uncommented_lines() {
  grep -v "^ *#" <".tool-versions"
}

function install() {
  all_plugins=$(asdf plugin list)

  uncommented_lines | while IFS= read -r line; do
    plugin=$(plugin_from_line "$line")
    version=$(version_from_line "$line")

    if ! is_plugin_installed "$plugin"; then
      asdf plugin add "$plugin"
    fi

    if ! is_version_installed "$plugin"; then
      asdf install "$plugin" "$version"
      asdf "$scope" "$plugin" "$version"
    fi
  done

  success "✓ Install done!"
}

function uninstall_versions() {
  uncommented_lines | while IFS= read -r line; do
    plugin=$(plugin_from_line "$line")
    version=$(version_from_line "$line")

    if is_version_installed "$plugin"; then
      asdf uninstall "$plugin" "$version"
    fi
  done

  success "✓ Uninstall done!"
}

function uninstall_plugins() {
  all_plugins=$(asdf plugin list)

  uncommented_lines | while IFS= read -r line; do
    plugin=$(plugin_from_line "$line")

    if is_plugin_installed "$all_plugins" "$plugin"; then
      asdf plugin remove "$plugin"
    fi
  done

  success "✓ Uninstall done!"
}

function is_valid_install_scope() {
  scopes="local global shell"

  print "$scopes" | grep -qw "$scope"
}

function is_valid_uninstall_mode() {
  modes="versions plugins"

  print "$modes" | grep -qw "$mode"
}

function validate_install_scope() {
  if [[ -z $scope ]]; then
    alert_die "Install scope is required"
  fi

  if ! is_valid_install_scope "$scope"; then
    alert_die "Unknown install scope"
  fi
}

function validate_uninstall_mode() {
  if [[ -z $mode ]]; then
    alert_die "Uninstall mode is required"
  fi

  if ! is_valid_mode "$mode"; then
    alert_die "Unknown uninstall mode"
  fi
}

function parse_options() {
  for opt in "$@"; do
    case $opt in
    -h | --help)
      help
      close
      ;;

    --* | -*)
      alert "Error: Unknown option $opt"
      help
      die
      ;;
    esac
  done
}

apply_command() {
  if [ -n "$1" ]; then
    local command=$1
  else
    help
    die
  fi

  for opt in $command; do
    case $opt in
    install)

      scope="$2"
      validate_install_scope
      install
      ;;

    uninstall)

      mode="$2"
      validate_uninstall_mode
      uninstall_"$mode"

      ;;

    *)
      alert "Error: Unknown command $opt"
      die
      ;;
    esac
  done
}

parse_options "$@"
apply_command "$@"
