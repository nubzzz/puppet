class rsyslog::client (
	$loghost	= hiera('rsyslog::loghost',''),
	$tcp_listen	= hiera('rsyslog::tcp_listen','false'),
	$udp_listen	= hiera('rsyslog::udp_listen','false'),
	$extra_rules	= hiera('rsyslog::extra_rules',['']),
) {
	case $::osfamily {
		'RedHat': {
			$rsyslog_conf	= '/etc/rsyslog.conf'
			$source_file	= 'rsyslog.conf.rh.erb'
			$srv_name	= 'rsyslog'
		}
		'Debian': {
			$rsyslog_conf	= '/etc/rsyslog.conf'
			$source_file	= 'rsyslog.conf.deb.erb'
			$srv_name	= 'rsyslog'
		}
		default: {
			fail('Operating system is unsupported by logging class')
		}
	}
	file { "$rsyslog_conf":
		owner => 'root',
		group => 'root',
		mode => '0644',
#		source => "puppet:///files/rsyslog/$source_file",
		content	=> template("rsyslog/$source_file"),
		before => Service["rsyslog"],
		notify => Service["rsyslog"]
	}
	service { "rsyslog":
        	enable  => true,
		ensure  => running,
	}
}
