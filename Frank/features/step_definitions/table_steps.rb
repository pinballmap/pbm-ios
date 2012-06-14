Then /^I should see a table containing the following:$/ do |table|
  table.raw.each do |row|
    expected_mark = row.first
    check_element_exists( "tableView view marked:'#{expected_mark}'" )
  end
end

Then /^I should see a table containing "([^\"]*)"$/ do |expected_mark|
  check_element_exists( "tableView view marked:'#{expected_mark}'" )
end
