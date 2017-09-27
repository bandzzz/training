#
# Cookbook Name:: platform_utils
# Recipe:: platform_update
#
# Copyright 2016, whitestar
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

require 'shellwords'

::Chef::Recipe.send(:include, PlatformUtils::Helper)

if node['platform_utils']['platform_update']['auto_update']
  timer = node['platform_utils']['platform_update']['timer']
  execute_name = nil
  execute_command = nil

  case node['platform_family']
  when 'debian' then
    update_command = node['platform_utils']['platform_update']['apt-get']['command']
    words = Shellwords.split(update_command)
    unless words[0] == 'apt-get'
      Chef::Log.fatal('You must use apt-get command.')
      raise
    end
    validate_shellwords(words)

    execute_name = 'apt-get_upgrade'
    execute_command = "apt-get update; #{update_command}"
  when 'rhel' then
    update_command = node['platform_utils']['platform_update']['yum']['command']
    words = Shellwords.split(update_command)
    unless words[0] == 'yum'
      Chef::Log.fatal('You must use yum command.')
      raise
    end
    validate_shellwords(words)

    execute_name = 'yum_update'
    execute_command = update_command
  end

  log "execute execute[#{execute_name}], #{timer}" do
    notifies :run, "execute[#{execute_name}]", timer
  end

  execute execute_name do
    user 'root'
    command execute_command
    action :nothing
  end
end
