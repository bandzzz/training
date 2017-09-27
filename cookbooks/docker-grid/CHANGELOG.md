# docker-grid CHANGELOG

0.5.3
-----
- improves server key pair deployment for a Docker registry service.

0.5.2
-----
- adds the `docker_volumes_cleanup` script.

0.5.1
-----
- improves `docker-compose` installation.

0.5.0
-----
- adds the `docker-grid::registry-server` and `docker-grid::registry-docker-compose` recipes.

0.4.0
-----
- includes the `ssl_cert::server_key_pairs` recipe automatically.
- refactoring.

0.3.9
-----
- adds the Debian 9 (stretch) support.
- adds the `docker_images_cleanup` script.
- adds the Concourse pipeline configuration.

0.3.8
-----
- supports the latest Docker engine (17.03.1.ce-1, 17.03.1~ce-0).

0.3.7
-----
- supports the feature to specify no Docker version.

0.3.6
-----
- Bug fix: Ubuntu 14.04 LTS support.

0.3.5
-----
- adds the `['docker-grid']['engine']['skip_setup']` attribute.
- adds the `['docker-grid']['compose']['skip_setup']` attribute.

0.3.4
-----
- improves CentOS distributed `docker` package support.

0.3.3
-----
- adds OS distributed Docker Engine package support.
- adds the `['docker-grid']['install_flavor']` attribute.

0.3.2
-----
- refactoring.

0.3.1
-----
- bug fix: `systemctl daemon-reload` timing.
- adds the storage-driver automatic modifier for ZFS.

0.3.0
-----
- adds `Docker in LXD` support.

0.2.9
-----
- refactoring.
- adds the `platform_utils` cookbook dependency.

0.2.8
-----
- adds the `['docker-grid']['registry']['docker-compose']['host_data_volume']` attribute.

0.2.7
-----
- adds the `['docker-grid']['compose']['home_dir']` attribute.
- adds the `['docker-grid']['compose']['app_dir']` attribute.

0.2.6
-----
- bug fix: modifies `apt-get update` timing for the updated apt-line on Ubuntu.

0.2.5
-----
- adds `docker` service's handling of CA certificate update events.

0.2.4
-----
- improves the `docker-grid::registry` recipe.
- adds the `['docker-grid']['registry']['docker-compose']['config_format_version']` attribute. 
- adds the `['docker-grid']['registry']['docker-compose']['service_name']` attribute. 

0.2.3
-----
- adds the `docker-grid::registry` recipe.
- adds the `ssl_cert` cookbook dependency.
- adds the `['docker-grid']['apt_repo']['override_apt_line']` attribute.

0.2.2
-----
- adds the `docker-grid::compose` recipe.
- adds the `['docker-grid']['engine']['users_allow']` attribute.
- refactoring.

0.2.1
-----
- refactoring.

0.2.0
-----
- adds the `['docker-grid']['engine']['userns-remap']` attribute.

0.1.0
-----
- Initial release of docker-grid
