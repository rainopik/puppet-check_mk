# Class: check_mk::agent::install
#
# Install the check_mk::agent
#
class check_mk::agent::install (
  $version = $check_mk::agent::version,
  $filestore = $check_mk::agent::filestore,
  $workspace = $check_mk::agent::workspace,
  $windows_installer = $check_mk::agent::windows_installer,
) {

  case $::operatingsystem {
      debian, ubuntu: {
        $package_name_cmk = 'check-mk-agent'
        $package_name_logwatch = 'check-mk-agent-logwatch'
      }
      default: {
        $package_name_cmk = 'check_mk-agent'
        $package_name_logwatch = 'check_mk-agent-logwatch'
      }
  }


  if $filestore {
    if ! defined(File[$workspace]) {
      file { $workspace:
        ensure => directory,
      }
    }


    case $::operatingsystem {
      centos, redhat: {
        $agent_filename = "check_mk-agent-${version}.noarch.rpm"
        $logwatch_filename = "check_mk-agent-logwatch-${version}.noarch.rpm"
        $provider = 'rpm'
      }
      debian, ubuntu: {
        $agent_filename = "check-mk-agent_${version}_all.deb"
        $logwatch_filename = "check-mk-agent-logwatch_${version}_all.deb"
        $provider = 'dpkg'
      }
      windows: {
        # Nothing
      }
      default: {
        fail("Unsupported OS in check_mk::agent - ${::operatingsystem}")
      }
    }

    file { "${workspace}/${agent_filename}":
      ensure  => present,
      source  => "${filestore}/${agent_filename}",
      require => Package['xinetd'],
    }
    file { "${workspace}/${logwatch_filename}":
      ensure  => present,
      source  => "${filestore}/${logwatch_filename}",
      require => Package['xinetd'],
    }
    package { $package_name_cmk:
      ensure   => present,
      provider => $provider,
      source   => "${workspace}/${agent_filename}",
      require  => File["${workspace}/${agent_filename}"],
    }
    package { $package_name_logwatch:
      ensure   => present,
      provider => $provider,
      source   => "${workspace}/${logwatch_filename}",
      require  => [
        File["${workspace}/${logwatch_filename}"],
        Package[$package_name_cmk],
      ],
    }
  }

  else {
    case $::operatingsystem {
      centos, redhat: {
        $check_mk_agent_packagename = 'check-mk-agent'
        # Redhat/CentOS Package has logwatch build in
        $check_mk_agent_logwatch_packagename = undef
      }
      debian, ubuntu: {
        $check_mk_agent_packagename = $package_name_cmk
        $check_mk_agent_logwatch_packagename = $package_name_logwatch
      }
      windows: {
        # Nothing
      }
      default: {
        fail("Unsupported OS in check_mk::agent - ${::operatingsystem}")
      }
    }
    case $::kernel {
      linux: {
        include xinetd

        package { $check_mk_agent_packagename:
          ensure  => present,
          require => Package['xinetd'],
        }
        if ( $check_mk_agent_logwatch_packagename ) {
          package { $check_mk_agent_logwatch_packagename:
            ensure  => present,
            require => Package[$check_mk_agent_packagename]
          }
        }
      }
      windows: {
        # Windows might have c:\temp or c:\tmp
        # Playing it safe using c:\
        exec {'Download check_mk_agent':
          command  => "\$client = new-object System.Net.WebClient; \$client.DownloadFile('${windows_installer}','C:\\check_mk_agent.exe')",
          creates  => 'C:/check_mk_agent.exe',
          provider => 'powershell'
        }
        exec {'Install check_mk_agent':
          command => 'C:\\check_mk_agent.exe /S',
          creates => 'C:\\Program Files (x86)\\check_mk\\check_mk_agent.exe',
          require => Exec['Download check_mk_agent']
        }
      }
      default: {
        fail("Unsupported kernel in check_mk::agent::install - ${::kernel}")
      }
    }
  }
}
