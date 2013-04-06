class owncloud::database {
    $rootpw = hiera('owncloud::db::rootpw')
    validate_string($rootpw)

    class {'mysql::server':
        config_hash => { 'root_password' => $rootpw },
    }

    $db   = hiera('owncloud::db::name')
    $dbuser = hiera('owncloud::db::user')
    $dbpass = hiera('owncloud::db::pass')
    validate_string($db, $dbuser, $dbpass)

    mysql::db { $db:
        user     => $dbuser,
        password => $dbpass,
        host     => 'localhost',
        grant    => ['all'],
    }

    $now          = time()
    $adminuser    = hiera('owncloud::adminuser')
    $adminpass    = hiera('owncloud::adminpass')
    $passwordsalt = hiera('owncloud::passwordsalt')
    validate_string($adminuser, $adminpass, $passwordsalt)

    $puppetdata = '/var/www/owncloud/puppet-data'
    file{"${puppetdata}/schema.sql":
        ensure   => present,
        content  => template('owncloud/owncloud.sql.erb'),
        replace  => false, # password hash and current time will always be different
    }

    exec{"schema ${db}":
        command     => "mysql ${db} < ${puppetdata}/schema.sql && touch ${puppetdata}/schema-created",
        environment => 'HOME=/root',
        creates     => "${puppetdata}/schema-created",
        require     => [Mysql::Db[$db] ],
    }
}
