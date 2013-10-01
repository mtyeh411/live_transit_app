project = "gtfs_realtime_viz"

working_directory File.expand_path('..', Dir.pwd)
pid "/var/run/unicorn.pid"
stderr_path "/var/log/#{project}/unicorn.log"
stdout_path "/var/log/#{project}/unicorn.log"

listen "/var/run/#{project}.sock"
worker_processes 2
timeout 30
