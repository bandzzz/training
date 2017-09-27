#
# Cookbook Name:: docker-grid
# Recipe:: engine
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

# https://dcos.io/docs/1.8/administration/installing/custom/system-requirements/

install_flavor = node['docker-grid']['install_flavor']
platform = node['platform']
platform_family = node['platform_family']
platform_version = node['platform_version']

if node['docker-grid']['engine']['skip_setup']
  log 'Skip the Docker Engine setup.'
  return
end

::Chef::Recipe.send(:include, PlatformUtils::Helper)
::Chef::Recipe.send(:include, PlatformUtils::VirtUtils)

docker_ver = node['docker-grid']['engine']['version']
docker_ver = '' if docker_ver.nil?

[
  'bridge-utils',
].each {|pkg|
  resources(package: pkg) rescue package pkg do
    action :install
  end
}

bash 'systemctl_daemon-reload' do
  code <<-EOH
    systemctl daemon-reload
  EOH
  action :nothing
end

# https://docs.docker.com/engine/userguide/storagedriver/selectadriver/
if shell_out("cat /etc/mtab | grep -E '\s+/\s+zfs\s+'").exitstatus.zero?
  if container_guest_node?
    Chef::Log.warn('This node is running in the Linux container with ZFS, set the storage-driver to vfs as a fallback.')
    node.override['docker-grid']['engine']['storage-driver'] = 'vfs'
  else
    Chef::Log.warn('This node is running on ZFS, set the storage-driver to zfs.')
    node.override['docker-grid']['engine']['storage-driver'] = 'zfs'
  end
end

storage_driver = node['docker-grid']['engine']['storage-driver']

if storage_driver == 'overlay2'
  if !docker_ver.empty? && Gem::Version.create(docker_ver.tr('~', '-')) < Gem::Version.create('1.12')
    # tr('~', '-') for Ubuntu.
    Chef::Application.fatal!('Docker version must be 1.12 or later for overlay2 storage driver.')  # and exit.
  end
end
load_kernel_module('overlay') if storage_driver =~ /overlay2?/

userns_remap = node['docker-grid']['engine']['userns-remap']
if !userns_remap.nil? && !userns_remap.empty?
  if !docker_ver.empty? && Gem::Version.create(docker_ver.tr('~', '-')) < Gem::Version.create('1.10')
    # tr('~', '-') for Ubuntu.
    Chef::Application.fatal!('Docker version must be 1.10 or later for userns-remap.')  # and exit.
  end

  include_recipe 'platform_utils::kernel_user_namespace'

  remap_user = userns_remap == 'default' ? 'dockremap' : userns_remap
  notifies_conf = {
    'action' => :restart,
    'resource' => 'service[docker]',
    'timer' => :delayed,
  }
  ::Chef::Recipe.send(:include, PlatformUtils::Helper)
  append_subusers([remap_user], notifies_conf)
end

bash 'clean_up_docker0_bridge' do
  code <<-"EOH"
    if brctl show | grep docker0; then
      ip link set docker0 down
      brctl delbr docker0
    fi
    # https://github.com/docker/docker/issues/23630
    if [ -d /var/lib/docker/network ]; then
      rm -rf /var/lib/docker/network
    fi
  EOH
  action :nothing
end

case platform_family
when 'rhel'
  if install_flavor == 'dockerproject'
    # https://dcos.io/docs/1.8/administration/installing/custom/system-requirements/install-docker-centos/
    template '/etc/yum.repos.d/docker.repo' do
      source  'etc/yum.repos.d/docker.repo'
      owner 'root'
      group 'root'
      mode '0644'
    end

    [
      'docker',
      'container-selinux',
      'docker-common',
    ].each {|pkg|
      resources(package: pkg) rescue package pkg do
        action :remove
        notifies :run, 'bash[clean_up_docker0_bridge]', :immediately
      end
    }

    [
      'docker-engine-selinux',
      'docker-engine',
    ].each {|pkg|
      resources(yum_package: pkg) rescue yum_package pkg do
        allow_downgrade true
        action :install
        version docker_ver unless docker_ver.empty?
        # dockerrepo is disabled by default to prevent automatic update.
        options '--enablerepo=dockerrepo'
        notifies :run, 'bash[clean_up_docker0_bridge]', :before if pkg == 'docker-engine'
      end
    }
  else
    # OS distribution
    [
      'docker-engine-selinux',
      'docker-engine',
    ].each {|pkg|
      resources(package: pkg) rescue package pkg do
        action :remove
        notifies :run, 'bash[clean_up_docker0_bridge]', :immediately
      end
    }

    file '/etc/systemd/system/docker.service.d/override.conf' do
      action :delete
    end

    [
      'docker',
    ].each {|pkg|
      resources(yum_package: pkg) rescue yum_package pkg do
        allow_downgrade true
        action :install
        version docker_ver unless docker_ver.empty?
        notifies :run, 'bash[clean_up_docker0_bridge]', :before
      end
    }

    template '/etc/sysconfig/docker' do
      source  'etc/sysconfig/docker'
      owner 'root'
      group 'root'
      mode '0644'
      notifies :restart, 'service[docker]'
    end
  end
