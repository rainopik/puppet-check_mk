class check_mk::service(
  $http_service_name    = undef,
  $omd_service_name     = 'omd',
) {

  $guess_http_service_name = $::osfamily ? {
    /(?i-mx:redhat|suse|gentoo|linux)/ => 'httpd',
    /(?i-mx:debian)/                   => 'apache2',
  }


  $real_http_service_name = $http_service_name ? {
    undef     => $guess_http_service_name,
    default   => $http_service_name,    
  }


  if $http_service_name != false {
    if ! defined(Service[$real_http_service_name]) {
      service { $real_http_service_name:
        ensure    => 'running',
        enable    => true,
      }
    }    
  }


  # xinetd service handled by xinetd module
  service { $omd_service_name:
    ensure    => 'running',
    enable    => true,
  }
}
