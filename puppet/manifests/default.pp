$as_vagrant   = 'sudo -u vagrant -H bash -l -c'
$home         = '/home/vagrant'
$ruby_version = '2.0.0-p247'
$app          = 'gtfs_realtime_viz'
$with_gemset  = "${home}/.rvm/bin/rvm ${ruby_version}@${app} do"

Exec {
  path => ['/usr/sbin', '/usr/bin', '/sbin', '/bin']
}

# --- Preinstall stage ---
stage { 'preinstall':
  before =>  Stage['main']
}

class apt_get_update {
  exec { 'apt-get -y update':
    unless =>  "test -e ${home}/.rvm"
  }
}

class { 'apt_get_update':
  stage => preinstall
}

# --- Databases ---
package { ['sqlite3', 'libsqlite3-dev']:
  ensure => installed;
}

# --- Dependency Packages ---
package { 'curl':
  ensure => installed
}
package { 'build-essential':
  ensure => installed
}
package { 'git-core': 
  ensure => installed
}
package { ['libxml2', 'libxml2-dev', 'libxslt-dev']:
  ensure => installed
}

package { 'nodejs':
  ensure => installed
}
package { 'redis-server': 
  ensure => installed
}

# --- Ruby ---
exec { 'install_rvm':
  command => "${as_vagrant} 'curl -L https://get.rvm.io | bash -s stable'",
  creates => "${home}/.rvm/bin/rvm",
  require => Package['curl']
}

exec { 'install_ruby':
  command => "${as_vagrant} '${home}/.rvm/bin/rvm install ${ruby_version} --autolibs=enabled && rvm alias create default ${ruby_version}'",
  creates => "${home}/.rvm/bin/ruby",
  require => Exec['install_rvm']
}

exec { 'install_gemset':
  command => "${as_vagrant} 'rvm use ${ruby_version}@${app} --create'",
  creates => "${home}/.rvm/gems/ruby-${ruby_version}@${app}/",
  require => Exec['install_ruby']
}

exec { 'install_bundler':
  command => "${as_vagrant} 'gem install bundler --no-rdoc --no-ri'",
  creates => "${home}/.rvm/bin/bundle",
  require => Exec['install_gemset']
}

exec { "install_gems":
 command  => "${with_gemset} bundle install",
 cwd      => '/vagrant',
 require  => Exec['install_bundler']
}

# --- Application service monitoring ---
exec { "update_cron":
  command   => "${as_vagrant} '${with_gemset} bundle exec whenever -i'",
  cwd       => '/vagrant',
  logoutput => true,
  require   => Exec['install_gems']
}

exec { "export_foreman":
  command  => "${with_gemset} rvmsudo foreman export upstart /etc/init -a ${app} -u vagrant",
  cwd      => '/vagrant',
  creates  => "/etc/init/${app}.conf",
  require  => Exec['update_cron']
}

service { "${app}":
  ensure    => running,
  provider  => 'upstart',
  require   => Exec['export_foreman']
}
