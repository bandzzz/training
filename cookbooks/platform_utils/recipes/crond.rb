#
# Cookbook Name:: platform_utils
# Recipe:: crond
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

::Chef::Recipe.send(:include, PlatformUtils::PackageUtils)

pkg = cron_pkg_name
resources(package: pkg) rescue package pkg do
  action :install
end

serv = cron_serv_name
resources(service: serv) rescue service serv do
  action [:enable, :start]
  supports status: true, restart: true, reload: false
end
