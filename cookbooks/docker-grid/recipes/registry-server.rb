#
# Cookbook Name:: docker-grid
# Recipe:: registry-server
#
# Copyright 2017, whitestar
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

package 'docker-registry' do
  action :install
end

service_name = node.value_for_platform(
  ['centos', 'redhat'] => {
    'default' => 'docker-distribution',
  },
  ['debian', 'ubuntu'] => {
    'default' => 'docker-registry',
  }
)

service service_name do
  action [:enable, :start]
  supports status: true, restart: true, reload: false
end

directory '/etc/docker' do
  owner 'root'
  group 'root'
  mode '0755'  # workaround: this directory mode is modified to 700 for containig key.json file.
  action :create
  only_if { Dir.exist?('/etc/docker') }
end

config = node['docker-grid']['registry']['server']['config']
override_config = node.override['docker-grid']['registry']['server']['config']

service_owner = node.value_for_platform(
  ['centos', 'redhat'] => {
    'default' => 'root',
  },
  ['debian', 'ubuntu'] => {
    'default' => 'docker-registry',
  }
)

directory config['storage']['filesystem']['rootdirectory'] do
  owner service_owner
  group service_owner
  mode '0755'
  action :create
  recursive true
end

if node['docker-grid']['registry']['with_ssl_cert_cookbook']
  ::Chef::Recipe.send(:include, SSLCert::Helper)
  cn = node['docker-grid']['registry']['ssl_cert']['common_name']
  append_server_ssl_cn(cn)
  include_recipe 'ssl_cert::server_key_pairs'

  append_members_to_key_access_group(service_owner)
  override_config['http']['tls']['certificate'] = server_cert_path(cn)
  override_config['http']['tls']['key'] = server_key_path(cn)
end

conf_dir = node.value_for_platform(
  ['centos', 'redhat'] => {
    'default' => '/etc/docker-distribution/registry',
  },
  ['debian', 'ubuntu'] => {
    'default' => '/etc/docker/registry',
  }
)

template "#{conf_dir}/config.yml" do
  source  'etc/docker/registry/config.yml'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, "service[#{service_name}]"
end
