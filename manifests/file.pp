# Define: patch::file
#
# Apply a patch on a single file.
#
# === Authors
#
# Martin Meinhold <Martin.Meinhold@gmx.de>
#
# === Copyright
#
# Copyright 2014 Martin Meinhold, unless otherwise noted.
#
define patch::file (
  $target = $title,
  $diff_content = undef,
  $diff_source = undef,
  $prefix = undef,
  $path = ['/usr/local/bin', '/usr/bin', '/bin'],
  $cwd = '/',
) {
  validate_absolute_path($target)

  require ::patch

  $real_prefix = $prefix ? {
    undef   => '',
    default => "${prefix}-"
  }
  $patch_name = md5($target)
  $patch_file = "${patch::patch_dir}/${real_prefix}${patch_name}.patch"
  case $::operatingsystem {
    'FreeBSD' : {
      $root_group = 'wheel'
    }
    default : {
      $root_group = 'root'
    }
  }

  file { $patch_file:
    ensure  => file,
    content => $diff_content,
    source  => $diff_source,
    owner   => 'root',
    group   => $root_group,
    mode    => '0640',
  }

  exec { "apply-${real_prefix}${patch_name}.patch":
    command => "patch --forward ${target} ${patch_file}",
    onlyif  => "patch --forward --dry-run ${target} ${patch_file}",
    path    => $path,
    cwd     => $cwd,
    require => File[$patch_file],
  }
}
