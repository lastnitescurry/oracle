# == Class: oracle
#
# Performs initial configuration tasks for all Vagrant boxes.
# http://www.puppetcookbook.com/posts/add-a-unix-group.html
# https://docs.puppetlabs.com/guides/techniques.html#how-can-i-ensure-a-group-exists-before-creating-a-user
# https://docs.puppetlabs.com/references/latest/type.html#package-attribute-install_options
# http://www.andrejkoelewijn.com/blog/2012/02/28/oracle-xe-on-ubuntu-using-vagrant-and-puppet
# https://github.com/ismaild/vagrant-centos-oracle/blob/master/oracle/xe.rsp
# https://docs.puppet.com/hiera/3.1/puppet.html#automatic-parameter-lookup
class oracle::xe::server (
  $http_port    = "8080",
  $listner_port = "1521",
  $password     = "manager",
  $dbenable     = "y",
  $install_root = "/u01/app/oracle",
  $rpm_source   = "/opt/software/Oracle/Database/oracle-xe-11.2.0-1.0.x86_64.rpm"
  )  {

# Moved to hiera
#  package { "oracle-xe":
#    ensure    => installed,
#    provider  => rpm,
#    source    => $rpm_source,
#    require   => [Package["libaio"],Package["bc"],Package["flex"]],
#  }

    # TODO more to template file
  $xe_responses = "
ORACLE_LISTENER_PORT=${http_port}
ORACLE_HTTP_PORT=${listner_port}
ORACLE_PASSWORD=${password}
ORACLE_CONFIRM_PASSWORD=$password
ORACLE_DBENABLE=${dbenable}
  "

  file { "response-file":
    path    => "${install_root}/xe.rsp.properties",
    content => $xe_responses,
    require => File[$install_root],
  }
  file { "sql-post-file":
    path    => "${install_root}/configure.sql",
    owner   => oracle,
    group   => dba,
    mode    => '0755',
    source  => 'puppet:///modules/oracle/configure.sql',
    require => File[$install_root],
  }

  exec { "create-database":
    command   => "/etc/init.d/oracle-xe configure responseFile=${install_root}/xe.rsp.properties",
    require   => [Package["oracle-xe"],File["response-file"]],
    user      => root,
    timeout   => 3000,
    logoutput => true,
    creates   => "${install_root}/oradata/XE/system.dbf",
   }

  exec { "post-db-sql":
    command     => "${install_root}/product/11.2.0/xe/bin/sqlplus system/${password} < ${install_root}/configure.sql",
    cwd         => "${install_root}/product/11.2.0/xe/bin",
    require     => [Exec["create-database"],File["sql-post-file"]],
    environment => [
                  "ORACLE_HOME=${install_root}/product/11.2.0/xe",
                  "ORACLE_SID=XE",
                  "NLS_LANG=AMERICAN_AMERICA.AL32UTF8",
                  ],
    user        => root,
    logoutput   => true,
    subscribe   => File["sql-post-file"],
    refreshonly => true,
   }
}
