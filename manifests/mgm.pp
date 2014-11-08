class source::mgm {
	include source::mgm::exec1,source::mgm::file1,source::mgm::exec2,source::mgm::exec3
 notify { "---------------------source::mgm--------------------------------------":
      withpath => true,
    }
	
}

class source::mgm::exec1{
	exec { "create file":
		command => "mkdir /var/lib/mysql-cluster",
		path => ["/usr/bin","/usr/sbin","/bin","/sbin"],
		creates => "/var/lib/mysql-cluster",
		require => Class["source::minit::exec2"],
		notify => Class["source::mgm::file1"],
	}
}

class source::mgm::file1{
	file{ "config.ini":
		name => "/var/lib/mysql-cluster/config.ini",
		owner => "root",
		group => "root",
		mode => 0644,
		source => "puppet://$puppetserver/modules/source/config.ini",
		require => Class["source::mgm::exec1"],
		notify => Class["source::mgm::exec2"],
	}
}

class source::mgm::exec2 {
	exec { "cp_ndb_mgm":
		cwd => "/usr/local/bin",
		command =>"cp /var/tmp/mysql/mysql/bin/ndb_mgm* /usr/local/bin",
		path => ["/usr/bin","/usr/sbin","/bin","/sbin"],
		logoutput => on_failure,
		unless => "/bin/ls /usr/local/bin/ndb_mgm*",
		require => Class["source::mgm::file1"],
		notify => Class["source::mgm::exec3"],
	}
}

class source::mgm::exec3 {
	exec { "mkdir mysql":
		command => "mkdir /usr/local/mysql",
		path => ["/usr/bin","/usr/sbin","/bin","/sbin"],
		creates => "/usr/local/mysql",
		require => Class["source::mgm::exec2"],
		notify => Class["source::mgmserver::exec1"],
	}
}
