$ruby_version = '2.0.0-p247'
$project      = 'gtfs_realtime_viz'

$bash         = 'sudo -H bash -l -c'
$rvm          = '/usr/local/rvm'
$with_gemset  = "${rvm}/bin/rvm ${ruby_version}@${project} do"

Exec {
  path => ['/usr/sbin', '/usr/bin', '/sbin', '/bin']
}

# --- Databases ---
include postgresql::server

# --- Node ---
package { 'nodejs':
  ensure => installed
}

# --- Redis ---
class { 'redis': }

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

include stdlib
file_line { 'trust_all_rvmrcs':
  path    => "/etc/rvmrc",
  line    => 'rvm_trust_rvmrcs_flag=1',
  match   => '^rvm_trust_rvmrcs_flag=',
  require => File['/etc/rvmrc']
}
file { '/etc/rvmrc':
  ensure  => file
}

# --- Application configs and installs ---
exec { 'install_gems':
 command  => "${with_gemset} bundle install",
 cwd      => '/vagrant',
 require  => Rvm_gem["ruby-${ruby_version}@${project}/bundler"]
}

exec { 'update_cron':
  command   => "${bash} '${with_gemset} bundle exec whenever -i'",
  cwd       => '/vagrant',
  logoutput => true,
  require   => Exec['install_gems']
}

exec { 'export_foreman':
  command  => "${bash} '${with_gemset} rvmsudo foreman export upstart /etc/init -a ${project} -u root'",
  cwd      => '/vagrant',
  creates  => "/etc/init/${project}.conf",
  require  => Exec['update_cron']
}

# --- Application service monitoring ---
file { "/etc/init/${project}.conf":
  ensure  => file,
  require => Exec['export_foreman'],
  notify  => Service["${project}"]
}

service { $project:
  ensure    => running,
  provider  => 'upstart'
}

# --- Logfile management ---
class { 'logrotate': }

logrotate::rule { $project:
  path          => "/var/log/${project}/*.log",
  rotate        => 3,
  size          => '100k',
  create        => true,
  create_mode   => 0600,
  create_owner  => root,
  create_group  => root,
  shred         => true,
  compress      => true,
  ifempty       => false,
}

cron { 'logrotate':
  ensure  => absent,
  command => '/usr/sbin/logrotate',
  user    => root,
  minute  => '*/5',
}
