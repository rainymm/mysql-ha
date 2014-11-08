class source::minit {
  include source::minit::file1,source::minit::exec1,source::minit::exec2,source::minit::user
    notify { "---------------------source::minit-------------------------------":
      withpath => true,
    }
}
class source::minit::user{
  group { "mysql": 
    ensure => present,
    gid    => 2000
  }
  user { "mysql":
    ensure     => present,
    uid        => 2000,
    gid        => 2000,
    groups     => ["mysql"],
#   membership => minimum,
    shell      => "/sbin/nologin",
    require    => Group["mysql"]
  }

}
class source::minit::file1{  
  file{ "mysql":
    name    => "/var/tmp/mysql/mysql-cluster.tar.gz",
    owner   => "root",
    group   => "root",
    mode    => 0700,
    source  => "puppet://$puppetserver/modules/source/mysql-cluster.tar.gz",
    #backup  => 'main',
    require => Class["source::minit::exec1"],
	notify => Class["source::minit::exec2"],
   }
}
class source::minit::exec1{
  exec {"create mysql_pag":
    command => "mkdir /var/tmp/mysql ",
    path    => ["/usr/bin","/usr/sbin","/bin","/sbin"],
    creates => "/var/tmp/mysql", 
	logoutput => on_failure,
	notify => Class["source::minit::file1"],
  }
}
class source::minit::exec2{
  exec { "install mysql":
    cwd       =>"/var/tmp/mysql",
    command   =>"tar -zxvf mysql-cluster.tar.gz && mv /var/tmp/mysql/mysql-cluster-gpl-7.3.6-linux-glibc2.5-x86_64 /var/tmp/mysql/mysql",  
    path      => ["/usr/bin","/usr/sbin","/bin","/sbin"],
    logoutput => on_failure,  
    require   => Class[source::minit::file1,source::minit::user],
	notify 	  => Class[source::ndbd::file1],
	unless 	  => "/bin/ls /var/tmp/mysql/mysql/lib"
  }
}


