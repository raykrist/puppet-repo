#
class repo::keygen(
  String $keyname,
  String $email,
  String $desc,
  String $passphrase = "''",
  Integer $keylen = 4096,
  String $user = $repo::user,
  String $basedir = $repo::basedir,
  Array $packages = ['rng-tools']
) {

  Exec {
    path => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin',
    user => $user
  }

  package { $packages:
    ensure => installed
  }

  file { "${basedir}/gpg-keygen":
    owner   => $user,
    mode    => '0644',
    content => template("${module_name}/keygen.erb"),
  }

  exec { 'repo rngd urandom':
    command     => 'rngd -r /dev/urandom',
    refreshonly => true,
    user        => root,
    notify      => Exec['repo gpg --key-gen']
  }

  exec { 'repo gpg --key-gen':
    command     => "gpg --batch --gen-key ${basedir}/gpg-keygen",
    refreshonly => true,
    notify      => Exec['repo export gpg pub key']
  }

  exec { 'repo gpg keygen trigger':
    command => 'echo',
    unless  => "test -s ${basedir}/.gnupg/pubring.kbx",
    notify  => Exec['repo rngd urandom']
  } -> exec { 'repo export gpg pub key':
    command => "gpg --armor --output ${basedir}/apt/pub/gpg.key --export ${email}",
    creates => "${basedir}/apt/pub/gpg.key",
  }

}
