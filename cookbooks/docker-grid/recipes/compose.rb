#
# Cookbook Name:: docker-grid
# Recipe:: compose
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

# See: https://docs.docker.com/compose/install/

install_flavor = node['docker-grid']['compose']['install_flavor']

if node['docker-grid']['compose']['skip_setup']
  log 'Skip the Docker Compose setup.'
  return
end

include_recipe 'docker-grid::engine'

home_dir = node['docker-grid']['compose']['home_dir']
app_dir = node['docker-grid']['compose']['app_dir']
[
  home_dir,
  app_dir,
].each {|dir|
  resources(directory: dir) rescue directory dir do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
  end
}

case install_flavor
when 'dockerproject'
  docker_compose_path = '/usr/local/bin/docker-compose'

  execute 'install_docker_compose' do
    user 'root'
    command "curl -L \"#{node['docker-grid']['compose']['release_url']}\" -o #{docker_compose_path} && chmod +x #{docker_compose_path}"
    action :run
    not_if { ::File.exist?(docker_compose_path) } unless node['docker-grid']['compose']['auto_upgrade']
  end
when 'os-repository'
  package 'docker-compose' do
    action :install
  end
end
