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
    ensure  => $::repo::incoming
  }

}