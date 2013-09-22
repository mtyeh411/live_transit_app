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
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, "#{path}/log/cron.log"
#set :environment, "development"

every 1.minutes do
  MCRO_API_KEY = 'm2Hu4MYrS6qAFbB3NqXJ7ss95BGs1AB2sxzqwxBzU3GBDwunkduENArr'
  MCRO_ENDPOINT = "http://rideonrealtime.net/gtfs_realtime?auth_token=#{MCRO_API_KEY}"
  runner "GtfsrParser.perform_async('#{MCRO_ENDPOINT}', 'MCRO')"
end

every 1.day, :at=>'2 am' do
  runner "TripDayPublisher.perform"
end
