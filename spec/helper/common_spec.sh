#!/bin/sh

Describe "shell-utils.sh: Common functions"
  Include ./src/shell-utils.sh

  Describe "should check yes answers"
    Parameters:value "Y" "y" "yes" "Yes" "YES"

    It "should check yes answer with '${1}'"
      When call is_yes "$1"
      The status should be success
    End
  End

  Describe "should check no answers"
    Parameters:value "n" "N" "no" "No" "NO"

    It "should check no answers with '${1}'"
      When call is_yes "$1"
      The status should be failure
    End
  End

  It "should alert and die"
    message="An error occured"

    When run alert_die "$message"
    The status should be failure
    The output should equal ""
    The error should equal "${RED}Error: $message${NORMAL}"
  End
End
