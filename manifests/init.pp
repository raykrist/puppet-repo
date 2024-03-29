# Class: repo
#
# Configures a repo system using reprepro for apt, createrepo for yum and
# generate_index for gem.
#
# == Actions
#
# Configures repos and sets up a user and mechanism for uploading packages.
# Repos are reindexed on uploads with write events using incron.
#
# Each instance of a repo will have one directory under each /incoming/ and
# each /pub/
#
# Known bugs: Will not accept multiple file uploads. Only use scp with single file.
#
# Requires github.com/puppetlabs/puppetlabs-stdlib >= 4.6.0
#
# == Parameters
#
# [*repo_types*]
#   Array with the repo types to set up. Allowed values are yum, apt and gem
#
# [*basedir*]
#   Base path of all repositories. Repositories will be created in this path.
#
# [*scriptdir*]
#   The location of the reindex scripts. Default /usr/local/bin
#
# [*user*]
#   Username for user used for uploading new packages.
#
# [*group*]
#   Group set on the folders in $basedir/incoming
#
# [*incoming*]
#   Tells us if we should allow incoming packages to the repo. Default is true
#
# == Examples
#
#  class { "repo":
#    repo_types => [ 'yum', 'apt' ]
#  }
#
# == Authors
#
# Raymond Kristiansen <raymond.kristiansen@it.uib.no>
# Jan Ivar Beddari <janivar@beddari.net>
# Christian Bryn <christian.bryn@freecode.no>
#
class repo (
  Array $repo_types = [ 'yum', 'apt', 'gem'],
  String $basedir = '/var/lib/repo',
  String $scriptdir = '/usr/local/bin',
  String $user = 'repo',
  Integer $uid = 505,
  String $group = 'repo',
  Integer $gid = 505,
  Boolean $incoming = true,
  Boolean $generate_gpgkey = false,
  Hash $user_keys = {}
) {

  class { 'repo::install': }
  -> class { 'repo::config': }
  -> class { 'repo::service': }

  if $generate_gpgkey and $incoming {
    class { 'repo::keygen':
      require => Class['repo::config']
    }
  }

}
