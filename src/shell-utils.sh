#!/usr/bin/env bash

set -e

# ---------------------------------------------- #
#                    Constants                   #
# ---------------------------------------------- #

# Colors
red="\e[31m"
green="\e[32m"
yellow="\e[33m"
normal="\e[0m"

yes_pattern="[Yy]"

# ---------------------------------------------- #
#                     Git tag                    #
# ---------------------------------------------- #

# Ask confirmation before pushing tag to git. Else, cancel the operation.
function tag_version() {
  local tag=$1

  print_target_tag "$tag"

  ask "Push this tag? (y/n)" answer

  (is_yes "$answer" && git_push_tag "$tag" && print_success_tag) \
    || print_cancel_tag
}

# Ask version to user if not previously given in input.
function ask_version() {
  local name=$2
  local version=$3

  [ -z "$version" ] && ask "Version of $name? (format: x.y.z)" version

  quote "$1='$version'"
}

# Validate the given version.
function validate_version() {
  local name=$1
  local version=$2

  [ -z "$version" ] && alert_die "$name version is empty"

  return 0
}

function print_target_tag() {
  local tag=$1

  print_new_line
  print "Version to tag: $tag"
}

function print_success_tag() {
  print_new_line
  success "Tag pushed"
}

function print_cancel_tag() {
  print_new_line
  warning "Operation cancelled"
}

function git_push_tag() {
  local tag=$1

  git tag "$tag"
  git push --tags
}

# ---------------------------------------------- #
#                     Common                     #
# ---------------------------------------------- #

function is_yes() {
  local answer=$1

  [ "$answer" != "${answer#$yes_pattern}" ]
}

function alert_die() {
  local error="$1"

  print_new_line
  alert "Error: $error"
  die
}

function quote() {
  eval "$*"
}

function is_root() {
  [[ $(id -u) -eq 0 ]]
}

function validate_checksum() {
  local checksum=$1
  local file=$2

  print "$checksum" "$file" | sha256sum --quiet --check -
}

# ---------------------------------------------- #
#                      Files                     #
# ---------------------------------------------- #

# Remove directory and its files.
function remove() {
  print "Remove $1"
  rm -rf "$1"
}

# Remove files in a directory from a pattern.
function remove_by_pattern() {
  local target_dir=$1
  local target_files=$2

  if [[ ! -d $target_dir ]]; then
    warning "$target_dir already removed: skipped"
    return 0
  fi

  print "Remove $target_files in $target_dir"
  find "$target_dir" -name "$target_files" -delete
}

# ---------------------------------------------- #
#                     Output                     #
# ---------------------------------------------- #

function print() {
  echo -e "$*"
}

# Prints an error to STDERR.
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

# ---------------------------------------------- #
#                      Input                     #
# ---------------------------------------------- #

# Ask a question and gets its answer.
function ask() {
  question=$1

  print_new_line
  print "$question"

  shift
  prompt "$*"
}

# Wrapper for "read".
function prompt() {
  read -r "$*"
}

# ---------------------------------------------- #
#                      Exit                      #
# ---------------------------------------------- #

# Wrapper for "exit" when error.
function die() {
  exit 1
}

# Wrapper for "exit" without error.
function close() {
  exit 0
}
