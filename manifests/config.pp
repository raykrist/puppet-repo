# Class: repo::config
#
# Set up the repos and users
#
# == Parameters
#
# [*incoming*]
#   If this is false, we do not set up incoming dirs and ssh keys
#
# == Authors
#
# Raymond Kristiansen <raymond.kristiansen@it.uib.no>
#
class repo::config(
  $basedir    = $::repo::basedir,
  $user       = $::repo::user,
  $group      = $::repo::group,
  $user_keys  = $::repo::user_keys,
  $incoming   = $::repo::incoming,
  $repo_types = $::repo::repo_types
) {

  File {
    owner  => $user,
    group  => $group,
    mode   => '0755'
  }

  $repodir = prefix($repo_types, "${basedir}/")
  $pubdir = suffix($repodir, '/pub')
  $incoming_dir = suffix($repodir, '/incoming')

  file { [ $basedir, $repodir, $pubdir ]:
    ensure => directory
  }

  file { $incoming_dir:
    ensure => $incoming? { true => directory, default => absent },
    force  => true
  }

  user { $user:
    ensure     => present,
    home       => $basedir,
    uid        => 505,
    gid        => 505,
    managehome => true,
    system     => true,
    comment    => 'System user for package repositories',
    require    => Group[$group]
  }

  group { $group:
    ensure => present,
    gid    => 505,
  }

  # Add ssh keys for upload users
  create_resources('repo::add_ssh_keys', $user_keys)

}
