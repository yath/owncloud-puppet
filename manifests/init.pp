class owncloud {
    file{'/var/www/owncloud/puppet-data':
        ensure => directory,
    }

    class{'owncloud::database': }

#    require owncloud::database
    require owncloud::httpd

    package{'owncloud':
        ensure => present,
    }

    $dbname         = hiera('owncloud::db::name')
    $dbuser         = hiera('owncloud::db::user')
    $dbpassword     = hiera('owncloud::db::pass')
    $passwordsalt   = hiera('owncloud::passwordsalt')
    $datadirectory  = hiera('owncloud::datadirectory')
    validate_string($dbname, $dbuser, $dbpassword, $passwordsalt, $datadirectory)

    $dodebug  = hiera('owncloud::debug')
    $forcessl = hiera('owncloud::forcessl')
    validate_bool($dodebug, $forcessl)

    file{'/var/www/owncloud/config/config.php':
        ensure  => present,
        content => template('owncloud/config.php.erb'),
        require => Package['owncloud'],
        owner   => 'www-data',
        group   => 'www-data',
        replace => false, # will be updated by owncloud
    }

    file{$datadirectory:
        ensure => directory,
        owner  => 'www-data',
        group  => 'www-data',
    }
}
