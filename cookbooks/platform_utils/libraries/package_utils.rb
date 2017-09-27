#
# Cookbook Name:: platform_utils
# Library:: PackageUtils
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

module PlatformUtils
  # Package utilities methods
  module PackageUtils
    def cron_pkg_name
      case node['platform_family']
      when 'debian'then return 'cron'
      when 'rhel'  then return 'crontabs'
      end
    end

    def cron_serv_name
      case node['platform_family']
      when 'debian'then return 'cron'
      when 'rhel'  then return 'crond'
      end
    end

    def httpd_pkg_name
      case node['platform_family']
      when 'debian'then return 'apache2'
      when 'rhel'  then return 'httpd'
      end
    end

    def httpd_serv_name
      case node['platform_family']
      when 'debian'then return 'apache2'
      when 'rhel'  then return 'httpd'
      end
    end

    def jsvc_pkg_name
      case node['platform_family']
      when 'debian' then return 'jsvc'
      when 'rhel'   then return 'jakarta-commons-daemon-jsvc'
      end
    end

    def libbz2_pkg_name
      case node['platform_family']
      when 'debian' then return 'libbz2-1.0'
      when 'rhel'   then return 'bzip2-libs'
      end
    end
  end
end
