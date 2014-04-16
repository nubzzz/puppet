class rpm-repo::server (
	$document_root	= '/var/www/',
	$https_toggle	= false,
    $server_name    = $fqdn,
    $server_admin   = "it@wellspringworldwide.com",
    $aliases        = $hostname,
    $errorlog_name  = "$hostname-error_log",
    $accesslog_name = "$hostname-access_log",
    ) {
    
    case $::osfamily {
        'RedHat': {
        	package {
        		'httpd':
        			ensure	=> installed;
        		'createrepo':
        			ensure	=> installed;
        	}
            
            service {
                'httpd':
                    ensure  => running,
                    enable  => true,
                    hasstatus   => true,
                    hasrestart  => true,
                    require => Package['httpd'];
            }
        
            file {
                '/etc/httpd/conf.d/repo.conf':
                    content => template('rpm-repo/repo.conf.erb'),
                    mode    => '0644',
                    owner   => 'root',
                    group   => 'root',
                    notify  => Service['httpd'],
                    require => Package['httpd'];
            }
        }
        default: {
            fail('This operating system is not supported by the rpm-repo class')
        }
    }
}
