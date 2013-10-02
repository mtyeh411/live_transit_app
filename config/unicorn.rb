if ENV['RAILS_ENV']=='production'
  working_directory "/var/www/gtfs_realtime_viz/current"
  pid "/var/www/gtfs_realtime_viz/current/tmp/pids/unicorn.pid"
  stderr_path "/var/www/gtfs_realtime_viz/current/log/unicorn.log"
  stdout_path "/var/www/gtfs_realtime_viz/current/log/unicorn.log"

  listen "/var/www/gtfs_realtime_viz/current/tmp/unicorn.sock"
  worker_processes 2
  timeout 30
#else 
#  working_directory "/Users/myeh/Projects/mc_trn/gtfs_realtime_map"
#  pid "/Users/myeh/Projects/mc_trn/gtfs_realtime_map/tmp/pids/unicorn.pid"
#  stderr_path "/Users/myeh/Projects/mc_trn/gtfs_realtime_map/log/unicorn.log"
#  stdout_path "/Users/myeh/Projects/mc_trn/gtfs_realtime_map/log/unicorn.log"
#
#  listen "/Users/myeh/Projects/mc_trn/gtfs_realtime_map/tmp/unicorn.sock"
#  worker_processes 2
#  timeout 30
end
