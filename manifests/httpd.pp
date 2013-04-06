class owncloud::httpd {
    package{['apache2', 'libapache2-mod-php5']:
        ensure => present,
    }

    service{'apache2':
        enable => true,
    }

    # augeas supports apache configs only since 0.8.0 :(
    exec{'default AllowOverride':
        command  => 'bash -c \'sed -i -e "s/AllowOverride .*/AllowOverride All/" /etc/apache2/sites-available/{default,default-ssl}\'',
        unless   => 'bash -c \'grep AllowOverride /etc/apache2/sites-available/{default,default-ssl} | grep -qw All\'',
        notify   => Service['apache2'],
    }

    exec{'a2enmod rewrite':
        unless => 'test -L /etc/apache2/mods-enabled/rewrite.load',
        notify   => Service['apache2'],
    }

    exec{'a2enmod headers':
        unless => 'test -L /etc/apache2/mods-enabled/headers.load',
        notify   => Service['apache2'],
    }
}
