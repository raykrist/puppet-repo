# Define: repo::instance
#
# Configures a specific apt or yum repo ready to import packages
#
# == Actions
#
# Configures repos and sets up a user and mechanism for uploading packages.
# Repos are reindexed on demand by listeing for write events using incron.
#
# == Parameters
#
# [*version*]
#   Required. Version keyword. For Debian/Ubuntu, this will be a string like
#   "oneiric". For yum set the major release version, like "5" or "6"
#
# [*repotype*]
#   Required. "apt" or "yum". apt repos are created using reprepro, yum repos
#   using createrepo
#
# [*incoming*]
#   true or false. Enable a incoming directory for this repo. Default true.
#
# [*arch*]
#   Architecture string to set in the repo config. For yum repos this is
#   typically set to "x86_64", for apt "amd64"
#
# [*description*]
#   Repository description. Defaults to '${name} repository'
#
# [*sign*]
#   Sign the repository with the given key. 'disabled' means no signing and
#   is the default. The gpg given must be generated and available for the root
#   user on the server prior to setting this. As root run "gpg --list-keys"
#
# === Examples
#
#  repo::instance { 'el6-testing':
#    version => '6',
#    repotype => 'yum',
#    arch => "x86_64",
#    require => Class['app::inf::repo']
#  }
#
# == Authors
#
# Christian Bryn <christian.bryn@freecode.no>
# Jan Ivar Beddari <janivar@beddari.net>
# Raymond Kristiansen <raymond.kristiansen@it.uib.no>
#
#
define repo::instance (
  $version,
  $repotype,
  $arch,
  $description="${name} repository",
  $sign = false,
  $upload = true,
  $incoming = $::repo::incoming
) {

  # Validate repo type
  if ! ($repotype in ['apt','yum','gem']) {
    fail 'Non-supported repository type'
  }

  if $version =~ Array {
    $real_version = $version
  } else {
    $real_version = [ $version ]
  }

  File {
    owner => $repo::user,
    group => $repo::group,
    mode  => '0755',
  }

  # Create repo dirs
  $repodir = "${repo::basedir}/${repotype}/pub/${name}"
  file { $repodir:
    ensure => directory,
  }

  # Create incoming repo dir
  file { "${repo::basedir}/${repotype}/incoming/${name}":
    ensure => $incoming? { true => directory, default => absent },
    force  => true
  }

  # Incron entry
  if $incoming {
    file { "/etc/incron.d/${repotype}-${name}":
      ensure  => $incoming? { true => present, default => absent },
      mode    => '0644',
      owner   => root,
      group   => root,
      content => template("${module_name}/incron.d/repo-${repotype}.erb"),
      notify  => Class['repo::service']
    }
  }

  # Apt stuff
  if $repotype == 'apt' {
    file { "${repodir}/conf":
      ensure => directory,
    }
    file {
      "${repodir}/conf/distributions":
        ensure  => present,
        content => template("${module_name}/apt-distributions.erb");
      "${repodir}/conf/options":
        ensure  => present,
        content => template("${module_name}/apt-options.erb");
    }
  }

  # Gem specific
  # See http://docs.rubygems.org/read/chapter/18
  if $repotype == 'gem' {
    file { "${repodir}/gems":
      ensure => directory,
    }
    exec { "${repodir} gem index":
      command => "/usr/bin/gem generate_index --directory ${repodir}",
      unless  => "/usr/bin/test -d ${repodir}/quick",
      user    => $::repo::user,
      require => File["${repodir}/gems"],
    }
  }

  # Yum stuff
  if $repotype == 'yum' {
    # If not upload, root should own incoming
    $incoming_dir = prefix($real_version, "${repo::basedir}/${repotype}/incoming/${name}/")
    file { $incoming_dir:
      ensure  => $incoming? {
        true    => directory,
        default => absent },
      force   => true,
      require => File["${repo::basedir}/${repotype}/incoming/${name}"],
      owner   => $upload? { true => $repo::user, default => root },
      group   => $upload? { true => $repo::group, default => root },
    }

    $pub_dir = prefix($real_version, "${repodir}/")
    file { $pub_dir:
      ensure  => directory,
      require => File[$repodir]
    }

    # Create RHEL symlinks for use of yum variable $releasever
    repo::instance::yum_rhel_symlink { $pub_dir:
      require => File[$pub_dir]
    }
  }

}
