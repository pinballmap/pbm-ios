Feature: 
  As an iOS developer
  I want to make sure that the app can be navigated correctly
  So that the app is usable

Scenario: lands on main menu after loading
Given I launch the app
And I wait 3 seconds
Then I should see a navigation bar titled "bayarea Pinball Map"
And I should see the main menu

Scenario: navigate to locations
Given I am on the main menu
And I touch the 6th table cell
Then I should see a navigation bar titled "Location"
And I should see a table containing "Filter by"
And I should see a table containing "All"
And I should see a table containing "4+ Machines"
And I should see a table containing "< 1 mile"
And I should see a table containing "bayarea"
And I should see a table containing "Suburbs"
Given I wait 1 seconds
And I touch "Back"
Then I should see the main menu

Scenario: navigate location submenus
Given I am on the main menu
And I touch the 6th table cell
And I wait 1 seconds
And I touch "All"
Then I should see a navigation bar titled "All Locations"
And I should see "Map"
Given I touch "Map"
Then I should see an element of class "MKMapView"
Given I touch "Back"
And I touch the first table cell
And I wait 1 seconds
Then I should be on a machine detail screen
Given I touch "Map"
Then I should see an element of class "MKMapView"
And I should see "Google Map"
Given I touch "Back"
And I touch "Add Machine"
Then I should see "Select a Machine"
And I should see a navigation bar titled "Add Machine"
And I should see "Add"
Given I touch "Back"
And I touch the first table cell
Then I should see "Comments:"
And I should see "Edit"
And I should see "ipdb.org"
And I should see "Other Locations"
And I should see "Edit Comment"

Scenario: navigate to machines
Given I am on the main menu
And I touch "Machines"
Then I should see a navigation bar titled "Machine"
Given I touch "Back"
Then I should see the main menu

Scenario: navigate machines submenus
Given I am on the main menu
And I touch "Machines"
And I touch the first table cell
And I wait 1 seconds
Then I should be on a machine locations screen
Given I touch the first table cell
And I wait 1 seconds
Then I should be on a machine detail screen

Scenario: navigate to closest locations
Given I am on the main menu
And I touch "Closest Locations"
Then I should see a navigation bar titled "Closest Locations"
And I should see a table containing "< 1 mile"
Given I touch "Back"
Then I should see the main menu

Scenario: navigate closest locations submenus
Given I am on the main menu
And I touch "Closest Locations"
And I touch the first table cell
And I wait 1 seconds
Then I should be on a machine detail screen

Scenario: navigate to recently added
Given I am on the main menu
And I touch "Recently Added"
Then I should see a navigation bar titled "Recently Added"
Given I touch "Back"
Then I should see the main menu

Scenario: navigate to events
Given I am on the main menu
And I touch "Events"
Then I should see a navigation bar titled "Events"
Given I touch "Back"
Then I should see the main menu

Scenario: navigate events submenus
Given I am on the main menu
And I touch "Events"
And I touch the first table cell
And I wait for 1 seconds
Then I should be on an event detail screen

Scenario: navigate to change region
Given I am on the main menu
And I touch "Change Region"
Then I should see a navigation bar titled "Change Region"
Given I touch "Back"
Then I should see the main menu
