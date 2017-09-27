#
# Cookbook Name:: platform_utils
# Recipe:: sudo
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

%w(
  sudo
).each {|pkg|
  resources(package: pkg) rescue package pkg do
    action :install
  end
}

node['platform_utils']['sudo']['sudoers.d'].each {|sudoers_file, lines|
  template "/etc/sudoers.d/#{sudoers_file}" do
    source  'etc/sudoers.d/sudoers'
    owner 'root'
    group 'root'
    mode '0440'
    variables(
      lines: lines
    )
  end
}

sudo_group = value_for_platform_family(
  'debian' => 'sudo',
  'rhel' => 'wheel'
)
sudo_members = node['platform_utils']['sudo']['group']['members']

group "append_#{sudo_members.join('_')}_to_#{sudo_group}_group" do
  group_name sudo_group
  action :modify
  members sudo_members
  append true
end unless sudo_members.empty?
