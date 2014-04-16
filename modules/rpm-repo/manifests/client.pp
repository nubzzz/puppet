class rpm-repo::client (
    $repo_server    = 'rpm-repo.nubzzz.com',
    $gpg_signed     = true,
    $protocol       = 'http',
    $enabled        = true,
    $suffix         = 'repo',
    $gpg_key_name   = 'RPM-GPG-KEY-home',
    $repo_name           = 'home',
    ) {
    case $::osfamily {
        'RedHat': {
            file {
                "/etc/yum.repos.d/$repo_name.repo":
                    content => template('rpm-repo/customrepo.repo.erb'),
                    mode    => '0644',
                    owner   => 'root',
                    group   => 'root';
            }
        }
        default: {
            fail('This operating system is not supported by the rpm-repo class')
        }
    }
}
