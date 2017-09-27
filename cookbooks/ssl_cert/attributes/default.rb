#
# Cookbook Name:: ssl_cert
# Attributes:: default
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

# debian key access group is 'ssl-cert'
default['ssl_cert']['debian']['key_access_mode'] = '0640'
default['ssl_cert']['rhel']['key_access_group'] = 'ssl-cert'
default['ssl_cert']['rhel']['key_access_mode'] = '0400'

# deployed CA certificates from chef-vault
default['ssl_cert']['ca_names'] = [
  #'grid_ca',
]

# deployed CA public keys from chef-vault
# for SSH-CA, ...
default['ssl_cert']['ca_pubkey_names'] = [
  #'grid_ssh_ca',
]

# deployed SSH-CA KRL (Key Revocation List) from chef-vault
default['ssl_cert']['ssh_ca_krl_name'] = nil  # e.g. 'grid_ssh_ca'

# deployed server keys and/or certificates from chef-vault
default['ssl_cert']['common_names'] = [
  #'ldap.grid.example.com',
]

# for chef-vault installation
default['ssl_cert']['chef_gem']['clear_sources'] = false
default['ssl_cert']['chef_gem']['source'] = nil
default['ssl_cert']['chef_gem']['options'] = nil
default['ssl_cert']['chef-vault']['version'] = '~> 2.6'

default['ssl_cert']['env_context'] = node.chef_environment
default['ssl_cert']['vault_item_suffix'] = \
  if !node['ssl_cert']['env_context'].nil? && !node['ssl_cert']['env_context'].empty?
    ".#{node['ssl_cert']['env_context']}"
  else
    ''
  end

# CA certificates attributes
default['ssl_cert']['ca_cert_vault'] = 'ca_certs'
default['ssl_cert']['ca_cert_vault_item_key'] = 'public'
default['ssl_cert']['ca_cert_file_prefix'] = ''
default['ssl_cert']['ca_cert_file_extension'] = 'crt'
=begin
 CA certificate vault item name is
   each CA name + ".#{node['ssl_cert']['vault_item_suffix']}".
 valut item key is 'public'.

 * vault item management

  $ ruby -rjson -e 'puts JSON.generate({"public" => File.read("grid_ca.prod.crt")})' \
  > > ~/tmp/grid_ca.prod.crt.json
  $ knife vault create ca_certs grid_ca.prod \
  > --json ~/tmp/grid_ca.prod.crt.json
=end

# CA public keys attributes
default['ssl_cert']['ca_pubkey_vault'] = 'ca_pubkeys'
default['ssl_cert']['ca_pubkey_vault_item_key'] = 'public'
default['ssl_cert']['ca_pubkey_file_prefix'] = ''
default['ssl_cert']['ca_pubkey_file_extension'] = 'pub'
=begin
 CA public key vault item name is
   each CA name + ".#{node['ssl_cert']['vault_item_suffix']}".
 valut item key is 'public'.

 * vault item management

  $ ruby -rjson -e 'puts JSON.generate({"public" => File.read("grid_ssh_ca.prod.pub")})' \
  > > ~/tmp/grid_ssh_ca.prod.pub.json
  $ knife vault create ca_pubkeys grid_ssh_ca.prod \
  > --json ~/tmp/grid_ssh_ca.prod.pub.json
=end

# SSH-CA KRL attributes
default['ssl_cert']['ssh_ca_krl_vault'] = 'ssh_ca_krls'
default['ssl_cert']['ssh_ca_krl_vault_item_key'] = 'public'
default['ssl_cert']['ssh_ca_krl_file_prefix'] = ''
default['ssl_cert']['ssh_ca_krl_file_extension'] = 'krl'
=begin
 SSH-CA KRL vault item name is
   each SSH-CA KRL name + ".#{node['ssl_cert']['vault_item_suffix']}".
 valut item key is 'public'.

 * vault item management

  $ ruby -rjson -e 'puts JSON.generate({"public" => File.read("grid_ssh_ca.prod.krl")})' \
  > > ~/tmp/grid_ssh_ca.prod.krl.json
  $ knife vault create ssh_ca_krls grid_ssh_ca.prod \
  > --json ~/tmp/grid_ssh_ca.prod.krl.json
=end

