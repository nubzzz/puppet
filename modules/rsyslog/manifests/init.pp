# module to install and configure rsyslog
# == Parameters:
# $req_pkgs	- array of package names
# $loghost	- remote host to send syslog messages to, requires
#		tcp_listen or Udp_listen
# $tcp_listen	- tcp port to listen on
# $udp_listen	- udp port to listen on
# $extra_rules	- array of extra rules to add
#
# == Requires:
# nothing
#
# == Sample Usage:
# include::rsyslog::rsyslog
# or
# class {'rsyslog::rsyslog':
#	loghost		= 'central.domain.tld',
#	tcp_listen	= '514',
#	extra_rules	= ['# slapd logs to /var/log/slapd.log','if $programname == 'slapd' then /var/log/slapd.log','& ~'],
# }

class rsyslog::rsyslog (
	$req_pkgs	= hiera('rsyslog::pkgs',['rsyslog']),
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
	package { $req_pkgs: }
	package { "syslog-ng":
		ensure => absent
	}
	package { "syslogd":
		ensure => absent
	}


	file { "$rsyslog_conf":
		owner => 'root',
		group => 'root',
		mode => '0644',
		content	=> template("rsyslog/$source_file"),
		before => Service["rsyslog"],
		notify => Service["rsyslog"]
	}
	service { "rsyslog":
        	enable  => true,
		ensure  => running,
	}
}
