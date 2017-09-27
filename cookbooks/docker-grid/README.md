docker-grid Cookbook
====================

This cookbook sets up Docker engine etc.

## Contents

- [Requirements](#requirements)
    - [platforms](#platforms)
    - [packages](#packages)
- [Attributes](#attributes)
- [Usage](#usage)
    - [Recipes](#recipes)
        - [docker-grid::default](#docker-griddefault)
        - [docker-grid::compose](#docker-gridcompose)
        - [docker-grid::engine](#docker-gridengine)
        - [docker-grid::registry](#docker-gridregistry)
        - [docker-grid::registry-docker-compose](#docker-gridregistry-docker-compose)
        - [docker-grid::registry-server](#docker-gridregistry-server)
    - [Role Examples](#role-examples)
    - [SSL server keys and certificates management by `ssl_cert` cookbook](#ssl-server-keys-and-certificates-management-by-ssl_cert-cookbook)
- [License and Authors](#license-and-authors)

## Requirements

### platforms
- CentOS, Red Hat Enterprise Linux >= 7.2 (in baremetal or LXD (Ubuntu >= 14.04))
- Debian >= 9.0
- Ubuntu >= 14.04 (in baremetal or LXD (Ubuntu >= 14.04))

### packages
- none.

## Attributes

|Key|Type|Description, example|Default|
|:--|:--|:--|:--|
|`['docker-grid']['install_flavor']`|String|`'dockerproject'` or `'os-repository'`|`'dockerproject'`|
|`['docker-grid']['dockerproject']['package_name']`|String||`'docker-engine'`|
|`['docker-grid']['apt_repo']['url']`|String||`'https://apt.dockerproject.org/repo'`|
|`['docker-grid']['apt_repo']['keyserver']`|String||`'hkp://p80.pool.sks-keyservers.net:80'`|
|`['docker-grid']['apt_repo']['recv-keys']`|String||`'58118E89F3A912897C070ADBF76221572C52609D'`|
|`['docker-grid']['apt_repo']['override_apt_line']`|String|If you set this attribute, apt-line settings with the `['docker-grid']['apt_repo']['url']` attribute is overrridden. e.g. `'deb https://apt.dockerproject.org/repo ubuntu-xenial main'`|`''`|
|`['docker-grid']['yum_repo']['baseurl']`|String||`'https://yum.dockerproject.org/repo/main/centos/$releasever/'`|
|`['docker-grid']['yum_repo']['gpgcheck']`|String|`'0'`: disabled, `'1'`: enabled.|`'1'`|
|`['docker-grid']['yum_repo']['gpgkey']`|String||`'https://yum.dockerproject.org/gpg'`|
|`['docker-grid']['compose']['install_flavor']`|String|`'dockerproject'` or `'os-repository'`|`'dockerproject'`|
|`['docker-grid']['compose']['skip_setup']`|Boolean||`false`|
|`['docker-grid']['compose']['auto_upgrade']`|Boolean|upgrade/reinstall the docker-compose automatically.|`false`|
|`['docker-grid']['compose']['release_base_url']`|String||`'https://github.com/docker/compose/releases/download/1.9.0'`|
|`['docker-grid']['compose']['release_url']`|String||`"#{node['docker-grid']['compose']['release_base_url']}/docker-compose-#{node['kernel']['name']}-#{node['kernel']['machine']}"`|
|`['docker-grid']['compose']['home_dir']`|String||`'/opt/docker-compose'`|
|`['docker-grid']['compose']['app_dir']`|String||`"#{node['docker-grid']['compose']['home_dir']}/app`|
|`['docker-grid']['engine']['skip_setup']`|Boolean||`false`|
|`['docker-grid']['engine']['version_on_centos']`|String|Docker version for CentOS. `''` (empty) means the latest version.|`'1.11.2-1'`|
|`['docker-grid']['engine']['version_on_debian']`|String|Docker version for Debian. `''` (empty) means the latest version.|`'17.03.1~ce-0'`|
|`['docker-grid']['engine']['version_on_ubuntu']`|String|Docker version for Ubuntu. `''` (empty) means the latest version.|`'1.11.2-0'`|
|`['docker-grid']['engine']['version']`|String|Docker version. `''` (empty) means the latest version. Note: this **default** value is overwritten by the `version_on_{centos or ubuntu}`.|See default.rb|
|`['docker-grid']['engine']['storage-driver_on_centos']`|String|Docker storage driver (overlay, devicemapper, ...) for CentOS.|`'overlay'`|
|`['docker-grid']['engine']['storage-driver_on_debian']`|String|Docker storage driver (aufs, overlay, ...) for Debian.|`'overlay2'`|
|`['docker-grid']['engine']['storage-driver_on_ubuntu']`|String|Docker storage driver (aufs, overlay, ...) for Ubuntu.|`'aufs'`|
|`['docker-grid']['engine']['storage-driver']`|String||See default.rb|
|`['docker-grid']['engine']['userns-remap']`|String|e.g. `'default'` (`dockremap` user/group) or your specified user/group name. Note: it is available in Docker 1.10/later and (Ubuntu or RHEL family 7.2/later).|`nil` (inactive)|
|`['docker-grid']['engine']['daemon_extra_options']`|String|ref. `docker daemon --help`.|`'-H fd://'`|
|`['docker-grid']['engine']['users_allow']`|Array|Non-root users allowed to manage Docker daemon.|`[]`|
|`['docker-grid']['registry']['with_ssl_cert_cookbook']`|Boolean|If this attribute is true, `node['docker-grid']['registry']['docker-compose']['config']` are are overridden by the following `common_name` attributes.|`false`|
|`['docker-grid']['registry']['ssl_cert']['common_name']`|String|Registry server common name for TLS|`node['fqdn']`|
|`['docker-grid']['registry']['server']['config']`|Hash|Registry server configurations.|See `attributes/default.rb`|
|`['docker-grid']['registry']['docker-compose']['app_dir']`|String||`"#{node['docker-grid']['compose']['app_dir']}/registry"`|
|`['docker-grid']['registry']['docker-compose']['host_data_volume']`|String|Data directory path on the host filesystem or `nil` (unset).|`'/var/lib/docker-registry'`|
|`['docker-grid']['registry']['docker-compose']['config_format_version']`|String|`docker-compose.yml` format version. `'1'` or `'2'`|`'1'`|
|`['docker-grid']['registry']['docker-compose']['service_name']`|String|Docker registry service name in the `docker-compose.yml`|`'registry'`|
|`['docker-grid']['registry']['docker-compose']['config']`|Hash|`docker-compose.yml` configurations. See attributes/default.rb and [_Deploying a registry server_](https://docs.docker.com/registry/deploying/#/managing-with-compose) |See `attributes/default.rb`|
|`['docker-grid']['registry']['docker-compose']['registry-config']`|Hash|See [_Overriding the entire configuration file_](https://docs.docker.com/registry/configuration/#/overriding-the-entire-configuration-file)|`nil`|

## Usage

### Recipes

#### docker-grid::default

This recipe does nothing.

#### docker-grid::compose

This recipe installs docker-compose.

#### docker-grid::engine

This recipe sets up Docker engine.

#### docker-grid::registry

This recipe sets up Docker Compose configurations for the Docker registry service.

#### docker-grid::registry-docker-compose

This recipe is alias of the `docker-grid::registry` recipe.

#### docker-grid::registry-server

This recipe sets up a Docker registry service on real host.

### Role Examples

- `roles/docker.rb`:  installs the `docker-engine` package.

```ruby
name 'docker'
description 'Docker Engine distributed by dockerproject'

run_list(
  'recipe[docker-grid::engine]',
)

override_attributes(
  'docker-grid' => {
    'install_flavor' => 'dockerproject',
    'engine' => {
      'version_on_centos' => '17.03.1.ce-1',
      'version_on_debian' => '17.03.1~ce-0',
      'version_on_ubuntu' => '17.03.1~ce-0',
      'storage-driver_on_centos' => 'overlay',
      'storage-driver_on_debian' => 'overlay2',
      'storage-driver_on_ubuntu' => 'overlay2',  # default: 'aufs'
      #'userns-remap' => 'default',  # default: nil (inactive)
      'daemon_extra_options' => '-H fd:// --bip=192.168.128.1/24 --fixed-cidr=192.168.128.0/24',
    },
  },
)
```

- `roles/docker-rhel.rb`:  installs the `docker` package.

```ruby
name 'docker-rhel'
description 'Docker Engine distributed by RHEL'

run_list(
  'recipe[docker-grid::engine]',
)

override_attributes(
  'docker-grid' => {
    'install_flavor' => 'os-repository',
    'engine' => {
      'version_on_centos' => '1.12.5-14',  # docker package
      'version_on_ubuntu' => '1.12.3-0ubuntu4~16.04.2',  # docker.io package
      'storage-driver_on_centos' => 'overlay',
      'storage-driver_on_ubuntu' => 'overlay',  # default: aufs
      #'userns-remap' => 'default',
      'daemon_extra_options' => '-H fd://',
      # for RHEL docker package >= 1.12: '-H fd://' option automatically removed by this cookbook.
      # See https://github.com/docker/docker/issues/22847
    },
  },
)
```

- `roles/docker-ubuntu.rb`: installs the `docker.io` package.

```ruby
name 'docker-ubuntu'
description 'Docker Engine distributed by Ubuntu'

run_list(
  'recipe[docker-grid::engine]',
)

override_attributes(
  'docker-grid' => {
    'install_flavor' => 'os-repository',
    'engine' => {
      'version_on_centos' => '1.12.5-14',  # docker package
      'version_on_ubuntu' => '1.12.3-0ubuntu4~16.04.2',  # docker.io package
      'storage-driver_on_centos' => 'overlay',
      'storage-driver_on_ubuntu' => 'overlay',  # default: aufs
      #'userns-remap' => 'default',
      'daemon_extra_options' => '-H fd://',
    },
  },
)
```

- `roles/docker-registry.rb`: on Docker.

```ruby
name 'docker-registry'
description 'Docker Registry Server'

run_list(
  'recipe[docker-grid::registry]',
)

override_attributes(
  'docker-grid' => {
    'engine' => {
      'version_on_centos' => '17.03.1.ce-1',
      'version_on_debian' => '17.03.1~ce-0',
      'version_on_ubuntu' => '17.03.1~ce-0',
      'storage-driver_on_centos' => 'overlay',
      'storage-driver_on_debian' => 'overlay2',
      'storage-driver_on_ubuntu' => 'overlay2',  # default: 'aufs'
      'userns-remap' => '',
      'daemon_extra_options' => \
        '-H fd:// --bip=192.168.128.1/24 --fixed-cidr=192.168.128.0/24', \
        # for development environment only.
        #+ ' --insecure-registry registry.docker.example.com:5000',
    },
    'registry' => {
      'docker-compose' => {
        'config_format_version' => '1',
        'host_data_volume' => nil,
        'config' => {
          # in docker-compose.yml
          # See: https://docs.docker.com/registry/deploying/#/managing-with-compose
          'registry' => {
            'restart' => 'always',
            'image' => 'registry:2',
            'ports' => [
              '5000:5000',
            ],
            'environment' => {
              'REGISTRY_HTTP_TLS_CERTIFICATE' => '/certs/domain.crt',
              'REGISTRY_HTTP_TLS_KEY' =>         '/certs/domain.key',
              'REGISTRY_AUTH' =>                'htpasswd',
              'REGISTRY_AUTH_HTPASSWD_PATH' =>  '/auth/htpasswd',
              'REGISTRY_AUTH_HTPASSWD_REALM' => 'Registry Realm',
            },
            'volumes' => [
              '/path/data:/var/lib/registry',
              '/path/certs:/certs',
              '/path/auth:/auth',
            ],
          },
        },
      },
    },
  },
)
```

- `roles/docker-registry-with-ssl-cert.rb`: on Docker.

```ruby
name 'docker-registry-with-ssl-cert'
description 'Docker Registry Server'

registry_fqdn = 'registry.docker.example.com'

run_list(
  #'recipe[ssl_cert::server_key_pairs]',  # docker-grid <= 0.3.9
  'recipe[docker-grid::registry]',
)

override_attributes(
  'ssl_cert' => {
    'common_names' => [
      registry_fqdn,
    ],
  },
  'docker-grid' => {
    'engine' => {
      'version_on_centos' => '17.03.1.ce-1',
      'version_on_debian' => '17.03.1~ce-0',
      'version_on_ubuntu' => '17.03.1~ce-0',
      'storage-driver_on_centos' => 'overlay',
      'storage-driver_on_debian' => 'overlay2',
      'storage-driver_on_ubuntu' => 'overlay2',  # default: 'aufs'
      'userns-remap' => '',
      'daemon_extra_options' => \
        '-H fd:// --bip=192.168.128.1/24 --fixed-cidr=192.168.128.0/24',
    },
    'registry' => {
      'with_ssl_cert_cookbook' => true,
      'ssl_cert' => {
        'common_name' => registry_fqdn,
      },
      'docker-compose' => {
        'config_format_version' => '1',
        'host_data_volume' => nil,
        'config' => {
          # in docker-compose.yml
          # See: https://docs.docker.com/registry/deploying/#/managing-with-compose
          'registry' => {
            'restart' => 'always',
            'image' => 'registry:2',
            'ports' => [
              '5000:5000',
            ],
            'environment' => {
              # REGISTRY_HTTP_TLS_{CERTIFICATE,KEY} will be set automatically.
              'REGISTRY_AUTH' =>                'htpasswd',
              'REGISTRY_AUTH_HTPASSWD_PATH' =>  '/auth/htpasswd',
              'REGISTRY_AUTH_HTPASSWD_REALM' => 'Registry Realm',
              # proxy cache
              #'REGISTRY_PROXY_REMOTEURL' => 'https://registry-1.docker.io',
            },
            'volumes' => [
              # Volumes for the server certificate and key files will be set automatically.
              '/path/data:/var/lib/registry',
              '/path/auth:/auth',
            ],
          },
        },
      },
    },
  },
)
```

- `roles/docker-registry-by-entire-config.rb`: on Docker.

```ruby
name 'docker-registry-by-entire-config'
description 'Docker Registry Server'

run_list(
  'recipe[docker-grid::registry]',
)

override_attributes(
  'docker-grid' => {
    'engine' => {
      'version_on_centos' => '17.03.1.ce-1',
      'version_on_debian' => '17.03.1~ce-0',
      'version_on_ubuntu' => '17.03.1~ce-0',
      'storage-driver_on_centos' => 'overlay',
      'storage-driver_on_debian' => 'overlay2',
      'storage-driver_on_ubuntu' => 'overlay2',  # default: 'aufs'
      'userns-remap' => '',
      'daemon_extra_options' => \
        '-H fd:// --bip=192.168.128.1/24 --fixed-cidr=192.168.128.0/24', \
        # for development environment only.
        #+ ' --insecure-registry registry.docker.example.com:5000',
    },
    'registry' => {
      'docker-compose' => {
        'registry-config' => {
          # NOT nil
          # in ./etc/config.yml
          # See: https://docs.docker.com/registry/configuration/#/overriding-the-entire-configuration-file
          'version' => '0.1',
          # ...
        },
        'config_format_version' => '1',
        'config' => {
          # in ./docker-compose.yml
          # See: https://docs.docker.com/registry/deploying/#/managing-with-compose
          'registry' => {
            'restart' => 'always',
            'image' => 'registry:2',
            'ports' => [
              '5000:5000',
            ],
            'environment' => {
              # -> ./etc/config.yml
            },
            'volumes' => [
              # Volumes for the ./etc/config.yml will be set automatically.
              #'./etc/config.yml:/etc/docker/registry/config.yml:ro',
              '/path/data:/var/lib/registry',
              '/path/auth:/auth',
            ],
          },
        },
      },
    },
  },
)
```

- `roles/registry-server-with-ssl-cert.rb`: on real host.

```ruby
name 'registry-server-with-ssl-cert'
description 'Docker Registry Server'

registry_fqdn = 'registry.docker.example.com'

run_list(
  'recipe[docker-grid::registry-server]',
)

override_attributes(
  'ssl_cert' => {
    'common_names' => [
      registry_fqdn,
    ],
  },
  'docker-grid' => {
    'registry' => {
      'with_ssl_cert_cookbook' => true,
      'ssl_cert' => {
        'common_name' => registry_fqdn,
      },
      'server' => {
        'config' => {
          'storage' => {
            'filesystem' => {
              'rootdirectory' => '/var/lib/docker-registry',
            },
          },
          'proxy' => {
            'remoteurl' => 'https://registry-1.docker.io',
          },
        },
      },
    },
  },
)
```

### SSL server keys and certificates management by `ssl_cert` cookbook

- create vault items.

```text
$ ruby -rjson -e 'puts JSON.generate({"private" => File.read("registry.docker.example.com.prod.key")})' \
> > ~/tmp/registry.docker.example.com.prod.key.json

$ ruby -rjson -e 'puts JSON.generate({"public" => File.read("registry.docker.example.com.prod.crt")})' \
> > ~/tmp/registry.docker.example.com.prod.crt.json

$ cd $CHEF_REPO_PATH

$ knife vault create ssl_server_keys registry.docker.example.com.prod \
> --json ~/tmp/registry.docker.example.com.prod.key.json

$ knife vault create ssl_server_certs registry.docker.example.com.prod \
> --json ~/tmp/registry.docker.example.com.prod.crt.json
```

- grant reference permission to the Docker Registry host

```text
$ knife vault update ssl_server_keys  registry.docker.example.com.prod -S 'name:registry-host.example.com'
$ knife vault update ssl_server_certs registry.docker.example.com.prod -S 'name:registry-host.example.com'
```

- modify run_list and attributes

```ruby
run_list(
  #'recipe[ssl_cert::server_key_pairs]',  # docker-grid <= 0.3.9
  'recipe[docker-grid::registry]',
)

override_attributes(
  'ssl_cert' => {
    'common_names' => [
      'registry.docker.example.com',
    ],
  },
  'docker-grid' => {
    'registry' => {
      'with_ssl_cert_cookbook' => true,
      'ssl_cert' => {
        'common_name' => 'registry.docker.example.com',
      },
      # ...
    },
  },
)
```

## License and Authors

- Author:: whitestar at osdn.jp

```text
Copyright 2016-2017, whitestar

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
