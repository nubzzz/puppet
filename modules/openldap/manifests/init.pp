# module for openldap
# == Parameters:
# openldap::pkgs
# openldap::service
# 
# == Requires:
# nothing
# 
# == Sample Usage:
# 

class openldap::server (
	$required_packages = hiera('openldap::pkgs',['openldap-servers','openldap-clients']),
	$service = hiera('openldap::service', 'slapd'),
	$ldapuser = hiera('openldap::slapd::user','ldap'),
	$ldapgroup = hiera('openldap::slapd::group','ldap'),
) {
	package { $required_packages:
		ensure	=> installed,
	}

	File {
		owner	=> "root",
		group	=> "root",
		mode	=> 644,
	}

	service { $service:
		name      => $service,
		ensure    => running,
		enable    => true,
		require	  => Package[$required_packages],
	}
	file {'/etc/openldap/slapd.d':
		owner	=> "$ldapuser",
		group	=> "$ldapgroup",
		mode	=> 0700,
	}
}
