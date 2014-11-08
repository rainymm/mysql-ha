class source::mgmserver {
	include source::mgmserver::exec1
	 notify { "---------------------source::mgmserver-------------------------------":
      withpath => true,
    }

}

class source::mgmserver::exec1 {
	exec { "start mgm":
		command => "/usr/local/bin/ndb_mgmd -f /var/lib/mysql-cluster/config.ini",
		path => ["/usr/bin","/usr/sbin","/bin","/sbin"],
		logoutput => on_failure,		
		require => Class["source::mgm::exec3"],	
	}
}
