#
# Cookbook Name:: platform_utils
# Recipe:: kernel_user_namespace
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

reboot_msg = 'reboot_message'
resources(log: reboot_msg) rescue log reboot_msg do
  message 'Please reboot this machine because of kernel boot option modified.'
  level :warn
  action :nothing
end

# By default user namespace feature is inactive in RHEL family (>= 7.2).
if node['platform_family'] == 'rhel' && !container_guest_node?
  unless Gem::Version.create(node['platform_version']) >= Gem::Version.create('7.2')
    Chef::Application.fatal!('Platform version must be 7.2 or later for kernel user namespace feature.')  # and exit.
  end

  bash 'enable_user_namespace_feature_of_kernerl' do
    code <<-"EOH"
      grubby --args='user_namespace.enable=1' --update-kernel=/boot/vmlinuz-#{node['kernel']['release']}
    EOH
    not_if "grubby --info=/boot/vmlinuz-#{node['kernel']['release']} | grep 'user_namespace.enable=1'"
    notifies :write, "log[#{reboot_msg}]"
  end
end
