Feature: Account
  In order to have returning users
  As a community member
  I want to manage my own account
 
  Scenario: Successful change of personal info
    Given an "active" site_user named "Aslak" exists
    And I am logged in as "Aslak"
    When I view the account page
    And I fill in "newaddr@new.com" for "Email"
    And I press "Save"
    Then "Aslak"'s Email should be "newaddr@new.com"
    And I should see "Your account has been updated"



make this a real, working feature.