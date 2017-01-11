# == Class: oracle
#
class oracle::12c::client() {

  $oracle_home    ='/u01/app/oracle/product/12.1/client'
  $oracle_base    ='/u01/app/oracle'
  $installer      ='/home/oracle/sig/client'
  $media_home     ='/opt/media'
  $dbhostname     ='ol7.localdomain'
  $dbport         ='1521'
  $servicename    ='orcl.localdomain'
  $sid            ='orcl'

#  file { '/home/oracle/.bashrc':
#      owner => 'oracle',
#      group => 'dba',
#      mode  => '0644',
#      content => template('oracle/bashrc.sh.erb'),
#  }

# template(<FILE REFERENCE>, [<ADDITIONAL FILES>, ...])
 file { 'client-response':
   ensure    => file,
   path      => '/home/oracle/sig/client/client_install.rsp',
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
    command   => "/usr/bin/unzip ${media_home}/3rdParty/oracle/linuxamd64_12102_client.zip",
    cwd       => $installer,
    creates   => "${installer}/client/runInstaller",
    user      => oracle,
    group     => dba,
    logoutput => true,
  }

  exec { "clientInstall":
    command     => "${installer}/client/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile /home/oracle/sig/client/client_install.rsp",
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
