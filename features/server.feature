Feature: Server
  In order to let users play with their app as they create it
  I want to serve an app directly
 
  Scenario: Index Page
    Given a simple app
    When I GET the "/" page
    Then I should see an html page

  Scenario: Show Page
    Given a simple populated app
    When I GET the "/posts/1" page
    Then I should see an html page