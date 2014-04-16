class sudo (
	$required_packages = hiera('sudo::pkgs', ['sudo']),
	$enable = true,
	$ensure = running,
	$ldap_uri = hiera('pamldap::servers', ['ldap://ldap.example.tld']),
	$basedn = hiera('pamldap::basedn', 'dc=example,dc=tld'),
	$ldap_binduser = hiera('pamldap::binduser', 'uid=user'),
	$ldap_bindpass = hiera('pamldap::bindpass', 'password'),
	$tls_cacertfile = hiera('tls::cacertfile', '/etc/pki/tls/certs/CA.crt'),
	$tls_reqcert = hiera('tls::reqcert', 'allow'),
	$sudobase = hiera('pamldap::sudobase', 'ou=sudo,dc=example,dc=tld'),
) {
	package { 'sudo':
		ensure => installed,
	}

	File {
		owner	=> "root",
		group	=> "root",
		mode	=> 644,
	}

	file { 'sudo-ldap.conf':
		path    => '/etc/sudo-ldap.conf',
		ensure  => file,
		mode   => 600,
		owner	=> root,
		group	=> root,
		require => Package['sudo'],
		content => template("sudo/sudo-ldap.conf.erb"),
	}
}
