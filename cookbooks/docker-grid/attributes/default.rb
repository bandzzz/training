#
# Cookbook Name:: docker-grid
# Attributes:: default
#
# Copyright 2016-2017, whitestar
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['docker-grid']['install_flavor'] = 'dockerproject'  # or 'os-repository'
default['docker-grid']['dockerproject']['package_name'] = 'docker-engine'
default['docker-grid']['apt_repo'] = {
  'url' => 'https://apt.dockerproject.org/repo',
  'keyserver' => 'hkp://p80.pool.sks-keyservers.net:80',
  'recv-keys' => '58118E89F3A912897C070ADBF76221572C52609D',
  'override_apt_line' => '',  # e.g. 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
}
default['docker-grid']['yum_repo'] = {
  'baseurl' => 'https://yum.dockerproject.org/repo/main/centos/$releasever/',
  'gpgcheck' => '1',
  'gpgkey' => 'https://yum.dockerproject.org/gpg',
}

default['docker-grid']['compose']['install_flavor'] = 'dockerproject'  # or 'os-repository'
default['docker-grid']['compose']['skip_setup'] = false
# dockerproject: direct download.
# Note: non-support by this cookbook.
#   os-repository (Ubuntu): http://packages.ubuntu.com/search?keywords=docker-compose&searchon=names
#   os-repository (CentOS): none.
default['docker-grid']['compose']['auto_upgrade'] = false
default['docker-grid']['compose']['release_base_url'] = 'https://github.com/docker/compose/releases/download/1.9.0'
default['docker-grid']['compose']['release_url'] = "#{node['docker-grid']['compose']['release_base_url']}/docker-compose-#{node['kernel']['name']}-#{node['kernel']['machine']}"
default['docker-grid']['compose']['home_dir'] = '/opt/docker-compose'
default['docker-grid']['compose']['app_dir'] = "#{node['docker-grid']['compose']['home_dir']}/app"

default['docker-grid']['engine']['skip_setup'] = false
# dockerproject: 17.03.1.ce-1, 1.13.1-1, 1.12.6-1, 1.11.2-1, 1.10.3-1
# os-repository: yum list docker
#   http://mirror.centos.org/centos/7.3.1611/extras/x86_64/Packages/
default['docker-grid']['engine']['version_on_centos'] = '1.11.2-1'
# dockerproject: 17.03.1~ce-0, 1.13.1-0, 1.12.6-0, 1.11.2-0
default['docker-grid']['engine']['version_on_debian'] = '17.03.1~ce-0'
# os-repository: http://packages.ubuntu.com/search?keywords=docker.io&searchon=names
default['docker-grid']['engine']['version_on_ubuntu'] = '1.11.2-0'

# '' (empty) version -> latest version
case node['platform']
when 'centos', 'redhat'
  version_on_centos = node['docker-grid']['engine']['version_on_centos']
  if !version_on_centos.nil? && !version_on_centos.empty?
    version_on_centos = "#{version_on_centos}.el#{node['platform_version'].to_i}.#{node['platform']}"
  end
when 'debian'
  version_on_debian = node['docker-grid']['engine']['version_on_debian']
  if !version_on_debian.nil? && !version_on_debian.empty?
    version_on_debian = \
      if node['docker-grid']['install_flavor'] == 'dockerproject'
        if Gem::Version.create(version_on_debian.tr('~', '-')) >= Gem::Version.create('1.12.4-0')
          "#{version_on_debian}~debian-#{node['lsb']['codename']}"
        else
          "#{version_on_debian}~#{node['lsb']['codename']}"
        end
      end
  end
when 'ubuntu'
  version_on_ubuntu = node['docker-grid']['engine']['version_on_ubuntu']
  if !version_on_ubuntu.nil? && !version_on_ubuntu.empty?
    version_on_ubuntu = \
      if node['docker-grid']['install_flavor'] == 'dockerproject'
        if Gem::Version.create(version_on_ubuntu.tr('~', '-')) >= Gem::Version.create('1.12.4-0')
          "#{version_on_ubuntu}~ubuntu-#{node['lsb']['codename']}"
        else
          "#{version_on_ubuntu}~#{node['lsb']['codename']}"
        end
        # else
        # e.g. 1.12.3-0ubuntu4~16.10.2, 1.12.3-0ubuntu4~16.04.2
        # version_on_ubuntu
      end
  end
end

