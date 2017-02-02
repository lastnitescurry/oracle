# == Class: oracle
#
class oracle::12c::client() {

  $oracle_home
  $oracle_base
  $installer_location
  $source_location
  $dbhostname
  $dbport
  $servicename
  $sid

# template(<FILE REFERENCE>, [<ADDITIONAL FILES>, ...])
 file { 'client-response':
   ensure    => file,
   path      => "${installer_location}/client_install.rsp",
   owner     => oracle,
   group     => oinstall,
   content   => template('oracle/client_install.rsp.erb'),
 }

 file { 'oraInst':
   ensure    => file,
   path      => '/etc/oraInst.loc',
   owner     => oracle,
   group     => oinstall,
   content   => template('oracle/oraInst.loc.erb'),
 }

  exec { "unzipClient":
    command   => "/usr/bin/unzip ${source_location}/3rdParty/oracle/linuxamd64_12102_client.zip",
    cwd       => $installer,
    creates   => "${installer_location}/client/runInstaller",
    user      => oracle,
    group     => dba,
    logoutput => true,
  }

  exec { "clientInstall":
    command     => "${installer_location}/client/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile ${installer_location}/client_install.rsp",
    cwd         => $installer,
    require     => [File["client-response"],
                    File["oraInst"],
                    Group["oinstall"],
                    User["oracle"]],
    environment => ["HOME=/home/oracle",
                    "ORACLE_HOME=${oracle_base}/product/12.1",
                    ],
    creates     => "$oracle_home/root.sh",
    user        => oracle,
    group       => oinstall,
    logoutput   => true,
  }

  # template(<FILE REFERENCE>, [<ADDITIONAL FILES>, ...])
   file { 'tnsnames':
     ensure    => file,
     path      => "${oracle_home}/network/admin/tnsnames.ora",
     require     => [Exec["clientInstall"],
                     User["oracle"]],
     owner     => oracle,
     group     => oinstall,
     content   => template('oracle/tnsnames.ora.erb'),
   }

}
