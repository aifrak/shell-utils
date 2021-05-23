#!/usr/bin/env bash

Describe "shell-utils.sh: Input functions" utils:input
  Include ./src/shell-utils.sh

  It "should ask by printing a question"
    Mock prompt
      # do nothing
    End

    question="Is it working?"

    When call ask "$question" answer
    The line 2 of output should equal "$question"
  End
End
