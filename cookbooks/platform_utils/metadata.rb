# $ knife supermarket share platform_utils "Operating Systems & Virtualization"
name             'platform_utils'
maintainer       'whitestar'
maintainer_email ''
license          'Apache 2.0'
description      'Platform Utilities'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.4.4'
source_url       'http://scm.osdn.jp/gitroot/metasearch/grid-chef-repo.git'
issues_url       'https://osdn.jp/projects/metasearch/ticket'

%w( centos redhat debian ubuntu ).each do |os|
  supports os
end
