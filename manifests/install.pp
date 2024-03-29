# Class: repo::install
#
# Install all packages needed for the repo module
#
# == Parameters
#
# == Authors
#
# Raymond Kristiansen <raymond.kristiansen@it.uib.no>
#
class repo::install(
  $scriptdir = $::repo::scriptdir
) {

  package { ['reprepro','createrepo','incron','rubygem-builder','rubygems','gnupg2']:
    ensure => installed
  }

  File {
    owner => 'root',
    group => 'root',
    mode  => '0755',
  }

  file { "${scriptdir}/apt-updaterepo":
    content => template("${module_name}/bin/apt-updaterepo"),
  }

  file { "${scriptdir}/gem-updaterepo":
    content => template("${module_name}/bin/gem-updaterepo"),
  }

  file { "${scriptdir}/yum-updaterepo":
    content => template("${module_name}/bin/yum-updaterepo"),
  }

}
