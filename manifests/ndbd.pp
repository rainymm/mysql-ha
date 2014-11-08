class source::ndbd {
	include source::ndbd::file1,source::ndbd::exec1,source::ndbd::exec2,source::ndbd::exec3,source::ndbd::exec4,source::ndbd::exec5
	 notify { "---------------------source::ndbd-------------------------------------":
      withpath => true,
    }

}

class source::ndbd::file1 {
	file { "my.cnf":
		name => "/etc/my.cnf",
		owner => "root",
		group => "root",
		mode => 0644,
		source => "puppet://$puppetserver/modules/source/my.cnf",
		require => Class["source::minit::exec2"],
		notify => Class["source::ndbd::exec1"],
	}
}

class source::ndbd::exec1 {
    exec { "cp_mysql":
        cwd => "/usr/local/",
        command =>"cp -R /var/tmp/mysql/mysql /usr/local",
        path => ["/usr/bin","/usr/sbin","/bin","/sbin"],
        logoutput => on_failure,
        unless => "/bin/ls /usr/local/mysql/bin",
        require => Class["source::ndbd::file1"],
		notify => Class["source::ndbd::exec2"],
    }
}

class source::ndbd::exec2 {
	exec { "create_sock":
		command => "mkdir /usr/local/mysql/sock",
		path => ["/usr/bin","/usr/sbin","/bin","/sbin"],
		logoutput => on_failure,
		creates => "/usr/local/mysql/sock",
		require => Class["source::ndbd::exec1"],
		notify => Class["source::ndbd::exec3"],
	}
}

class source::ndbd::exec3 {
	exec{ "scripts_mysql":
		command => "/usr/local/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data",
		path => ["/usr/bin","/usr/sbin","/bin","/sbin"],
		logoutput => on_failure,
		require => Class["source::ndbd::exec2"],
		unless => "/bin/ls /usr/local/mysql/my.cnf",
		notify => Class[source::ndbd::exec4],
	}
}

class source::ndbd::exec4 {
	exec { "quanxian":
		command => "chgrp -R mysql /usr/local/mysql && chown -R mysql:mysql /usr/local/mysql/data && chown -R mysql:mysql /usr/local/mysql/sock",
		path => ["/usr/bin","/usr/sbin","/bin","/sbin"],
		logoutput => on_failure,
		require => Class["source::ndbd::exec3"],
		notify => Class["source::ndbd::exec5"],
		refreshonly => true,
	}
}

class source::ndbd::exec5 {
	exec { "init.d":
		command => "cp /usr/local/mysql/support-files/mysql.server /etc/rc.d/init.d && mv /etc/rc.d/init.d/mysql.server /etc/rc.d/init.d/mysqld && chmod +x /etc/rc.d/init.d/mysqld",
		path => ["/usr/bin","/usr/sbin","/bin","/sbin"],
		logoutput => on_failure,
		require => Class["source::ndbd::exec4"],
		notify => Class[source::ndbdserver::exec1,source::ndbdserver::exec3],
		unless => "/bin/ls /etc/rc.d/init.d/mysqld",
	}
}
