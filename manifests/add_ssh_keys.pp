#
define repo::add_ssh_keys(
  $key,
  $ensure = present,
  $type = 'ssh-rsa',
  $user = $::repo::user
) {

  ssh_authorized_key { "${name}-${user}":
    ensure => $ensure,
    key    => $key,
    type   => $type,
    user   => $user
  }
}
