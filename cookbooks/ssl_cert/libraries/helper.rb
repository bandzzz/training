#
# Cookbook Name:: ssl_cert
# Library:: Helper
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

module SSLCert
  # Helper methods.
  module Helper
    def ssl_cert_pkg
      case node['platform_family']
      when 'debian'
        pkg = 'ssl-cert'
        resources(package: pkg) rescue package pkg do
          action :install
        end
      when 'rhel'
        enable_command = 'update-ca-trust_enable'
        resources(execute: enable_command) rescue execute enable_command do
          user 'root'
          command 'update-ca-trust enable'
          action :run
          only_if { node['platform_version'].to_i == 6 }
          only_if 'update-ca-trust check | grep DISABLED'
        end
      end
    end

    def get_private_key_group
      if node['ssl_cert']['rhel']['key_access_group'].nil? \
        || node['ssl_cert']['rhel']['key_access_group'].empty?
        node.override['ssl_cert']['rhel']['key_access_group'] = 'root'
      end

      node.value_for_platform_family(
        'debian'  => 'ssl-cert',
        'rhel'    => node['ssl_cert']['rhel']['key_access_group'],
        'default' => 'root'
      )
    end

    def get_private_key_mode
      node.value_for_platform_family(
        'debian'  => node['ssl_cert']['debian']['key_access_mode'],
        'rhel'    => node['ssl_cert']['rhel']['key_access_mode'],
        'default' => '0400'
      )
    end

    def append_members_to_key_access_group(mems)
      mems = [mems] if mems.is_a?(String)
      key_group = get_private_key_group
      if key_group == 'root'
        Chef::Log.warn('Skip member adding because the key access group is root.')
      else
        group "append_#{mems.join('_')}_to_#{key_group}_group" do
          group_name key_group
          system true
          action :create
          members mems
          append true
        end
      end
    end

    def chef_gem_chef_vault
      pkg = 'chef-vault'
      resources(chef_gem: pkg) rescue chef_gem pkg do
        compile_time true if respond_to?(:compile_time)
        clear_sources node['ssl_cert']['chef_gem']['clear_sources']
        source node['ssl_cert']['chef_gem']['source']
        options node['ssl_cert']['chef_gem']['options']
        version node['ssl_cert']['chef-vault']['version']
        action :install
      end
    end

=begin
    * Item conf example
    item_conf = {
      'vault' => 'concourse',
      'name' => 'web',
      # single password or nested hash password path delimited by slash
      'env_context' => false,
      'key' => 'password',  # real hash path: "/password"
      # or nested hash password path delimited by slash
      #'env_context' => true,
      #'key' => 'hash/path/to/password',  # real hash path: "/#{node.chef_environment}/hash/path/to/password"
    }
