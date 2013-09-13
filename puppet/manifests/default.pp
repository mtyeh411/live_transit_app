$ruby_version = '2.0.0-p247'
$project      = 'gtfs_realtime_viz'

$bash         = 'sudo -H bash -l -c'
$rvm          = '/usr/local/rvm'
$with_gemset  = "${rvm}/bin/rvm ${ruby_version}@${project} do"

Exec {
  path => ['/usr/sbin', '/usr/bin', '/sbin', '/bin']
}

# --- Preinstall stage ---
stage { 'preinstall':
  before =>  Stage['main']
}

class pkg_manager_update {
  exec { 'apt-get -y update':
    unless =>  "test -e ${rvm}"
  }
}

class { 'pkg_manager_update':
  stage => preinstall
}

# --- Dependency Packages ---
package { 'nodejs':
  ensure => installed
}
package { 'redis-server': 
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

include stdlib
file_line { 'trust_all_rvmrcs':
  path    => "/etc/rvmrc",
  line    => "rvm_trust_rvmrcs_flag=1",
  match   => "^rvm_trust_rvmrcs_flag=",
  require => File['/etc/rvmrc']
}
file { '/etc/rvmrc':
  ensure  => file
}

# --- Application configs and installs ---
exec { "install_gems":
 command  => "${with_gemset} bundle install",
 cwd      => '/vagrant',
 require  => Rvm_gem["ruby-${ruby_version}@${project}/bundler"]
}

exec { "update_cron":
  command   => "${bash} '${with_gemset} bundle exec whenever -i'",
  cwd       => '/vagrant',
  logoutput => true,
  require   => Exec['install_gems']
}

exec { "export_foreman":
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

service { "${project}":
  ensure    => running,
  provider  => 'upstart'
}
