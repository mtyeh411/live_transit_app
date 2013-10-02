set :application, "gtfs_realtime_viz"
set :deploy_to, "/var/www/#{application}"
set :user, 'ubuntu'

set :scm, :git
set :repository,  "git://github.com/mtyeh411/live_transit_app.git"

# Replace below with info relevant to your server
server "107.20.200.72", :web, :app, :primary => true
ssh_options[:keys] = "~/proj/ec2_keypairs/rideon/ride-ontime.com/ride-ontime.com.pem"

require 'bundler/capistrano' 
set :bundle_flags, "--deployment --quiet --binstubs"

require 'rvm/capistrano' 
set :rvm_ruby_string, 'ruby-2.0.0-p247@gtfs_realtime_viz'
set :rvm_type, :system

require 'capistrano/foreman'
set :foreman_sudo, 'rvmsudo'
set :foreman_upstart_path, '/etc/init'
set :foreman_options, {
  app: application,
  user: user,
  log: "#{shared_path}/log",
}

set :keep_releases, 2
set :rails_env, 'production'

namespace :deploy do
  task :start do ; end
  task :stop do ; end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} start #{application} || #{try_sudo} restart #{application}"
  end

  desc "use shared database.yml with latest release"
  task :database_yml, :roles => :app do
    run "cp #{shared_path}/config/database.yml #{latest_release}/config/"
  end

  desc "install node dependencies"
  task :npm_install, :roles => :app do
    run "cd #{latest_release}/node && #{try_sudo} npm install"
  end
end

namespace :redis do
  desc "start redis"
  task :start, :roles => :app do
    run "sudo redis-server /etc/redis/redis.conf"
  end

  desc "stop redis"
  task :stop, :roles => :app do
    run "sudo kill -INT `cat /var/run/redis/redis-server.pid`"
  end
end

before "deploy:assets:precompile", "deploy:database_yml"
before "deploy:create_symlink", "deploy:npm_install"

after "deploy:update", "redis:start"
after "deploy:update", "foreman:export"
after "deploy:update", "foreman:restart"

after "deploy:restart", "deploy:cleanup"
