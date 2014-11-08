class source::ndbdserver {
	include source::ndbdserver::exec1,source::ndbdserver::exec2,source::ndbdserver::exec3
	 notify { "---------------------source::ndbdserver -------------------------------":
      withpath => true,
    }

}


class source::ndbdserver::exec1 {
	exec { "start ndbd init":
		command => "/usr/local/mysql/bin/ndbd --initial && mkdir /usr/local/mysql/data/gg",
		path => ["/usr/bin","/usr/sbin","/bin","/sbin"],
		logoutput => on_failure,
		unless => "/bin/ls /usr/local/mysql/data/gg",
		require => Class["source::ndbd::exec5"],
		notify => Class["source::ndbdserver::exec2"],
	}
}

class source::ndbdserver::exec3 {
	exec { "start ndbd":	
		command => "/usr/local/mysql/bin/ndbd",
		path => ["/usr/bin","/usr/sbin","/bin","/sbin"],
        logoutput => on_failure,
        onlyif => "/bin/ls /usr/local/mysql/data/gg",
        require => Class["source::ndbd::exec5"],
		notify => Class["source::ndbdserver::exec2"],
	}
}

class source::ndbdserver::exec2 {
	exec { "start mysqld":
		command => "/usr/local/mysql/bin/mysqld_safe --user=mysql &",
		path => ["/usr/bin","/usr/sbin","/bin","/sbin"],
		logoutput => on_failure,
		#refreshonly => true,
		require => Class["source::ndbdserver::exec1","source::ndbdserver::exec3"],
	}
}