# '' (empty) version -> latest version
default['docker-grid']['engine']['version'] = node.value_for_platform(
  ['centos', 'redhat'] => {
    'default' => version_on_centos,
  },
  'debian' => {
    'default' => version_on_debian,
  },
  'ubuntu' => {
    'default' => version_on_ubuntu,
  }
)
# overlay2: Docker >= 1.12, Kernel >= 4.0
default['docker-grid']['engine']['storage-driver_on_centos'] = 'overlay'
default['docker-grid']['engine']['storage-driver_on_debian'] = 'overlay2'
default['docker-grid']['engine']['storage-driver_on_ubuntu'] = 'aufs'
default['docker-grid']['engine']['storage-driver'] = node.value_for_platform(
  ['centos', 'redhat'] => {
    'default' => node['docker-grid']['engine']['storage-driver_on_centos'],
  },
  'debian' => {
    'default' => node['docker-grid']['engine']['storage-driver_on_debian'],
  },
  'ubuntu' => {
    'default' => node['docker-grid']['engine']['storage-driver_on_ubuntu'],
  }
)
default['docker-grid']['engine']['userns-remap'] = nil  # default: inactive
# CentOS default: '--selinux-enabled --log-driver=journald --signature-verification=false'
default['docker-grid']['engine']['daemon_extra_options'] = '-H fd://'
default['docker-grid']['engine']['users_allow'] = []

# dockerproject: container image from https://hub.docker.com/
# Note: non-support by this cookbook.
#   os-repository (Ubuntu): http://packages.ubuntu.com/search?keywords=docker-registry&searchon=names
#   os-repository (CentOS): http://mirror.centos.org/centos/7.3.1611/extras/x86_64/Packages/
default['docker-grid']['registry']['with_ssl_cert_cookbook'] = false
# If node['docker-grid']['registry']['with_ssl_cert_cookbook'] is true,
# node['docker-grid']['registry']['docker-compose']['config']
# are overridden by the following 'ca_name' and 'common_name' attributes.
#default['docker-grid']['registry']['ssl_cert']['ca_name'] = nil
default['docker-grid']['registry']['ssl_cert']['common_name'] = node['fqdn']
# See https://docs.docker.com/registry/configuration/
rootdirectory = node.value_for_platform(
  ['centos', 'redhat'] => {
    'default' => '/var/lib/registry',
  },
  ['debian', 'ubuntu'] => {
    'default' => '/var/lib/docker-registry',
  }
)
default['docker-grid']['registry']['server']['config'] = {
  'version' => '0.1',
  'log' => {
    'fields' => {
      'service' => 'registry',
    },
  },
  'storage' => {
    'cache' => {
      # NOTE: Formerly, blobdescriptor was known as layerinfo.
      # While these are equivalent, layerinfo has been deprecated.
      'blobdescriptor' => 'inmemory',
    },
    'filesystem' => {
      'rootdirectory' => rootdirectory,
    },
  },
  'http' => {
    'addr' => ':5000',
    'headers' => {
      'X-Content-Type-Options' => [
        'nosniff',
      ],
    },
  },
  #'proxy' => {
  #  'remoteurl' => 'https://registry-1.docker.io',
  #},
  'health' => {
    'storagedriver' => {
      'enabled' => true,
      'interval' => '10s',
      'threshold' => 3,
    },
  },
}
default['docker-grid']['registry']['docker-compose']['app_dir'] = "#{node['docker-grid']['compose']['app_dir']}/registry"
# ./docker-compose.yml
default['docker-grid']['registry']['docker-compose']['config_format_version'] = '1'
default['docker-grid']['registry']['docker-compose']['service_name'] = 'registry'
default['docker-grid']['registry']['docker-compose']['host_data_volume'] = '/var/lib/docker-registry'
service_name = node['docker-grid']['registry']['docker-compose']['service_name']
version_1_config = {
  # Version 1 docker-compose format
  service_name => {
    'restart' => 'always',
    'image' => 'registry:2',
    #'ports' => [
    #  '5000:5000',
    #],
    #'environment' => {
    #  'REGISTRY_HTTP_TLS_CERTIFICATE' => '/certs/domain.crt',
    #  'REGISTRY_HTTP_TLS_KEY' =>         '/certs/domain.key',
    #  'REGISTRY_AUTH' =>                'htpasswd',
    #  'REGISTRY_AUTH_HTPASSWD_PATH' =>  '/auth/htpasswd',
    #  'REGISTRY_AUTH_HTPASSWD_REALM' => 'Registry Realm',
    #},
    #'volumes' => [
    #  #'./etc/config.yml:/etc/docker/registry/config.yml',  # Overriding the entire configuration file
    #  "#{node['docker-grid']['registry']['docker-compose']['host_data_volume']}:/var/lib/registry",
    #  '/path/certs:/certs',
    #  '/path/auth:/auth',
    #],
  },
}
version_2_config = {
  # Version 2 docker-compose format
  'version' => '2',
  'services' => version_1_config,
}
default['docker-grid']['registry']['docker-compose']['config'] = \
  node['docker-grid']['registry']['docker-compose']['config_format_version'] == '2' ? version_2_config : version_1_config
# ./etc/config.yml
# See: https://docs.docker.com/registry/configuration/#/overriding-the-entire-configuration-file
default['docker-grid']['registry']['docker-compose']['registry-config'] = nil
