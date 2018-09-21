# == Class: patch
#
# Manage the global configuration of the patch module.
#
# === Parameters
#
# [*ensure*]
#   What the state of the patch module should be.
#
# [*package*]
#   Sets the name of the package to be installed.
#
# === Authors
#
# Martin Meinhold <Martin.Meinhold@gmx.de>
#
# === Copyright
#
# Copyright 2014 Martin Meinhold, unless otherwise noted.
#
class patch (
  $ensure  = $patch::params::ensure,
  $package = $patch::params::package,
  $manage_package = $patch::params::manage_package,
) inherits patch::params {

  case $::operatingsystem {
    'FreeBSD' : {
      $root_group = 'wheel'
    }
    default : {
      $root_group = 'root'
    }
  }

  $patch_dir = "${::puppet_vardir}/patch"
  $patch_dir_ensure = $ensure ? {
    'absent' => absent,
    default  => directory,
  }

  file { $patch_dir:
    ensure => $patch_dir_ensure,
    owner  => 'root',
    group  => $root_group,
    mode   => '0750',
  }

  unless ! $manage_package or $manage_package != 'false' {
    package { $package: ensure => $ensure }
  }
}