=end
    def get_vault_item_value(item_conf)
      chef_gem_chef_vault
      require 'chef-vault'
      secret = ChefVault::Item.load(item_conf['vault'], item_conf['name'])
      secret = secret[node.chef_environment] if item_conf.key?('env_context') && item_conf['env_context'] == true
      if !item_conf['key'].nil? && !item_conf['key'].empty?
        item_conf['key'].split('/').each do |elm| secret = secret[elm] end
      end

      secret
    end

    def vault_item_suffix
      suffix = \
        if !node['ssl_cert']['vault_item_suffix'].nil? && !node['ssl_cert']['vault_item_suffix'].empty?
          node['ssl_cert']['vault_item_suffix']
        else
          ''
        end

      suffix
    end

    def append_ca_name(ca_name)
      ca_names = node['ssl_cert']['ca_names'].to_a
      return if ca_names.include?(ca_name)

      ca_names.push(ca_name)
      node.override['ssl_cert']['ca_names'] = ca_names
      node.from_file(run_context.resolve_attribute('ssl_cert', 'default'))
      # workaround for `ssl_cert::ca_certs` recipe execution before the current recipe.
      ca_certificate(ca_name)
      Chef::Log.info("CA name #{ca_name} has been appended for CA certificate deployment.")
    end

    def ca_cert_src_path(ca)
      undotted_ca = ca.tr('.', '_')
      node['ssl_cert']["#{undotted_ca}_cert_src_path"]
    end

    def ca_cert_path(ca)
      undotted_ca = ca.tr('.', '_')
      node['ssl_cert']["#{undotted_ca}_cert_path"]
    end

    def ca_certificate(ca)
      ssl_cert_pkg

      chef_gem_chef_vault
      require 'chef-vault'
      cert = ChefVault::Item.load(
        node['ssl_cert']['ca_cert_vault'], "#{ca}#{vault_item_suffix}"
      )
      node['ssl_cert']['ca_cert_vault_item_key'].split('/').each {|elm|
        cert = cert[elm]
      }

      cert_path = ca_cert_src_path(ca)
      #cert_path = ca_cert_path(ca)
      cert_file_name = File.basename(cert_path)
      update_command_name = 'update-ca-certificates'
      update_command = ''

      resources(file: cert_path) rescue file cert_path do
        content cert
        owner 'root'
        group 'root'
        mode '0644'
        notifies :run, "execute[#{update_command_name}]", :delayed
      end

      case node['platform_family']
      when 'debian'
        execute "add_ca_cert_entry_#{cert_file_name}" do
          user 'root'
          command "echo #{cert_file_name} >> /etc/ca-certificates.conf"
          action :run
          not_if "cat /etc/ca-certificates.conf | grep #{cert_file_name}"
          notifies :run, "execute[#{update_command_name}]", :delayed
        end

        update_command = 'update-ca-certificates'
      when 'rhel'
        update_command = 'update-ca-trust extract'
      end

      resources(execute: update_command_name) rescue execute update_command_name do
        user 'root'
        command update_command
        action :nothing
      end
    end

    def ca_pubkey_path(ca)
      undotted_ca = ca.tr('.', '_')
      node['ssl_cert']["#{undotted_ca}_pubkey_path"]
    end

    def ca_public_key(ca)
      ssl_cert_pkg

      chef_gem_chef_vault
      require 'chef-vault'
      pubkey = ChefVault::Item.load(
        node['ssl_cert']['ca_pubkey_vault'], "#{ca}#{vault_item_suffix}"
      )
      node['ssl_cert']['ca_pubkey_vault_item_key'].split('/').each {|elm|
        pubkey = pubkey[elm]
      }

      pubkey_path = ca_pubkey_path(ca)
      resources(file: pubkey_path) rescue file pubkey_path do
        content pubkey
        owner 'root'
        group 'root'
        mode '0644'
      end
    end

    def ssh_ca_krl_path(ca)
      undotted_ca = ca.tr('.', '_')
      node['ssl_cert']["#{undotted_ca}_krl_path"]
    end

    def ssh_ca_krl(ca)
      ssl_cert_pkg

      chef_gem_chef_vault
      require 'chef-vault'
      krl = ChefVault::Item.load(
        node['ssl_cert']['ssh_ca_krl_vault'], "#{ca}#{vault_item_suffix}"
      )
      node['ssl_cert']['ssh_ca_krl_vault_item_key'].split('/').each {|elm|
        krl = krl[elm]
      }

      krl_path = ssh_ca_krl_path(ca)
      resources(file: krl_path) rescue file krl_path do
        content krl
        owner 'root'
        group 'root'
        mode '0644'
      end
    end

    def append_server_ssl_cn(cn)
      cns = node['ssl_cert']['common_names'].to_a
      return if cns.include?(cn)

      cns.push(cn)
      node.override['ssl_cert']['common_names'] = cns
      node.from_file(run_context.resolve_attribute('ssl_cert', 'default'))
      # workaround for `ssl_cert::server_key_pairs` recipe execution before the current recipe.
      server_certificate(cn)
      server_private_key(cn)
      Chef::Log.info("Common name #{cn} has been appended for server key pair deployment.")
    end

    def server_cert_path(cn)
      undotted_cn = cn.tr('.', '_')
      node['ssl_cert']["#{undotted_cn}_cert_path"]
    end

    def server_cert_content(cn)
      chef_gem_chef_vault

      require 'chef-vault'
      cert = ChefVault::Item.load(
        node['ssl_cert']['server_cert_vault'], "#{cn}#{vault_item_suffix}"
      )
      node['ssl_cert']['server_cert_vault_item_key'].split('/').each {|elm|
        cert = cert[elm]
      }

      cert
    end

    def server_certificate(cn)
      ssl_cert_pkg

      cert = server_cert_content(cn)
      cert_path = server_cert_path(cn)

      resources(file: cert_path) rescue file cert_path do
        content cert
        owner 'root'
        group 'root'
        mode '0644'
      end
    end

    def server_key_path(cn)
      undotted_cn = cn.tr('.', '_')
      node['ssl_cert']["#{undotted_cn}_key_path"]
    end

    def server_key_content(cn)
      chef_gem_chef_vault

      require 'chef-vault'
      secret = ChefVault::Item.load(
        node['ssl_cert']['server_key_vault'], "#{cn}#{vault_item_suffix}"
      )
      node['ssl_cert']['server_key_vault_item_key'].split('/').each {|elm|
        secret = secret[elm]
      }

      secret
    end

    def server_private_key(cn)
      ssl_cert_pkg

      secret = server_key_content(cn)
      key_path = server_key_path(cn)
      key_group = get_private_key_group
      key_mode = get_private_key_mode

      resources(group: key_group) rescue group key_group do
        system true
        action :create
        append true
        not_if { key_group == 'root' }
      end

      resources(file: key_path) rescue file key_path do
        content secret
        sensitive true
        owner 'root'
        group key_group
        mode key_mode
      end
    end
  end
end
