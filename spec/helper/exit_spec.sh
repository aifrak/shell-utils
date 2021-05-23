#!/usr/bin/env bash

Describe "shell-utils.sh: Exit functions" utils:output
  Include ./src/shell-utils.sh

  It "should die"
    When run die
    The status should be failure
  End

  It "should close"
    When run close
    The status should be success
  End

End
