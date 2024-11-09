# Class: repo::service
#
# Set up the incron service
#
# == Parameters
#
# == Authors
#
# Raymond Kristiansen <raymond.kristiansen@it.uib.no>
#
class repo::service() {

  service { 'incrond':
    ensure => $::repo::incoming? { true => running, default => stopped },
    enable => $::repo::incoming? { true => true, default => false }
  }

}
