# chrome.pp
# Install Google Chrome for OS X or Ubuntu
# https://www.google.com/chrome/browser/desktop
# https://www.google.com/linuxrepositories
#

class software::browsers::chrome (
  $ensure  = $software::params::software_ensure,
  $url     = $software::params::chrome_url,
  $channel = $software::params::chrome_channel,
) inherits software::params {

  validate_string($ensure)
  validate_string($url)

  case $::operatingsystem {
    'Darwin': {
      package { 'GoogleChrome':
        ensure   => $ensure,
        provider => appdmg,
        source   => $url,
      }
    }
    'Ubuntu': {
      validate_string($channel)

      $apt_source_ensure = $ensure ? {
        'installed' => present,
        'latest'    => present,
        default     => $ensure,
      }

      include '::apt'
      apt::source { 'google-chrome':
        ensure   => $apt_source_ensure,
        location => $url,
        release  => 'stable',
        repos    => 'main',
        key      => {
          'id'     => '4CCA1EAF950CEE4AB83976DCA040830F7FAC5991',
          'source' => 'https://dl.google.com/linux/linux_signing_key.pub',
        },
      } ->

      package { "google-chrome-${channel}":
        ensure => $ensure,
      }
    }
    default: {
      fail("The ${name} class is not supported on ${::operatingsystem}.")
    }
  }

}
