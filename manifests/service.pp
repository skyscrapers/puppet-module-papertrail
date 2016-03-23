class papertrail::service {

  if !defined(Service['rsyslog']) {
    service { 'rsyslog':
      ensure      => running,
      hasstatus   => true,
      hasrestart  => true,
      enable      => true,
      require     => Class['papertrail::install'];
    }
  }
}
