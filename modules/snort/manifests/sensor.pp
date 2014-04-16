class snort::sensor (
	$ip_ranges ='10.7.0.0/16',
	$dns_servers = '$HOME_NET',
	$external_net = '!$HOME_NET',
	$snort_perfprofile = false,
	$stream_memcap = '8388608',
	$stream_prune_log_max = '1048576',
	$stream_max_queued_segs = '2621',
	$stream_max_queued_bytes = '1048576',
	$perfmonitor_pktcnt = '10000',
	$dcerpc2_memcap = '102400',
	$enable = true,
	$ensure = running,
	$norules = true,
	$interface = 'eth0',
	$rotation = '7',
	$ruleset = 'vrt',
	$daq = false,
	$dynamic_rules = true,
	$required_packages  = hiera('libdnet','libdnet-devel','pcre','pcre-devel','gcc','make','flex','byacc','bison','kernel-devel','libxml2-devel','zlib-devel')) {
	
    case $::osfamily {
        'RedHat': {
        	package {
        		'snort-wellspring':
        			ensure	=> installed;
        		'daq':
        			ensure	=> installed;
        		$required_packages:
        			ensure	=> installed;
        		'libpcap-snort':
        			ensure	=> installed;
        	}
        
        	
        	if $daq == true {
        		package {
        				'libnetfilter_queue':
        					source  => 'http://rules.emergingthreatspro.com/projects/emergingrepo/x86_64/libnetfilter_queue-0.0.17-2.x86_64.rpm',
        					ensure	=> installed;
        				'libnetfilter_queue-devel':
        					source	=> 'http://rules.emergingthreatspro.com/projects/emergingrepo/x86_64/libnetfilter_queue-devel-0.0.17-2.x86_64.rpm',
        					ensure	=> installed;
        				'libnfnetlink':
        					source  => 'http://rules.emergingthreatspro.com/projects/emergingrepo/x86_64/libnfnetlink-1.0.0-1.x86_64.rpm',
        					ensure	=> installed;
        				'libnfnetlink-devel':
        					source	=> 'http://rules.emergingthreatspro.com/projects/emergingrepo/x86_64/libnfnetlink-devel-1.0.0-1.x86_64.rpm',
        					ensure	=> installed;
        		}
        	}
        	
        	file { '/usr/local/snort/rules/local.rules':
        			ensure	=> present,
        			source	=> [ "puppet:///modules/snort/local/local.rules-${::fqdn}", 'puppet:///modules/snort/local/local.rules' ],
        			mode	=> '0644',
        			owner	=> 'root',
        			group	=> 'root',
        			force	=> true,
        			notify	=> Service['snortd'],
        			require => Package['snort-wellspring'];
        		'/etc/snort/snort.conf':
        			mode	=> '0644',
        			owner	=> 'root',
        			group	=> 'root',
        			alias	=> 'snortconf',
        			content => template( 'snort/snort.conf.erb'),
        			notify	=> Service['snortd'],
        			require => Package['snort-wellspring'];
        		'/etc/sysconfig/snort':
        			content	=> template( 'snort/sysconfig/snort.erb'),
        			mode	=> '0644',
        			owner	=> 'root',
        			group	=> 'root',
        			notify	=> Service['snortd'],
        			require => Package['snort-wellspring'];
        		'/etc/logrotate.d/snort':
        			content => template( 'snort/snort.rotate.erb'),
        			mode	=> '0644',
        			owner	=> 'root',
        			group	=> 'root';
        		'/var/log/snort/' :
        			ensure	=> directory,
        			mode	=> '0660',
        			owner	=> 'snort',
        			group	=> 'snort';
        		'/etc/init.d/snortd' :
        			content	=> template( 'snort/init.d/snortd.erb'),
        			mode	=> '0755',
        			owner	=> 'root',
        			group	=> 'root';
        		'/usr/sbin/snort' :
        			ensure	=> link,
        			target	=> '/usr/local/snort/bin/snort';
        		'/usr/local/lib/snort_dynamicpreprocessor' :
        			ensure	=> link,
        			target	=> '/usr/local/snort/lib/snort_dynamicpreprocessor';
        		'/usr/local/lib/snort_dynamicengine' :
        			ensure	=> link,
        			target	=> '/usr/local/snort/lib/snort_dynamicengine';
        		'/usr/local/lib/snort_dynamicrules' :
        			ensure	=> link,
        			target	=> '/usr/local/snort/so_rules/precompiled/RHEL-6-0/x86-64/2.9.6.0/';
        	}
        
        
        	service {'snortd':
        			ensure	=> $ensure,
        			enable	=> $enable,
        			hasstatus	=> true,
        			hasrestart	=> true,
        			require		=> Package['snort-wellspring'];
        	}
        
        	file {	'/etc/ld.so.conf':
        			source	=> 'puppet:///modules/snort/ld.so.conf';
        		'/usr/lib64/libdnet.1':
        			ensure  => 'link',
        			target  => '/usr/lib64/libdnet.so.1';
        	}
        	
        	group { 'snort':
        		ensure	=> 'present';
        	}
        	
        	user { 'snort':
        		ensure	=> 'present',
        		gid	=> 'snort',
        		require	=> Group['snort'];
        	}
        
        	# setup the ruleset
        	
        	if $ruleset == 'vrt' {
                package { 'snort-rules-vrt':
                    ensure  => latest;
                }
            }
            elsif $ruleset == 'ET' {
                package { 'snort-rules-et':
                    ensure  => latest;
                }
            }
            else {
                fail('No ruleset was selected')
            }
        }
        default: {
            fail('This operating system is not supported by the snort class')
        }
    }
}
