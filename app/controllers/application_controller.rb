class ApplicationController < ActionController::Base
  protect_from_forgery
  # Disable logfile
  ActiveRecord::Base.logger.level = 2
end
