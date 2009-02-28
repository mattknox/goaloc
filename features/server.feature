Feature: Server
  In order to let users play with their app as they create it
  I want to serve an app directly
 
  Scenario: Index Page
    Given a simple app
    When I GET the "/" page
    Then I should see an html page

  Scenario: New Page
    Given a simple app
    When I GET the "/posts/new" page
    Then I should see an html page

  Scenario: Create Post
    Given a simple populated app
    When I POST to "/posts/"
    Then I should be redirected to an html page

  Scenario: Show Page
    Given a simple populated app
    When I GET the "/posts/1" page
    Then I should see an html page

  Scenario: Edit Page
    Given a simple populated app
    When I GET the "/posts/1/edit" page
    Then I should see an html page

  Scenario: Update Post
    Given a simple populated app
    When I PUT to "/posts/1"
    Then I should be redirected to an html page

  Scenario: Destroy Post
    Given a simple populated app
    When I DELETE to "/posts/1"
    Then I should be redirected to an html page

  Scenario: Nested Index Page
    Given a populated nested app
    When I GET the "/posts/1/comments" page
    Then I should see an html page