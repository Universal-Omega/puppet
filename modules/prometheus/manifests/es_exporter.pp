class prometheus::es_exporter {
    package { 'prometheus-es-exporter':
        ensure => present,
    }

    file { '/etc/prometheus-es-exporter':
        ensure  => directory,
        recurse => true,
        purge   => true,
        force   => true,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        source  => 'puppet:///modules/prometheus/es_exporter',
        require => Package['prometheus-es-exporter'],
        notify  => Service['prometheus-es-exporter'],
    }

    systemd::service { 'prometheus-es-exporter':
        ensure   => present,
        content  => systemd_template('prometheus-es-exporter'),
        override => true,
        restart  => true,
    }
}
