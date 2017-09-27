#
# Cookbook Name:: docker-grid
# Recipe:: registry
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

doc_url = 'https://docs.docker.com/registry/deploying/#/managing-with-compose'

include_recipe 'docker-grid::compose'

app_dir = node['docker-grid']['registry']['docker-compose']['app_dir']
auth_dir = "#{app_dir}/auth"
etc_dir = "#{app_dir}/etc"
[
  app_dir,
  auth_dir,
  etc_dir,
].each {|dir|
  resources(directory: dir) rescue directory dir do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
  end
}

envs = {}
vols = []

host_data_volume = node['docker-grid']['registry']['docker-compose']['host_data_volume']
unless host_data_volume.nil?
  directory host_data_volume do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
  end

  vols.push("#{host_data_volume}:/var/lib/registry")
end

if node['docker-grid']['registry']['with_ssl_cert_cookbook']
  ::Chef::Recipe.send(:include, SSLCert::Helper)
  cn = node['docker-grid']['registry']['ssl_cert']['common_name']
  append_server_ssl_cn(cn)
  include_recipe 'ssl_cert::server_key_pairs'

  envs['REGISTRY_HTTP_TLS_CERTIFICATE'] = '/certs/domain.crt'
  envs['REGISTRY_HTTP_TLS_KEY'] = '/certs/domain.key'
  vols.push("#{server_cert_path(cn)}:/certs/domain.crt:ro")
  vols.push("#{server_key_path(cn)}:/certs/domain.key:ro")
end

unless node['docker-grid']['registry']['docker-compose']['registry-config'].nil?
  template "#{app_dir}/etc/config.yml" do
    source  'opt/docker-compose/app/registry/etc/config.yml'
    owner 'root'
    group 'root'
    mode '0644'
  end

  vols.push('./etc/config.yml:/etc/docker/registry/config.yml:ro')
end

service_name = node['docker-grid']['registry']['docker-compose']['service_name']
version_1_config = {
  service_name => {
  },
}

version_1_config[service_name]['environment'] = envs unless envs.empty?
version_1_config[service_name]['volumes'] = vols unless vols.empty?

version_2_config = {
  'services' => version_1_config,
}

node.override['docker-grid']['registry']['docker-compose']['config'] = \
  node['docker-grid']['registry']['docker-compose']['config_format_version'] == '2' ? version_2_config : version_1_config

[
  'docker-compose.yml',
].each {|conf_file|
  template "#{app_dir}/#{conf_file}" do
    source  "opt/docker-compose/app/registry/#{conf_file}"
    owner 'root'
    group 'root'
    mode '0644'
  end
}

log <<-"EOM"
Note: You must execute the following command manually.
  See #{doc_url}
  * Start:
    $ cd #{app_dir}
    $ docker-compose up -d
  * Stop
    $ docker-compose down
EOM
