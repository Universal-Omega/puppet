# PRIVATE CLASS: do not use directly
class mongodb::repo (
  Variant[Enum['present', 'absent'], Boolean] $ensure = 'present',
  Optional[String] $version                           = undef,
  Optional[String] $repo_location                     = undef,
  Optional[String] $proxy                             = undef,
  Optional[String] $proxy_username                    = undef,
  Optional[String] $proxy_password                    = undef,
  Optional[String[1]] $aptkey_options                 = undef,
) {
    if $repo_location != undef {
        $location = $repo_location
    } elsif $version == undef or versioncmp($version, '3.0.0') < 0 {
        fail('Package repositories for versions older than 3.0 are unsupported')
    } else {
        $repo_domain = 'repo.mongodb.org'
        $repo_path   = 'mongodb-org'

        $mongover = split($version, '[.]')
        $location = "https://${repo_domain}/apt/debian",
        $release     = "buster/${repo_path}/${mongover[0]}.${mongover[1]}"
        $repos       = 'main'
        $key = "${mongover[0]}.${mongover[1]}" ? {
          '5.0'   => 'F5679A222C647C87527C2F8CB00A0BD1E2C63C11',
          '4.4'   => '20691EEC35216C63CAF66CE1656408E390CFB1F5',
          default => '492EAFE8CD016A07919F1D2B9ECBEC467F0CEB10'
        }
        $key_server = 'hkp://keyserver.ubuntu.com:80'
    }

    contain mongodb::repo::apt
}
