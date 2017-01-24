class papertrail::install inherits papertrail {


  if !defined(Package['wget']) {
    package { ['wget']:
      ensure  => 'installed'
    }
  }

  if !defined(Package['rsyslog']) {
    package { ['rsyslog']:
      ensure  => 'installed'
    }
  }

  if !defined(Package['rsyslog-gnutls']) {
    package { ['rsyslog-gnutls']:
      ensure  => 'installed'
    }
  }

  $config_file = $papertrail::config_file_prio ? {
    undef   => '/etc/rsyslog.d/papertrail.conf',
    default => "/etc/rsyslog.d/${papertrail::config_file_prio}-papertrail.conf",
  }

  file { $config_file:
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('papertrail/etc/rsyslog.d/papertrail.conf.erb'),
    require => Package['rsyslog', 'rsyslog-gnutls'],
    notify  => Service['rsyslog'];
  }

  $rsyslog_user = $::operatingsystem ? {
    'Ubuntu'  => 'syslog',
    default   => 'root',
  }

  file { $papertrail::cert:
    ensure  => 'present',
    replace => 'no',
    owner   => $rsyslog_user,
    group   => 'root',
    mode    => '0660',
    require => [
      File[$config_file],
      Exec['get_certificates']
    ];
  }

  exec { 'get_certificates':
    path    => '/bin/:/usr/bin/:/usr/local/bin/',
    command => "wget ${papertrail::cert_url} -O ${papertrail::cert}",
    creates => $papertrail::cert
  }
}
