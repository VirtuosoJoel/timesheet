# Load the rails application
require File.expand_path('../application', __FILE__)

# Set the time zone
Timesheet::Application.config.time_zone = 'London'

# Initialize the rails application
Timesheet::Application.initialize!