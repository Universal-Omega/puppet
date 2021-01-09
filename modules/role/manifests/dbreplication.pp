# class: role::dbreplication
class role::dbreplication {
    include mariadb::packages

    $icinga_password = lookup('passwords::db::icinga')
    class { 'mariadb::config':
        config          => 'mariadb/config/mw.cnf.erb',
        password        => lookup('passwords::db::root'),
        server_role     => 'slave',
        icinga_password => $icinga_password,
    }

    file { '/etc/ssl/private':
        ensure  => directory,
        owner   => 'root',
        group   => 'mysql',
        mode	=> '0750',
    }

    $fwPort3306 = query_facts("domain='$domain' and (Class[Role::Icinga2])", ['ipaddress', 'ipaddress6'])
    $fwPort3306.each |$key, $value| {
        ufw::allow { "mariadb inbound 3306/tcp for ${value['ipaddress']}":
            proto   => 'tcp',
            port    => 3306,
            from    => $value['ipaddress'],
        }

        ufw::allow { "mariadb inbound 3306/tcp for ${value['ipaddress6']}":
            proto   => 'tcp',
            port    => 3306,
            from    => $value['ipaddress6'],
        }
    }


    include ssl::wildcard

    # Create a user to allow db transfers between servers
    users::user { 'dbcopy':
        ensure      => present,
        uid         => 3000,
        ssh_keys    => [
            'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFX1yvcRAMqwlbkkhMPhK1GFYrLYM18qC1YUcuUEErxz dbcopy@db6'
        ],
    }

    motd::role { 'role::dbreplication':
        description => 'replication backup database server',
    }
}
