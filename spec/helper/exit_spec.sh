#!/bin/sh

Describe "shell-utils.sh: Exit functions" utils:output
  Include ./src/shell-utils.sh

  It "should die"
    When run die
    The status should be failure
  End

End
