@skipOnOCIS @ocis-reva-issue-64
Feature: Sharing files and folders with internal groups
  As a user
  I want to share files and folders with groups
  So that those groups can access the files and folders

  Background:
    Given the setting "shareapi_auto_accept_share" of app "core" has been set to "no"
    And the administrator has set the default folder for received shares to "Shares"
    And these users have been created with default attributes:
      | username |
      | user1    |
      | user2    |
      | user3    |
    And these groups have been created:
      | groupname |
      | grp1      |
      | grp11     |
    And user "user1" has been added to group "grp1"
    And user "user2" has been added to group "grp1"

  Scenario: share a folder with multiple collaborators and check collaborator list order
    Given user "user3" has logged in using the webUI
    When the user shares folder "simple-folder" with group "grp11" as "Viewer" using the webUI
    And the user shares folder "simple-folder" with user "User Two" as "Viewer" using the webUI
    And the user shares folder "simple-folder" with group "grp1" as "Viewer" using the webUI
    And the user shares folder "simple-folder" with user "User One" as "Viewer" using the webUI
    Then the current collaborators list should have order "User Three,User One,User Two,grp1,grp11"

  Scenario Outline: share a file & folder with another internal user
    Given user "user3" has logged in using the webUI
    When the user shares folder "simple-folder" with group "grp1" as "<set-role>" using the webUI
    And the user shares file "testimage.jpg" with group "grp1" as "<set-role>" using the webUI
    And user "user1" accepts the share "simple-folder" offered by user "user3" using the sharing API
    And user "user2" accepts the share "simple-folder" offered by user "user3" using the sharing API
    And user "user1" accepts the share "testimage.jpg" offered by user "user3" using the sharing API
    And user "user2" accepts the share "testimage.jpg" offered by user "user3" using the sharing API
    Then group "grp1" should be listed as "<expected-role>" in the collaborators list for folder "simple-folder" on the webUI
    And group "grp1" should be listed as "<expected-role>" in the collaborators list for file "testimage.jpg" on the webUI
    And user "user1" should have received a share with these details:
      | field       | value                |
      | uid_owner   | user3                |
      | share_with  | grp1                 |
      | file_target | /Shares/simple-folder  |
      | item_type   | folder               |
      | permissions | <permissions-folder> |
    And user "user2" should have received a share with these details:
      | field       | value              |
      | uid_owner   | user3              |
      | share_with  | grp1               |
      | file_target | /Shares/testimage.jpg |
      | item_type   | file               |
      | permissions | <permissions-file> |
    And as "user1" these resources should be listed in the folder "Shares" on the webUI
      | entry_name        |
      | simple-folder |
      | testimage.jpg |
    And these resources should be listed in the folder "/Shares%2Fsimple-folder" on the webUI
      | entry_name |
      | lorem.txt  |
    But these resources should not be listed in the folder "/Shares%2Fsimple-folder" on the webUI
      | entry_name        |
      | simple-folder |
    When the user browses to the shared-with-me page using the webUI
    Then folder "simple-folder" should be marked as shared by "User Three" on the webUI
    And file "testimage.jpg" should be marked as shared by "User Three" on the webUI
    Examples:
      | set-role             | expected-role | permissions-folder         | permissions-file |
      | Viewer               | Viewer        | read                       | read             |
      | Editor               | Editor        | read,update,create, delete | read,update      |
      | Advanced permissions | Viewer        | read                       | read             |

  @skip @issue-4102
  Scenario: share a file with an internal group a member overwrites and unshares the file
    Given user "user3" has logged in using the webUI
    When the user renames file "lorem.txt" to "new-lorem.txt" using the webUI
    And the user shares file "new-lorem.txt" with group "grp1" as "Editor" using the webUI
    And user "user1" accepts the share "new-lorem.txt" offered by user "user3" using the sharing API
    And user "user2" accepts the share "new-lorem.txt" offered by user "user3" using the sharing API
    And the user re-logs in as "user1" using the webUI
    Then as "user1" the content of "/Shares/new-lorem.txt" should not be the same as the local "new-lorem.txt"
    # overwrite the received shared file
    When the user opens folder "Shares" using the webUI
    And the user uploads overwriting file "new-lorem.txt" using the webUI
    Then file "new-lorem.txt" should be listed on the webUI
    And as "user1" the content of "/Shares/new-lorem.txt" should be the same as the local "new-lorem.txt"
    # unshare the received shared file
    When the user unshares file "new-lorem.txt" using the webUI
    Then file "new-lorem.txt" should not be listed on the webUI
    # check that another group member can still see the file
    And as "user2" the content of "/Shares/new-lorem.txt" should be the same as the local "new-lorem.txt"
    # check that the original file owner can still see the file
    And as "user3" the content of "new-lorem.txt" should be the same as the local "new-lorem.txt"

  Scenario: share a folder with an internal group and a member uploads, overwrites and deletes files
    Given user "user3" has logged in using the webUI
    When the user renames folder "simple-folder" to "new-simple-folder" using the webUI
    And the user shares folder "new-simple-folder" with group "grp1" as "Editor" using the webUI
    And user "user1" accepts the share "new-simple-folder" offered by user "user3" using the sharing API
    And user "user2" accepts the share "new-simple-folder" offered by user "user3" using the sharing API
    And the user re-logs in as "user1" using the webUI
    And the user opens folder "Shares" using the webUI
    And the user opens folder "new-simple-folder" using the webUI
    Then as "user1" the content of "/Shares/new-simple-folder/lorem.txt" should not be the same as the local "lorem.txt"
    # overwrite an existing file in the received share
    When the user uploads overwriting file "lorem.txt" using the webUI
    Then file "lorem.txt" should be listed on the webUI
    And as "user1" the content of "/Shares/new-simple-folder/lorem.txt" should be the same as the local "lorem.txt"
    # upload a new file into the received share
    When the user uploads file "new-lorem.txt" using the webUI
    Then as "user1" the content of "/Shares/new-simple-folder/new-lorem.txt" should be the same as the local "new-lorem.txt"
    # delete a file in the received share
    When the user deletes file "data.zip" using the webUI
    Then file "data.zip" should not be listed on the webUI
    # check that the file actions by the sharee are visible to another group member
    When the user re-logs in as "user2" using the webUI
    And the user opens folder "Shares" using the webUI
    And the user opens folder "new-simple-folder" using the webUI
    Then as "user2" the content of "/Shares/new-simple-folder/lorem.txt" should be the same as the local "lorem.txt"
    And as "user2" the content of "/Shares/new-simple-folder/new-lorem.txt" should be the same as the local "new-lorem.txt"
    And file "data.zip" should not be listed on the webUI
    # check that the file actions by the sharee are visible for the share owner
    When the user re-logs in as "user3" using the webUI
    And the user opens folder "new-simple-folder" using the webUI
    Then as "user3" the content of "new-simple-folder/lorem.txt" should be the same as the local "lorem.txt"
    And as "user3" the content of "new-simple-folder/new-lorem.txt" should be the same as the local "new-lorem.txt"
    And file "data.zip" should not be listed on the webUI

  @skip @issue-4102
  Scenario: share a folder with an internal group and a member unshares the folder
    Given user "user3" has logged in using the webUI
    When the user renames folder "simple-folder" to "new-simple-folder" using the webUI
    And the user shares folder "new-simple-folder" with group "grp1" as "Editor" using the webUI
    And user "user1" accepts the share "new-simple-folder" offered by user "user3" using the sharing API
    And user "user2" accepts the share "new-simple-folder" offered by user "user3" using the sharing API
    # unshare the received shared folder and check it is gone
    When the user re-logs in as "user1" using the webUI
    And the user opens folder "Shares" using the webUI
    And the user deletes folder "new-simple-folder" using the webUI
    Then folder "new-simple-folder" should not be listed on the webUI
    # check that the folder is still visible to another group member
    When the user re-logs in as "user2" using the webUI
    And the user opens folder "Shares" using the webUI
    Then folder "new-simple-folder" should be listed on the webUI
    When the user opens folder "new-simple-folder" using the webUI
    Then file "lorem.txt" should be listed on the webUI
    And as "user2" the content of "/Shares/new-simple-folder/lorem.txt" should be the same as the original "simple-folder/lorem.txt"
    # check that the folder is still visible for the share owner
    When the user re-logs in as "user3" using the webUI
    Then folder "new-simple-folder" should be listed on the webUI
    When the user opens folder "new-simple-folder" using the webUI
    Then file "lorem.txt" should be listed on the webUI
    And as "user3" the content of "new-simple-folder/lorem.txt" should be the same as the original "simple-folder/lorem.txt"

  @skip @yetToImplement
  Scenario: user tries to share a file in a group which is excluded from receiving share
    Given group "system-group" has been created
    And the administrator has browsed to the admin sharing settings page
    When the administrator excludes group "system-group" from receiving shares using the webUI
    Then user "user1" should not be able to share file "lorem.txt" with group "system-group" using the sharing API

  @skip @yetToImplement
  Scenario: user tries to share a folder in a group which is excluded from receiving share
    Given group "system-group" has been created
    And the administrator has browsed to the admin sharing settings page
    When the administrator excludes group "system-group" from receiving shares using the webUI
    Then user "user1" should not be able to share folder "simple-folder" with group "system-group" using the sharing API

  Scenario: user shares the file/folder with a group and delete the share with group
    Given user "user1" has logged in using the webUI
    And user "user1" has shared file "lorem.txt" with group "grp1"
    And user "user2" has accepted the share "lorem.txt" offered by user "user1"
    When the user opens the share dialog for file "lorem.txt" using the webUI
    Then group "grp1" should be listed as "Editor" in the collaborators list on the webUI
    When the user deletes "grp1" as collaborator for the current file using the webUI
    Then group "grp1" should not be listed in the collaborators list on the webUI
    And file "lorem.txt" should not be listed in shared-with-others page on the webUI
    And as "user2" file "/Shares/lorem.txt" should not exist
    And as "user2" file "lorem (2).txt" should not exist

  Scenario: user shares the file/folder with multiple internal users and delete the share with one user
    Given group "grp2" has been created
    And user "user3" has been added to group "grp2"
    And user "user1" has logged in using the webUI
    And user "user1" has shared file "lorem.txt" with group "grp1"
    And user "user2" has accepted the share "lorem.txt" offered by user "user1"
    And user "user1" has shared file "lorem.txt" with group "grp2"
    And user "user3" has accepted the share "lorem.txt" offered by user "user1"
    When the user opens the share dialog for file "lorem.txt" using the webUI
    Then group "grp1" should be listed as "Editor" in the collaborators list on the webUI
    And group "grp2" should be listed as "Editor" in the collaborators list on the webUI
    When the user deletes "grp1" as collaborator for the current file using the webUI
    Then group "grp1" should not be listed in the collaborators list on the webUI
    And group "grp2" should be listed as "Editor" in the collaborators list on the webUI
    And file "lorem.txt" should be listed in shared-with-others page on the webUI
    And as "user2" file "/Shares/lorem.txt" should not exist
    But as "user3" file "/Shares/lorem.txt" should exist

  Scenario: Auto-completion for a group that is excluded from receiving shares
    Given group "system-group" has been created
    And the administrator has excluded group "system-group" from receiving shares
    When the user re-logs in as "user1" using the webUI
    And the user browses to the files page
    And the user opens the share dialog for folder "simple-folder" using the webUI
    And the user opens the share creation dialog in the webUI
    And the user types "system-group" in the share-with-field
    Then the autocomplete list should not be displayed on the webUI

  @issue-2060
  Scenario: sharing indicator of items inside a shared folder two levels down
    Given user "user1" has uploaded file with content "test" to "/simple-folder/lorem.txt"
    And user "user1" has uploaded file with content "test" to "/simple-folder/simple-empty-folder/inside.txt"
    And user "user1" has shared folder "simple-folder" with group "grp1"
    And user "user2" has accepted the share "simple-folder" offered by user "user1"
    When user "user1" has logged in using the webUI
    Then the following resources should have share indicators on the webUI
      | fileName            | expectedIndicators |
      | simple-folder       | user-direct        |
    When the user opens folder "simple-folder" using the webUI
    Then the following resources should have share indicators on the webUI
      | fileName            | expectedIndicators |
      | simple-empty-folder | user-indirect      |
      | lorem.txt           | user-indirect      |
    When the user opens folder "simple-empty-folder" using the webUI
    Then the following resources should have share indicators on the webUI
      | fileName            | expectedIndicators |
      | inside.txt          | user-indirect      |

  @issue-2060
  Scenario: sharing indicator of items inside a re-shared folder
    Given user "user1" has shared folder "simple-folder" with user "user2"
    And user "user2" has accepted the share "simple-folder" offered by user "user1"
    And user "user2" has shared folder "Shares/simple-folder" with group "grp1"
    When user "user2" has logged in using the webUI
    And the user opens folder "Shares" using the webUI
    Then the following resources should have share indicators on the webUI
      | fileName            | expectedIndicators |
      | simple-folder   | user-direct        |
    And the user opens folder "simple-folder" using the webUI
    And the following resources should have share indicators on the webUI
      | fileName            | expectedIndicators |
      | simple-empty-folder | user-indirect      |
      | lorem.txt           | user-indirect      |

  @issue-2060
  Scenario: sharing indicator of items inside a re-shared subfolder
    Given user "user1" has shared folder "simple-folder" with user "user2"
    And user "user2" has accepted the share "simple-folder" offered by user "user1"
    And user "user2" has shared folder "/Shares/simple-folder/simple-empty-folder" with group "grp1"
    When user "user2" has logged in using the webUI
    And the user opens folder "Shares" using the webUI
    Then the following resources should have share indicators on the webUI
      | fileName            | expectedIndicators |
      | simple-folder   | user-indirect      |
    When the user opens folder "simple-folder" using the webUI
    Then the following resources should have share indicators on the webUI
      | fileName            | expectedIndicators |
      | simple-empty-folder | user-direct        |
      | lorem.txt           | user-indirect      |

  @issue-2060
  Scenario: sharing indicator of items inside an incoming shared folder
    Given user "user1" has shared folder "simple-folder" with group "grp1"
    And user "user2" has accepted the share "simple-folder" offered by user "user1"
    When user "user2" has logged in using the webUI
    And the user opens folder "Shares" using the webUI
    Then the following resources should have share indicators on the webUI
      | fileName            | expectedIndicators |
      | simple-folder   | user-indirect      |
    When the user opens folder "simple-folder" using the webUI
    Then the following resources should have share indicators on the webUI
      | fileName            | expectedIndicators |
      | simple-empty-folder | user-indirect      |
      | lorem.txt           | user-indirect      |

  @issue-2060
  Scenario: no sharing indicator of items inside a not shared folder
    Given user "user1" has shared file "/textfile0.txt" with group "grp1"
    And user "user2" has accepted the share "textfile0.txt" offered by user "user1"
    When user "user2" has logged in using the webUI
    Then the following resources should not have share indicators on the webUI
      | simple-folder       |
    When the user opens folder "simple-folder" using the webUI
    Then the following resources should not have share indicators on the webUI
      | simple-empty-folder |
      | lorem.txt           |

  @issue-2060
  Scenario: sharing indicator for file uploaded inside a shared folder
    Given user "user1" has shared folder "/simple-empty-folder" with group "grp1"
    And user "user1" has logged in using the webUI
    When the user opens folder "simple-empty-folder" using the webUI
    And the user uploads file "new-lorem.txt" using the webUI
    Then the following resources should have share indicators on the webUI
      | fileName      | expectedIndicators |
      | new-lorem.txt | user-indirect      |

  @issue-2060
  Scenario: sharing indicator for folder created inside a shared folder
    Given user "user1" has shared folder "/simple-empty-folder" with group "grp1"
    And user "user1" has logged in using the webUI
    When the user opens folder "simple-empty-folder" using the webUI
    And the user creates a folder with the name "sub-folder" using the webUI
    Then the following resources should have share indicators on the webUI
      | fileName      | expectedIndicators |
      | sub-folder    | user-indirect      |

  @issue-2939
  Scenario: sharing indicator for group shares stays up to date
    Given these groups have been created:
      | groupname |
      | grp2      |
      | grp3      |
      | grp4      |
    When user "user1" has logged in using the webUI
    Then the following resources should not have share indicators on the webUI
      | simple-folder |
    When the user shares folder "simple-folder" with group "grp2" as "Viewer" using the webUI
    And the user shares folder "simple-folder" with group "grp3" as "Viewer" using the webUI
    Then the following resources should have share indicators on the webUI
      | fileName      | expectedIndicators |
      | simple-folder | user-direct        |
    When the user opens folder "simple-folder" using the webUI
    Then the following resources should have share indicators on the webUI
      | fileName      | expectedIndicators |
      | testimage.png | user-indirect      |
    When the user shares file "testimage.png" with group "grp4" as "Viewer" using the webUI
    # the indicator changes from user-indirect to user-direct to show the direct share
    Then the following resources should have share indicators on the webUI
      | fileName      | expectedIndicators |
      | testimage.png | user-direct        |
    # removing the last collaborator reverts the indicator to user-indirect
    When the user deletes "grp4" as collaborator for the current file using the webUI
    Then the following resources should have share indicators on the webUI
      | fileName      | expectedIndicators |
      | testimage.png | user-indirect      |
    When the user opens folder "" directly on the webUI
    And the user opens the share dialog for folder "simple-folder" using the webUI
    And the user deletes "grp3" as collaborator for the current file using the webUI
    # because there is still another share left, the indicator stays
    Then the following resources should have share indicators on the webUI
      | fileName      | expectedIndicators |
      | simple-folder | user-direct        |
    # deleting the last collaborator removes the indicator
    When the user deletes "grp2" as collaborator for the current file using the webUI
    Then the following resources should not have share indicators on the webUI
      | simple-folder |

  @issue-2897
  Scenario: sharing details of items inside a shared folder shared with user and group
    Given user "user3" has created folder "/simple-folder/sub-folder"
    And user "user3" has uploaded file with content "test" to "/simple-folder/sub-folder/lorem.txt"
    And user "user3" has shared folder "simple-folder" with user "user2"
    And user "user2" has accepted the share "simple-folder" offered by user "user3"
    And user "user3" has shared folder "/simple-folder/sub-folder" with group "grp1"
    And user "user1" has accepted the share "simple-folder/sub-folder" offered by user "user3"
    And user "user2" has accepted the share "simple-folder/sub-folder" offered by user "user3"
    And user "user3" has logged in using the webUI
    When the user opens folder "simple-folder/sub-folder" directly on the webUI
    And the user opens the share dialog for file "lorem.txt" using the webUI
    Then user "User Two" should be listed as "Editor" via "simple-folder" in the collaborators list on the webUI
    And group "grp1" should be listed as "Editor" via "sub-folder" in the collaborators list on the webUI

  @issue-2898
  Scenario: see resource owner of parent group shares in collaborators list
    Given user "user3" has been created with default attributes
    And user "user1" has shared folder "simple-folder" with group "grp1"
    And user "user2" has accepted the share "simple-folder" offered by user "user1"
    And user "user2" has shared folder "Shares/simple-folder" with user "user3"
    And user "user3" has accepted the share "simple-folder" offered by user "user2"
    And user "user3" has logged in using the webUI
    And the user opens folder "Shares" using the webUI
    And the user opens folder "simple-folder" using the webUI
    When the user opens the share dialog for folder "simple-empty-folder" using the webUI
    Then user "User One" should be listed as "Owner" reshared through "User Two" via "simple-folder" in the collaborators list on the webUI
    And the current collaborators list should have order "User One,User Three"

  Scenario: share a folder with other group and then it should be listed on Shared with Others page
    Given user "user1" has logged in using the webUI
    And user "user1" has shared folder "simple-folder" with user "user2"
    And user "user1" has shared folder "simple-folder" with group "grp1"
    When the user browses to the shared-with-others page
    Then the following resources should have the following collaborators
      | fileName            | expectedCollaborators |
      | simple-folder       | User Two, grp1        |

  Scenario: change existing expiration date of an existing share with another internal group
    Given user "user3" has created a new share with following settings
      | path            | lorem.txt  |
      | shareTypeString | group      |
      | shareWith       | grp1       |
      | expireDate      | +14        |
    And user "user1" has accepted the share "lorem.txt" offered by user "user3"
    And user "user2" has accepted the share "lorem.txt" offered by user "user3"
    And user "user3" has logged in using the webUI
    When the user edits the collaborator expiry date of "grp1" of file "lorem.txt" to "+7" days using the webUI
    Then user "user1" should have received a share with target "Shares/lorem.txt" and expiration date in 7 days
    And user "user2" should have received a share with target "Shares/lorem.txt" and expiration date in 7 days
    And user "user3" should have a share with these details:
      | field      | value      |
      | path       | /lorem.txt |
      | share_type | group      |
      | uid_owner  | user3      |
      | share_with | grp1       |
      | expiration | +7         |

  Scenario: share a resource with another internal group with default expiration date
    Given the setting "shareapi_default_expire_date_group_share" of app "core" has been set to "yes"
    And the setting "shareapi_expire_after_n_days_group_share" of app "core" has been set to "42"
    And user "user3" has logged in using the webUI
    When the user shares folder "lorem.txt" with group "grp1" as "Viewer" using the webUI
    And user "user1" accepts the share "lorem.txt" offered by user "user3" using the sharing API
    And user "user2" accepts the share "lorem.txt" offered by user "user3" using the sharing API
    Then user "user3" should have a share with these details:
      | field      | value              |
      | path       | /lorem.txt         |
      | share_type | group              |
      | uid_owner  | user3              |
      | share_with | grp1               |
      | expiration | +42                |
    And user "user1" should have received a share with target "Shares/lorem.txt" and expiration date in 42 days
    And user "user2" should have received a share with target "Shares/lorem.txt" and expiration date in 42 days

  Scenario Outline: share a resource with another internal group with expiration date beyond maximum enforced expiration date
    Given the setting "shareapi_default_expire_date_group_share" of app "core" has been set to "yes"
    And the setting "shareapi_enforce_expire_date_group_share" of app "core" has been set to "yes"
    And the setting "shareapi_expire_after_n_days_group_share" of app "core" has been set to "5"
    And user "user3" has logged in using the webUI
    When the user tries to share resource "<shared-resource>" with group "grp1" which expires in "+6" days using the webUI
    Then the expiration date shown on the webUI should be "+5" days
    And user "user1" should not have created any shares
    Examples:
      | shared-resource |
      | lorem.txt       |
      | simple-folder   |

  Scenario Outline: share a resource with another internal group with expiration date within maximum enforced expiration date
    Given the setting "shareapi_default_expire_date_group_share" of app "core" has been set to "yes"
    And the setting "shareapi_enforce_expire_date_group_share" of app "core" has been set to "yes"
    And the setting "shareapi_expire_after_n_days_group_share" of app "core" has been set to "5"
    And user "user3" has created a new share with following settings
      | path            | <shared-resource> |
      | shareTypeString | group             |
      | shareWith       | grp1              |
      | expireDate      | +4                |
    And user "user1" has accepted the share "<shared-resource>" offered by user "user3"
    And user "user2" has accepted the share "<shared-resource>" offered by user "user3"
    And user "user3" has logged in using the webUI
    When the user tries to edit the collaborator expiry date of "grp1" of resource "<shared-resource>" to "+7" days using the webUI
    Then the expiration date shown on the webUI should be "+4" days
    And it should not be possible to save the pending share on the webUI
    And user "user1" should have received a share with target "<target-resource>" and expiration date in 4 days
    And user "user2" should have received a share with target "<target-resource>" and expiration date in 4 days
    Examples:
      | shared-resource | target-resource   |
      | lorem.txt       | Shares/lorem.txt     |
      | simple-folder   | Shares/simple-folder |
