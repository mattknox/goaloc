Feature: Definition
  In order to help users
  As a user of the goaloc repl
  I want to define a skeleton app
 
  Scenario: Defining routes
    Given a new app
    When I call "route [:posts, :comments]"
    Then the app should have a Post and a Comment model
