When /^I wait ([\d.]+) second(?:s)?$/ do |seconds|
  seconds = seconds.to_f
  sleep( seconds )
end
