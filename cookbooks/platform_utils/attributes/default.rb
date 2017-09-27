#
# Cookbook Name:: platform_utils
# Attributes:: default
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

default['platform_utils']['kernel_modules']['loaded_modules'] = []

default['platform_utils']['platform_update']['auto_update'] = true
default['platform_utils']['platform_update']['timer'] = :delayed
default['platform_utils']['platform_update']['apt-get']['command'] = 'apt-get upgrade -y'
default['platform_utils']['platform_update']['yum']['command'] = 'yum update -y'

default['platform_utils']['subid']['users'] = []
default['platform_utils']['subid']['notifies'] = [
=begin
  # multiple notifies
  [
    :restart,
    'service[docker]',
    :immediately,  # option, default: :delayed
  ],
  # or
  {
    'action' => :restart,
    'resource' => 'service[docker]',
    'timer' => :immediately,  # option, default: :delayed
  },
=end
]
=begin
# single notifies
# or
[
  :restart,
  'service[docker]',
  :immediately,  # option, default: :delayed
],
# or
{
  'action' => :restart,
  'resource' => 'service[docker]',
  'timer' => :immediately,  # option, default: :delayed
},
=end

default['platform_utils']['sudo']['sudoers.d'] = {
  #'file_name' => [
  #  'each_line',
  #]
}
default['platform_utils']['sudo']['group']['members'] = []

default['platform_utils']['sysctl']['configs'] = {
=begin
  '80-by_chef' => {
    'action' => :create,
    'params' => {
      'key' => 'value',
    },
  },
  '88-unwanted' => {
    'action' => :delete,
  },
=end
}

default['platform_utils']['tcp_wrappers']['hosts_allow'] = []
default['platform_utils']['tcp_wrappers']['hosts_deny'] = []
