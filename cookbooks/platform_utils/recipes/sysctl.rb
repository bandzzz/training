#
# Cookbook Name:: platform_utils
# Recipe:: sysctl
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

::Chef::Recipe.send(:include, PlatformUtils::VirtUtils)

unless container_guest_node?
  node['platform_utils']['sysctl']['configs'].each {|file_name, conf|
    file_path = "/etc/sysctl.d/#{file_name}.conf"
    exec_name = "sysctl_-p_#{file_path}"

    resources(execute: exec_name) rescue execute exec_name do
      command "sysctl -p #{file_path}"
      action :nothing
    end

    resources(template: file_path) rescue template file_path do
      source 'etc/sysctl.d/template.conf'
      owner 'root'
      group 'root'
      mode '0644'
      variables(
        params: conf['params']
      )
      action conf['action'].to_sym
      notifies :run, "execute[#{exec_name}]", :immediately if conf['action'].to_sym == :create
    end
  }
end
