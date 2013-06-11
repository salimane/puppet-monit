 Puppet module for monit
=========================

This is a puppet module for monit.  It provides a simple way to install the
package, run the service, and handle the configuration.  It also provides a
separate directory for other packages to install monit snippets.

Usage
=====

How to use the module
---------------------

Add the following to your node manifest:

```shell
class {'monit':
    $enable_httpd  = 'no',
    $httpd_port    = 2812,
	$user          = 'monit',
    $password      = 'pwd',
    $alert         = 'root@localhost',
    $mailserver    = 'localhost',
    $pool_interval = '120'
}
```

This will add a host-only "/etc/monit/monitrc" configuration file, which in
turn will include any file ending with ".monitrc" in the "/etc/monit/conf.d/"
directory.

Making passwords
----------------

The $secret class parameter is used to construct a password for your monit
instance.

If you do not set a monit secret, it will use a default "secret" to make
passwords.

How to provide monit configuration snippets?
--------------------------------------------

This module can be used by other modules and classes to monitor their services.

Example:

```shell
  monit::check::process{'openssh':
    pidfile     => '/var/run/sshd.pid',
    start       => '/etc/init.d/ssh start',
    stop        => '/etc/init.d/ssh stop',
    customlines => ['if failed port 22 then restart',
                    'if 2 restarts within 3 cycles then timeout']
  }
```

For more information, see the inline documentation in manifests/init.pp
