#
define repo::instance::yum_rhel_symlink() {

  file { "${name}Server":
    ensure => link,
    target => $name
  }

  file { "${name}Workstation":
    ensure => link,
    target => $name
  }
}
