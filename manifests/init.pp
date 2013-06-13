# Module: monit
#
# A puppet module to configure the monit service, and add definitions to be
# used from other classes and modules.
#
# Stig Sandbeck Mathisen <ssm@fnord.no>
# Micah Anderson micah@riseup.net
#
# To set any of the following, simply set them as class parameters
# for example:
#
# class{'monit':
#   alert => 'someone@example.org',
#   mailserver => 'mail.example.com'
# }
#
# The following is a list of the currently available parameters:
#
# alert:            Who should get the email notifications?
#                   Default: root@localhost
#
# enable_httpd:     Should the httpd daemon be enabled?
#                   set this to 'yes' to enable it, be sure
#                   you have set the $monit_default_secret
#                   Valid values: yes or no
#                   Default: no
#
# user:       		The user that could access the httpd daemon.
#                   Default: monit
#
#
# password:       	The password for the httpd daemon.
#                   Default: pwd
#
# httpd_port:       What port should the httpd run on?
#                   Default: 2812
#
#
# mailserver:       Where should monit be sending mail?
#                   set this to the mailserver
#                   Default: localhost
#
# pool_interval:    How often (in seconds) should monit poll?
#                   Default: 120
#
#

class monit (
    $enable_httpd  = 'no',
    $httpd_port    = 2812,
    $user          = 'monit',
    $password      = 'pwd',
    $alert         = 'root@localhost',
    $mailserver    = 'localhost',
    $pool_interval = '120'
){

    # The package
    package { 'monit':
        ensure => installed,
    }

    # The service
    service { 'monit':
        ensure  => running,
        enable  => true,
        require => Package['monit'],
    }

    # How to tell monit to reload its configuration
    exec { 'monit reload':
        provider    => shell,
        command     => '`which monit` reload',
        refreshonly => true,
    }

    # Default values for all file resources
    File {
        owner   => 'root',
        group   => 'root',
        mode    => '0400',
        notify  => Exec['monit reload'],
        require => Package['monit'],
    }

    # The main configuration directory, this should have been provided by
    # the "monit" package, but we include it just to be sure.
    file { '/etc/monit':
        ensure  => directory,
        mode    => '0700',
    }

    # The configuration snippet directory.  Other packages can put
    # *.monitrc files into this directory, and monit will include them.
    file { '/etc/monit/conf.d':
        ensure  => directory,
        mode    => '0700',
        source  => "puppet:///monit/empty/",
        recurse => true,
        purge   => true,
        force   => true,
        ignore  => '.ignore';
    }

    # The main configuration file
    file { '/etc/monit/monitrc':
        ensure  => present,
        content => template('monit/monitrc.erb'),
    }

    # Monit is disabled by default on debian / ubuntu
    case $::operatingsystem {
        'debian': {
            file { '/etc/default/monit':
                content => "startup=1\n
                CHECK_INTERVALS=${pool_interval}\nSTART=yes\n",
                notify  => Service['monit']
            }
        }
        default: {
        }
    }

    # A template configuration snippet.  It would need to be included,
    # since monit's "include" statement cannot handle an empty directory.
    monit::snippet{ 'monit_template':
        source => "puppet://${::server}/modules/monit/template.monitrc",
    }
}
