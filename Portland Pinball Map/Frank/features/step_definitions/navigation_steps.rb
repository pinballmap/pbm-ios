Given /^I am on the main menu$/ do
  launch_app app_path
  sleep(5)
end

Then /^I should see the main menu$/ do
  check_element_exists( "tableView view marked:'Locations'" )
  check_element_exists( "tableView view marked:'Machines'" )
  check_element_exists( "tableView view marked:'Closest Locations'" )
  check_element_exists( "tableView view marked:'Recently Added'" )
  check_element_exists( "tableView view marked:'Events'" )
  check_element_exists( "tableView view marked:'Change Region'" )
end

Then /^I should be on a machine locations screen$/ do
  check_element_exists( "tableView view marked:'mi'" )
end

Then /^I should be on a machine detail screen$/ do
  check_element_exists( "tableView view marked:'Map'" )
  check_element_exists( "tableView view marked:'Add Machine'" )
  check_element_exists( "tableView view marked:'Location'" )
  check_element_exists( "tableView view marked:'Machines'" )
end

Then /^I should be on an event detail screen$/ do
  check_view_with_mark_exists("View on Web")
  check_view_with_mark_exists("View Location")
  check_element_exists( "navigationItemView marked:'Events'" )
end