when 'debian'
  # https://docs.docker.com/engine/installation/linux/debian/
  # https://docs.docker.com/engine/installation/linux/ubuntulinux/
  pkgs = [
    'apt-transport-https',
    'ca-certificates',
    'curl',
    'gnupg2',
    'software-properties-common',
  ]

  if storage_driver == 'aufs' \
    && !container_guest_node?
    if platform == 'debian'
      pkgs += [
        'aufs-dkms',
      ]
    elsif platform == 'ubuntu'
      pkgs += [
        "linux-image-extra-#{node['os_version']}",
        'linux-image-extra-virtual',
      ]
    end
  end

  pkgs.each {|pkg|
    resources(package: pkg) rescue package pkg do
      action :install
    end
  }

  apt_get_update = 'apt-get_update'
  resources(execute: apt_get_update) rescue execute apt_get_update do
    command 'apt-get update'
    action :nothing
  end

  if install_flavor == 'dockerproject'
    pkg_name_removed = 'docker.io'
    pkg_name = node['docker-grid']['dockerproject']['package_name']

    apt_repo_config = node['docker-grid']['apt_repo']
    bash 'apt-key_adv_docker_tools_key' do
      code <<-"EOH"
        apt-key adv --keyserver #{apt_repo_config['keyserver']} --recv-keys #{apt_repo_config['recv-keys']}
        #apt-get update
      EOH
      action :nothing
      not_if 'apt-key list | grep -i docker'
    end

    template '/etc/apt/sources.list.d/docker.list' do
      source  'etc/apt/sources.list.d/docker.list'
      owner 'root'
      group 'root'
      mode '0644'
      notifies :run, 'bash[apt-key_adv_docker_tools_key]', :before
      notifies :run, "execute[#{apt_get_update}]", :immediately
    end
  else
    # OS distribution
    pkg_name_removed = node['docker-grid']['dockerproject']['package_name']
    pkg_name = 'docker.io'
  end

  # Pinning Docker version
  template '/etc/apt/preferences.d/docker.pref' do
    source  'etc/apt/preferences.d/docker.pref'
    owner 'root'
    group 'root'
    mode '0644'
    action :delete if docker_ver.empty?
    variables(
      pkg_name: pkg_name
    )
  end

  resources(package: pkg_name_removed) rescue package pkg_name_removed do
    action :remove
    notifies :run, 'bash[clean_up_docker0_bridge]', :immediately
  end

  resources(package: pkg_name) rescue package pkg_name do
    action :install
    options '--allow-downgrades' if platform == 'debian' || platform_version >= '16.04'  # LTS (xenial)
    options '--force-yes' if platform_version == '14.04'  # LTS (trusty)
    version docker_ver unless docker_ver.empty?
    notifies :run, 'bash[clean_up_docker0_bridge]', :before
  end
end

docker_opts = []

storage_driver = node['docker-grid']['engine']['storage-driver']
docker_opts.push("--storage-driver=#{storage_driver}") if !storage_driver.nil? && !storage_driver.empty?

userns_remap = node['docker-grid']['engine']['userns-remap']
docker_opts.push("--userns-remap=#{userns_remap}") if !userns_remap.nil? && !userns_remap.empty?

extra_options = node['docker-grid']['engine']['daemon_extra_options']
# for docker-engine package on RHEL: remove '-H fd://'
# https://github.com/docker/docker/issues/22847
if platform_family == 'rhel' || platform == 'debian' || (platform == 'ubuntu' && platform_version == '14.04')
  # Note: docker_ver.empty? -> the latest version
  if docker_ver.empty? \
    || Gem::Version.create(docker_ver.tr('~', '-')) >= Gem::Version.create('1.12')
    extra_options = extra_options.gsub(%r{-H\sfd://}, '')  # for frozen string.
  end
end

docker_opts.push(extra_options) if !extra_options.nil? && !extra_options.empty?

init_package = node['init_package']
if init_package == 'systemd'
  directory '/etc/systemd/system/docker.service.d' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end

  template '/etc/systemd/system/docker.service.d/override.conf' do
    source  'etc/systemd/system/docker.service.d/override.conf'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      docker_opts: docker_opts
    )
    not_if { install_flavor == 'os-repository' && platform_family == 'rhel' }
    notifies :run, 'bash[systemctl_daemon-reload]', :immediately
    notifies :restart, 'service[docker]'
  end
elsif init_package == 'init'  # for Ubuntu 14.04,...
  template '/etc/default/docker' do
    source  'etc/default/docker'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      docker_opts: docker_opts
    )
    notifies :restart, 'service[docker]'
  end
end

service 'docker' do
  provider Chef::Provider::Service::Upstart if platform == 'ubuntu' && platform_version < '15.04'
  action [:start, :enable]
  subscribes :restart, 'execute[update-ca-certificates]', :delayed
end

users = node['docker-grid']['engine']['users_allow']
group 'docker' do
  members users unless users.empty?
  action :create
  append true
end

# utility scripts
[
  'docker_images_cleanup',
  'docker_volumes_cleanup',
].each {|script|
  template "/usr/local/bin/#{script}" do
    source  "usr/local/bin/#{script}"
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
}
