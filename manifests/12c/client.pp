# == Class: oracle
#
class oracle::12c::client() {

  $oracle_home    ='/u01/app/oracle/product/12.1/client'
  $oracle_base    ='/u01/app/oracle'
  $installer      ='/home/oracle/sig/client'
  $dbhostname     ='db.local'
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

  exec { "unzipClient":
    command   => "/usr/bin/unzip /opt/media/3rdParty/oracle/linuxamd64_12102_client.zip",
    cwd       => $installer,
    creates   => "${installer}/client/runInstaller",
    user      => oracle,
    group     => dba,
    logoutput => true,
  }

  exec { "clientInstall":
    command     => "${installer}/client/runInstaller -silent -responseFile /home/oracle/sig/client/client_install.rsp",
    cwd         => $installer,
    require     => [File["client-response"],
                    Group["oinstall"],
                    User["oracle"]],
    environment => ["HOME=/home/oracle",
                    "ORACLE_HOME=/u01/app/oracle/product/11.2.0",
                    ],
    creates     => "$oracle_home/root.sh",
    user        => oracle,
    group       => oinstall,
    logoutput   => true,
  }

  # template(<FILE REFERENCE>, [<ADDITIONAL FILES>, ...])
   file { 'tnsnames':
     ensure    => file,
     path      => "$oracle_home/network/admin/tnsnames.ora",
     require     => [File["client-response"],
                     User["oracle"]],
     owner     => oracle,
     group     => oinstall,
     content   => template('oracle/tnsnames.ora.erb'),
   }

}
