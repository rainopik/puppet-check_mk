# Sets up and installs Open Monitoring Distribution with check_mk
# 
# Parameters:
#   [*filestore*]         - directory for OMD package file. Set if you want to enable file-based installs, leave undef for installs from repository
#   [*package*]           - package name (install from system repository) or package filename (file-based install)
#   [*site*]              - OMD site name that will be created
#   [*workspace*]         - temp dir for file-based installs
#   [*omd_service_name*]  - name for the OMD service
#   [*http_service_name*] - name for the Apache service. Leave undef for autodetection, set false if Apache service should not be handled (eg. defined in another module)
#
class check_mk (
  $filestore            = undef,
  $host_groups          = undef,
  $package              = 'omd-0.56',
  $site                 = 'monitoring',
  $workspace            = '/root/check_mk',
  $omd_service_name     = 'omd',
  $http_service_name    = undef,
) {
  class { 'check_mk::install':
    filestore => $filestore,
    package   => $package,
    site      => $site,
    workspace => $workspace,
  }
  class { 'check_mk::config':
    host_groups => $host_groups,
    site        => $site,
    require     => Class['check_mk::install'],
  }
  class { 'check_mk::service':
    http_service_name => $http_service_name,
    omd_service_name  => $omd_service_name,
    require           => Class['check_mk::config'],
  }
}
