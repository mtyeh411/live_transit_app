$deploy_path  = "/var/www"
$project      = 'gtfs_realtime_viz'

$ruby_version = '2.0.0-p247'
$rvm          = '/usr/local/rvm'
$with_gemset  = "${rvm}/bin/rvm ${ruby_version}@${project} do"

$bash         = 'sudo -H bash -l -c'

Exec {
  path => ['/usr/sbin', '/usr/bin', '/sbin', '/bin']
}

file { $deploy_path:
  ensure  => "directory",
  owner   => 'www-data',
  group   => 'www-data',
  mode    => 775
}

# --- Datastores ---
package { 'libpq-dev': 
  ensure => installed
}
class { 'redis': }

# --- Node ---
package { 'nodejs':
  ensure => installed
}
package { 'npm':
  ensure => installed
}

# --- Ruby ---
include rvm

rvm_system_ruby { "ruby-${ruby_version}":
  ensure      => 'present',
  default_use => true,
}

rvm_gemset { "ruby-${ruby_version}@${project}":
  ensure  => present,
  require => Rvm_system_ruby["ruby-${ruby_version}"],
}

rvm_gem { "ruby-${ruby_version}@${project}/bundler":
  ensure  => latest,
  require => Rvm_gemset["ruby-${ruby_version}@${project}"]
}

file_line { 'trust_all_rvmrcs':
  path    => "/etc/rvmrc",
  line    => 'rvm_trust_rvmrcs_flag=1',
  match   => '^rvm_trust_rvmrcs_flag=',
  require => File['/etc/rvmrc']
}

file { '/etc/rvmrc':
  ensure  => file
}

# -- Application server --
class { 'nginx': }

package { 'ssl-cert':
  ensure  => 'installed'
}

nginx::unicorn { $project: 
  unicorn_socket  => "${deploy_path}/${project}/current/tmp/unicorn.sock",
  isdefaultvhost  => true,
  magic           => "
    location ~ ^/assets/ {
      root ${deploy_path}/${project}/current/public;
      add_header Last-Modified "";
      add_header ETag "";
      gzip_static on;
      expires max;
      add_header Cache-Control public;
    }"
}

# -- Logfile management --
class { 'logrotate': }

logrotate::rule { $project:
  path          => "${deploy_path}/${project}/shared/log/*.log",
  rotate        => 3,
  size          => '100k',
  create        => true,
  create_mode   => 0600,
  create_owner  => 'deployer',
  create_group  => 'www-data',
  shred         => true,
  compress      => true,
  ifempty       => false,
  require       => File["${deploy_path}/${project}/shared/log"]
}

cron { 'logrotate':
  ensure  => absent,
  command => '/usr/sbin/logrotate',
  user    => root,
  minute  => '*/5',
}

# -- Capistrano file directory --
group { 'deployers':
  ensure  => present
}

user { 'ubuntu':
  ensure  => present,
  group   => 'deployers',
  require => Group['deployers']
}

user { 'www-data':
  ensure  => present,
  group   => 'deployers',
  require => Class['nginx']
}

file {
  [ "${deploy_path}/${project}",
    "${deploy_path}/${project}/shared",
    "${deploy_path}/${project}/shared/config",
    "${deploy_path}/${project}/shared/pids",
    "${deploy_path}/${project}/shared/log",
  ]:
  ensure  => "directory",
  owner   => 'ubuntu',
  group   => 'deployers',
  mode    => 774,
  require => User['ubuntu']
}
