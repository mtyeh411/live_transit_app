set :application, "gtfs_realtime_viz"
set :deploy_to, "/var/www/#{application}"
set :user, 'ubuntu'

set :scm, :git
set :repository,  "git://github.com/mtyeh411/live_transit_app.git"

set :keep_releases, 2
set :rails_env, 'production'

# Replace below with info relevant to your server
server "50.19.224.217", :web, :app, :primary => true
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

set :whenever_command, "rvmsudo bundle exec whenever"
#require 'whenever/capistrano'

namespace :deploy do
  task :start do ; end
  task :stop do ; end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} start #{application} || #{try_sudo} restart #{application}"
  end
end

namespace :dbyml do
  desc "symlink database.yml from shared"
  task :symlink, :roles => :app do
    run "ln -s #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
  end

  desc "upload to shared"
  task :upload, :roles => :app do
    top.upload("config/database.yml", "#{shared_path}/config/database.yml")
  end
end

namespace :node do
  desc "install dependencies"
  task :deps do
    run "cd #{latest_release}/node && #{try_sudo} npm install"
  end
end

namespace :nginx do
  desc "start or restart nginx"
  task :restart, :roles => :app do
    run "#{try_sudo} service nginx start || #{try_sudo} service nginx restart"
  end

  desc "stop nginx"
  task :stop, :roles => :app do
    run "#{try_sudo} service nginx stop"
  end
end

namespace :redis do
  desc "start or restart redis"
  task :restart, :roles => :app do
    run "#{try_sudo} service redis-server start || #{try_sudo} service redis-server restart"
  end

  desc "stop redis"
  task :stop, :roles => :app do
    run "#{try_sudo} service redis-server stop"
  end
end

namespace :whenever do
  desc "update cron via whenever"
  task :update do
    run "cd #{latest_release} && #{whenever_command} -i"
  end

  desc "remove cron via whenever"
  task :remove do
    run "cd #{latest_release} && #{whenever_command} -c"
  end
end

before "deploy:cold", "dbyml:upload"

before "deploy:assets:precompile", "dbyml:symlink"

before "deploy:create_symlink", "node:deps"

after "deploy:update", "foreman:export"
after "deploy:update", "foreman:restart"
after "deploy:update", "whenever:update"

after "deploy:restart", "nginx:restart"
after "deploy:restart", "redis:restart"
after "deploy:restart", "deploy:cleanup"
