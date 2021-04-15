#!/bin/sh

# ---------------------------------------------- #
# ------------------ Constants ----------------- #
# ---------------------------------------------- #

# Colors
export RED="\e[31m"
export GREEN="\e[32m"
export YELLOW="\e[33m"
export NORMAL="\e[0m"

YES_PATTERN="[Yy]"

# ---------------------------------------------- #
# ------------------- Git tag ------------------ #
# ---------------------------------------------- #

# Ask confirmation before pushing tag to git. Else, cancel the operation.
#
# Input: $1 -> tag:string
tag_version() {
  tag=$1

  print_target_tag "$tag"

  ask "Push this tag? (y/n)" answer

  (is_yes "$answer" && git_push_tag "$tag" && print_success_tag) ||
    print_cancel_tag
}

# Ask version to user if not previously given in input.
#
# Input:  $2 -> name:string Name of the package
#         $3 -> version:string Version given as input
# Output: $1 -> version:string Return the input of the user
ask_version() {
  name=$2
  version=$3

  [ -z "$version" ] && ask "Version of $name? (format: x.y.z)" version

  quote "$1='$version'"
}

# Validate the given version.
#
# Input:  $1 -> name:string Name of the package
#         $2 -> version:string Version given as input
# Output: 0 -> int Return 0 when function ends
validate_version() {
  name=$1
  version=$2

  [ -z "$version" ] && alert_die "$name version is empty"

  return 0
}

# Print the given tag.
#
# Input:  $1 -> tag:string
print_target_tag() {
  tag=$1

  print_new_line
  print "Version to tag: $tag"
}

# Print message for tag success.
print_success_tag() {
  print_new_line
  success "Tag pushed"
}

# Print message for tag cancellation.
print_cancel_tag() {
  print_new_line
  warning "Operation cancelled"
}

# Push tag to git.
#
# Input: $1 -> tag:string Tag to push
git_push_tag() {
  tag=$1

  git tag "$tag"
  git push --tags
}

# ---------------------------------------------- #
# ------------------- Common ------------------- #
# ---------------------------------------------- #

# Check the given answer is positive.
#
# Input:  $1 -> answer:string Anwser given
is_yes() {
  answer=$1

  [ "$answer" != "${answer#$YES_PATTERN}" ]
}

# Print an error and die.
#
# Input:  $1 -> error:string Error to print
alert_die() {
  error="$1"

  print_new_line
  alert "Error: $error"
  die
}

# Wrapper for "eval".
quote() {
  eval "$*"
}

# ---------------------------------------------- #
# ------------------- Output ------------------- #
# ---------------------------------------------- #

# Wrapper for "echo".
print() {
  echo "$*"
}

# Prints an error to STDERR.
#
# Input: $* -> string Message to print
print_error() {
  print >&2 "$*"
}

# Prints a new line.
print_new_line() {
  print ""
}

# Prints a green success message.
#
# Input:  $* -> string Message to print
success() {
  print "${GREEN}$*${NORMAL}"
}

# Prints a yellow warning message.
#
# Input:  $* -> string Message to print
warning() {
  print "${YELLOW}$*${NORMAL}"
}

# Prints a red error message.
#
# Input:  $* -> string Message to print
alert() {
  print_error "${RED}$*${NORMAL}"
}

# ---------------------------------------------- #
# -------------------- Input ------------------- #
# ---------------------------------------------- #

# Ask a question and gets its answer.
#
# Input:  $1 -> error:string Question to print
# Input:  $* -> error:string Answer
ask() {
  question=$1

  print_new_line
  print "$question"

  shift
  prompt "$*"
}

# Wrapper for "read".
prompt() {
  read -r "$*"
}

# ---------------------------------------------- #
# -------------------- Exit -------------------- #
# ---------------------------------------------- #

# Wrapper for "die".
die() {
  exit 1
}
