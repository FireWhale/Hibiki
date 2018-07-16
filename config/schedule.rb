# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
require 'yaml'

@secrets = YAML.load_file("#{File.dirname(__FILE__)}/secrets.yml")

every 3.hours do
  runner "WatchWorker.perform_async", :environment => 'development'
end

every 1.month, at: 'start of the month at 2 am' do
  command "mysqldump -u root -p#{@secrets["development"]["mysql_password"]} hibiki_development > /vagrant/mysqldumps/development/`date +%Y-%m-%d`_dev_dump.sql"
  command "mysqldump -u root -p#{@secrets["development"]["mysql_password"]} hibiki_production > /vagrant/mysqldumps/production/`date +%Y-%m-%d`_prd_dump.sql"
end