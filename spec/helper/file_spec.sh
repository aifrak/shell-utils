#!/usr/bin/env bash

yellow="\e[33m"
normal="\e[0m"

Describe "shell-utils.sh: Exit functions" utils:output
  Include ./src/shell-utils.sh

  dummies_dir=./spec/dummies
  fake_dir=$dummies_dir/fake_dir
  not_existing_dir=$dummies_dir/not_existing_dir
  fake_file=$fake_dir/fake_file

  setup() {
    mkdir -p $fake_dir
    touch $fake_file
    touch "${fake_file}_DELETE"
    touch "${fake_file}_DELETE2"
    touch "${fake_file}_KEEP"
}
  cleanup() {
    rm -rf $dummies_dir
}
  BeforeEach 'setup'
  AfterEach 'cleanup'

  It "should remove file"
    When call remove "$fake_file"
    The output should equal "Remove $fake_file"
    The path $fake_file should not be exist
  End

  It "should remove directory"
    When call remove "$fake_dir"
    The output should equal "Remove $fake_dir"
    The path $fake_dir should not be exist
  End

  It "should remove by pattern"
    When call remove_by_pattern "$fake_dir" fake_file_DELETE*
    The output should equal "Remove fake_file_DELETE* in $fake_dir"
    The path "${fake_file}_DELETE" should not be exist
    The path "${fake_file}_DELETE2" should not be exist
    The path "${fake_file}_KEEP" should be exist
  End

  It "should remove by pattern already deleted"
    message="$not_existing_dir already removed: skipped"

    When call remove_by_pattern "$not_existing_dir" not_existing_file*
    The output should equal "$(echo -e "${yellow}$message${normal}")"
  End

End
