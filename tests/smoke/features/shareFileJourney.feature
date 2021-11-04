Feature: share folder with file
Alice shares folder with file to Brian with role "editor".
I want to check that Brian can accept folder, download, move, copy and rename shared file

Background:
  Given following users have been created
    | Alice |
    | Brian |
  And admin set the default folder for received shares to "Shares"
  And admin disables auto accepting

Scenario: Alice shares folder with file to Brian
  Given "Alice" has logged in
  When "Alice" opens the "files" app
  And "Alice" navigates to the files page
  And "Alice" creates following folders
    | folder_to_shared |
  And "Alice" uploads following resources
    | resource  | to               |
    | lorem.txt | folder_to_shared | 
  Then "Alice" checks whether the following resources exist
    | folder_to_shared/lorem.txt |
  And "Alice" shares following resources
    | resource         | user  | role   |
    | folder_to_shared | Brian | editor |
  Given "Brian" has logged in
  When "Brian" opens the "files" app
  And "Brian" accepts following resources
    | folder_to_shared |
  And "Brian" renames following resource
    | resource                          | as            |
    | Shares/folder_to_shared/lorem.txt | lorem_new.txt |
  And "Brian" uploads following resources
    | resource   | to                      |
    | simple.pdf | Shares/folder_to_shared | 
  And "Brian" copies following resources
    | resource                 | to        |
    | Shares/folder_to_shared  | All files |
  And "Brian" has logged out
  When "Alice" opens the "files" app
  Then "Alice" checks whether the following resources exist
    | folder_to_shared/lorem_new.txt |
    | folder_to_shared/simple.pdf    |
  When "Alice" creates new versions of the folowing files
    | resource   | to               |
    | simple.pdf | folder_to_shared |   
  Then "Alice" checks that new version exists
    | folder_to_shared/simple.pdf |
  When "Alice" removes following resources
    | folder_to_shared/lorem_new.txt |
    | folder_to_shared               |
  Given "Brian" has logged in
  When "Brian" opens the "files" app
  Then "Brian" checks whether the following resource not exist
    | Shares/folder_to_shared |
  

  Scenario: Alice shares file to Brian
  Given "Alice" has logged in
  When "Alice" opens the "files" app
  And "Alice" creates following folders
    | folder_to_shared |
  And "Alice" uploads following resources
    | resource        | to               |
    | testavatar.jpeg | folder_to_shared | 
  And "Alice" shares following resources using main menu
    | resource                         | user  | role   |
    | folder_to_shared/testavatar.jpeg | Brian | viewer |
  Given "Brian" has logged in
  When "Brian" opens the "files" app
  And "Brian" accepts following resources
    | testavatar.jpeg |
  And "Brian" copies following resources
    | resource               | to        |
    | Shares/testavatar.jpeg | All files |
  And "Brian" opens file in Mediaviewer
    | Shares/testavatar.jpeg |
  And "Brian" downloads following files
    | resource        | from   |
    | testavatar.jpeg | Shares |
  And "Brian" has logged out
  When "Alice" opens the "files" app
  And "Alice" changes role for the following shared resources  
    | resource                         | user  | role   |
    | folder_to_shared/testavatar.jpeg | Brian | editor |
  Given "Brian" has logged in
  When "Brian" opens the "files" app
  And "Brian" renames following resource
    | resource               | as                  |
    | Shares/testavatar.jpeg | testavatar_new.jpeg |
  And "Brian" has logged out
  When "Alice" opens the "files" app
  And "Alice" removes shares to the following resources  
    | resource                         | user  |
    | folder_to_shared/testavatar.jpeg | Brian |
  Given "Brian" has logged in
  When "Brian" opens the "files" app
  Then "Brian" checks whether the following resource not exist
    | Shares/testavatar_new.jpeg |
    