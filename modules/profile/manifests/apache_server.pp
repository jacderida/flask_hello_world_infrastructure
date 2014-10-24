class profile::apache_server {
  # This is a total hack to get a little Flask app running.
  # Not to be used in any way at all for a proper production app!
  $user = 'app'

  include apache
  include apache::mod::wsgi
  anchor { 'profile::apache_server::begin': } ->

  group { $user: ensure => present } ->
  user { $user:
    ensure     => present,
    shell      => '/bin/bash',
    home       => "/home/$user",
    managehome => true
  } ->

  package { 'python-pip': ensure => present } ->
  exec { 'install flask':
    command => '/usr/bin/pip install Flask'
  } ->

  file { '/var/www':
    ensure => directory,
    mode   => '0777'
  } ->

  file { '/var/www/hello_world':
    ensure => directory,
    mode   => '0777'
  } ->

  apache::vhost { 'hello.world.com':
    port                        => '8080',
    docroot                     => '/var/www/hello_world/current',
    wsgi_daemon_process         => 'helloworld',
    wsgi_daemon_process_options =>
      {
        processes    => '1',
        threads      => '5',
        display-name => '%{GROUP}'
      },
    wsgi_process_group  => 'helloworld',
    wsgi_script_aliases => { '/'  => '/var/www/hello_world/current/hello.wsgi' }
  } ->

  file { '/var/run/wsgi':
    ensure => directory,
    mode   => '0777'
  } ->

  exec { 'add wsgi socket prefix':
    command => '/bin/sed -i "1s/^/WSGISocketPrefix \/var\/run\/wsgi\\n /" /etc/httpd/conf.d/25-hello.world.com.conf'
  } ->

  anchor { 'profile::apache_server::end': }
}
