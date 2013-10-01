require 'bundler/capistrano'  # include bundler capistrano tasks

set :application, "gtfs_realtime_viz"

set :scm, :git
set :repository,  "git://github.com/mtyeh411/live_transit_app.git"

server "107.20.200.72", :web, :app, :primary => true

set :keep_releases, 2

ssh_options[:keys] = [
  File.join(
    ENV["HOME"],
    "proj",
    "ec2_keypairs",
    "rideon",
    "ride-ontime.com",
    "ride-ontime.com.pem"
  )
]

namespace :deploy do
  task :start do ; end
  task :stop do ; end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} start #{application} || #{try_sudo} restart #{application}"
  end

  desc "use shared database.yml file with latest release"
  task :database_yml, :roles => :app do
    run "ln -s #{shared_path}/config/database.yml #{current_path}/config/database.yml"
  end
end

namespace :foreman do
  desc "export Procfile to upstart script"
  task :export, :roles => :app do
    run "cd /var/www/#{application} && /usr/local/rvm/bin/rvm 2.0.0-p247@#{application} do rvmsudo foreman export upstart /etc/init -a #{application} -u root" 
  end

  desc "start/restart application services"
  task :restart, :roles => :app do
    run "#{try_sudo} start #{application} || #{try_sudo} restart #{application}"
  end
end

before "deploy:assets:precompile", "deploy:database_yml"
after "deploy:update", "foreman:export"
after "deploy:update", "foreman:restart"
after "deploy:restart", "deploy:cleanup"
