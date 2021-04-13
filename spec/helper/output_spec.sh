#!/bin/sh

Describe "shell-utils.sh: Output functions" utils:output
  Include ./src/shell-utils.sh

  It "should print a text"
    word1="Hello"
    word2="World"

    When call print $word1 $word2
    The output should equal "$word1 $word2"
  End

  It "prints an error"
    message="Something bad happened"

    When call print_error "$message"
    The output should equal ""
    The error should equal "$message"
  End

  It "should print a new line"
    When call print_new_line
    The output should equal ""
  End

  It "should print a success message"
    message="It works"

    When call success "$message"
    The output should equal "${GREEN}$message${NORMAL}"
  End

  It "should print a warning message"
    message="Be careful!"

    When call warning "$message"
    The output should equal "${YELLOW}$message${NORMAL}"
  End

  It "should print an alert message"
    message="Error!!!"

    When call alert $message
    The status should be success
    The output should equal ""
    The error should equal "${RED}$message${NORMAL}"
  End
End
