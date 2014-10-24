class apache_wrapper {
  anchor { 'apache_wrapper::begin': } ->
  class { 'role::apache_web_server': } ->
  anchor { 'apache_wrapper::end': }
}

include apache_wrapper
