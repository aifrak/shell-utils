#!/bin/sh

Describe "shell-utils.sh: Git tag functions" utils:git-tag
  Include ./src/shell-utils.sh

  ExampleGroup "tag_version"
    It "should tag a version and print a success message"
      Mock ask
        # Do nothing
      End

      Mock is_yes
        return 0
      End

      Mock git_push_tag
        # Do nothing
      End

      Mock print_success_tag
        echo "Success"
      End

      When call tag_version "fake-tag"
      The line 3 of output should equal "Success"
    End

    It "should tag a version and print a cancel message"
      Mock ask
        # Do nothing
      End

      Mock is_yes
        return 1
      End

      Mock print_cancel_tag
        echo "Cancelled"
      End

      When call tag_version "fake-tag"
      The line 3 of output should equal "Cancelled"
    End
  End

  ExampleGroup "ask_version"
    It "should ask the version"
      Mock prompt
        # Do nothing
      End

      version=""
      name="Fake name"

      When call ask_version version "$name" "$version"
      The line 2 of output should equal "Version of $name? (format: x.y.z)"
    End

    It "should not ask the version"
      Mock prompt
        # Do nothing
      End

      version="1.2.3"
      name="Fake name"

      When call ask_version version "$name" "$version"
      The output should equal ""
    End
  End

  ExampleGroup "validate_version"
    It "should should do nothing when filled version"
      name="Fake name"
      version="1.2.3"

      When call validate_version "$name" "$version"
      The output should equal ""
    End

    It 'should print an error when empty version'
      name="Fake name"
      version=""

      When run validate_version "$name" "$version"
      The status should be failure
      The output should equal ""
      The error should equal "${RED}Error: $name version is empty${NORMAL}"
    End
  End

  ExampleGroup "print tag message"
    It "should print cancel tag message"
      When call print_cancel_tag
      The line 2 of output should equal "${YELLOW}Operation cancelled${NORMAL}"
    End

      It "should print success tag message"
      When call print_success_tag
      The line 2 of output should equal "${GREEN}Tag pushed${NORMAL}"
    End
  End

  It "should print target tag 'fake-tag'"
    tag="fake-tag"

    When call print_target_tag $tag
    The line 2 of output should equal "Version to tag: $tag"
  End

  It "should git tag"
    Mock git
      # Do nothing
    End

    When call git_push_tag $tag
    The status should be success
  End
End
