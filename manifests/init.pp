# == Class: redis
#
# Install and configure redis
#
# === Parameters
#
# [*redis_port*]
#   Set the port redis will listen to
#   Default: 6379
#
# [*redis_max_memory*]
#   Set the redis config value maxmemory (bytes).
#   Default: 4gb
#
# [*redis_max_clients*]
#   Set the redis config value maxclients.
#   Default: 0
#
# [*redis_timeout*]
#   Set the redis config value timeout (seconds).
#   Default: 300
#
# [*redis_loglevel*]
#   Set the redis config value loglevel. Valid values are debug,
#   verbose, notice, and warning.
#   Default: notice
#
# [*redis_slaveof*]
#   Configure the redis server to be a slave of another
#   If this variable is set to anything other than "", it will result in a config entry
#   The value should be of the format "<MASTER_IP> <MASTER_PORT>"
#   Default: ""
#
# [*redis_databases*]
#   Set the redis config value databases.
#   Default: 16
#
# [*redis_slowlog_log_slower_than*]
#   Set the redis config value slowlog-log-slower-than (microseconds).
#   Default: 10000
#
# [*redis_slowlog_max_len*]
#   Set the redis config value slowlog-max-len.
#   Default: 1024
#
# === Examples
#
# include redis
#
# === Authors
#
# Matt Chesler (matt@zipmark.com)
#
class redis (
  $redis_port                    = '6379',
  $redis_max_memory              = '4gb',
  $redis_max_clients             = 0, # 0 = unlimited
  $redis_timeout                 = 300,
  $redis_loglevel                = 'notice',
  $redis_slaveof                 = "",
  $redis_databases               = 16,
  $redis_slowlog_log_slower_than = 10000, # microseconds
  $redis_slowlog_max_len         = 1024,
) {

  case $::osfamily {
    redhat: {
      $package_name = 'redis'
      $service_name = 'redis'
      $conf_path    = '/etc'
      $conf_file    = 'redis.conf'
    }
    default: { fail("Unsupported operating system for redis class") }
  }

  package { 'redis':
    name   => $package_name,
    ensure => installed,
  }

  service { 'redis':
    name      => $service_name,
    ensure    => running,
    enable    => true,
    subscribe => File['redis.conf'],
  }

  file { '/var/lib/redis':
    ensure  => directory,
    mode    => '0644',
    require => Package['redis'],
  }

  file { 'redis.conf':
    ensure  => present,
    path    => "${conf_path}/${conf_file}",
    mode    => '0644',
    content => template("redis/${conf_file}.erb"),
    require => Package['redis']
  }
}