# SSL sever private key attributes
default['ssl_cert']['server_key_vault'] = 'ssl_server_keys'
default['ssl_cert']['server_key_vault_item_key'] = 'private'
default['ssl_cert']['server_key_file_prefix'] = ''
default['ssl_cert']['server_key_file_extension'] = 'key'
=begin
 server key vault item name is
   each common name + "#{node['ssl_cert']['vault_item_suffix']}".
 valut item key is 'private'.

 * vault item management

  $ ruby -rjson -e 'puts JSON.generate({"private" => File.read("node_example_com.prod.key")})' \
  > > ~/tmp/node_example_com.prod.key.json
  $ knife vault create ssl_server_keys node.example.com.prod \
  > --json ~/tmp/node_example_com.prod.key.json
=end

# SSL sever caertificates attributes
default['ssl_cert']['server_cert_vault'] = 'ssl_server_certs'
default['ssl_cert']['server_cert_vault_item_key'] = 'public'
default['ssl_cert']['server_cert_file_prefix'] = ''
default['ssl_cert']['server_cert_file_extension'] = 'crt'
=begin
 server certificate vault item name is
   each common name + ".#{node['ssl_cert']['vault_item_suffix']}".
 valut item key is 'public'.

 * vault item management

  $ ruby -rjson -e 'puts JSON.generate({"public" => File.read("node_example_com.prod.crt")})' \
  > > ~/tmp/node_example_com.prod.crt.json
  $ knife vault create ssl_server_certs node.example.com.prod \
  > --json ~/tmp/node_example_com.prod.crt.json
=end

undotted_cns = node['ssl_cert']['common_names'].map {|item|
  item.tr('.', '_')
}

default['ssl_cert']['certs_src_dir'] = node.value_for_platform_family(
  'debian' => '/usr/share/ca-certificates',
  'rhel'   => '/usr/share/pki/ca-trust-source/anchors'  # simple trust anchors
)

default['ssl_cert']['certs_dir'] = node.value_for_platform_family(
  'debian' => '/etc/ssl/certs',
  'rhel'   => '/etc/pki/tls/certs'
)

default['ssl_cert']['private_dir'] = node.value_for_platform_family(
  'debian' => '/etc/ssl/private',
  'rhel'   => '/etc/pki/tls/private'
)

node['ssl_cert']['ca_names'].each {|ca|
  default['ssl_cert']["#{ca}_cert_src_path"] \
    = "#{node['ssl_cert']['certs_src_dir']}/#{node['ssl_cert']['ca_cert_file_prefix']}#{ca}.#{node['ssl_cert']['ca_cert_file_extension']}"
  default['ssl_cert']["#{ca}_cert_path"] = node.value_for_platform_family(
    # Debian family's certificates symlink rule
    # "/etc/ssl/certs/#{node['ssl_cert']['ca_cert_file_prefix']}#{ca}.pem" -> node['ssl_cert']["#{ca}_cert_src_path"]
    'debian' => "#{node['ssl_cert']['certs_dir']}/#{node['ssl_cert']['ca_cert_file_prefix']}#{ca}.pem",
    'rhel' => node['ssl_cert']["#{ca}_cert_src_path"]
  )
}

node['ssl_cert']['ca_pubkey_names'].each {|ca|
  default['ssl_cert']["#{ca}_pubkey_path"] \
    = "#{node['ssl_cert']['certs_dir']}/#{node['ssl_cert']['ca_pubkey_file_prefix']}#{ca}.#{node['ssl_cert']['ca_pubkey_file_extension']}"
}

krl_name = node['ssl_cert']['ssh_ca_krl_name']
default['ssl_cert']["#{krl_name}_krl_path"] \
  = "/etc/ssh/#{node['ssl_cert']['ssh_ca_krl_file_prefix']}#{krl_name}.#{node['ssl_cert']['ssh_ca_krl_file_extension']}"

undotted_cns.each {|cn|
  default['ssl_cert']["#{cn}_key_path"]  \
    = "#{node['ssl_cert']['private_dir']}/#{node['ssl_cert']['server_key_file_prefix']}#{cn}.#{node['ssl_cert']['server_key_file_extension']}"
  default['ssl_cert']["#{cn}_cert_path"] \
    = "#{node['ssl_cert']['certs_dir']}/#{node['ssl_cert']['server_cert_file_prefix']}#{cn}.#{node['ssl_cert']['server_cert_file_extension']}"
}
