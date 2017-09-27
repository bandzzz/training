ssl_cert Cookbook
=================

This cookbook deploys CA certificates, SSL server keys and/or certificates from Chef Vault items.

## Contents

- [Requirements](#requirements)
  - [packages](#packages)
- [Attributes](#attributes)
  - [ssl_cert::default](#ssl_certdefault)
- [Usage](#usage)
  - [recipes](#recipes)
  - [Vault items creation and cookbook attribute settings (with default attributes)](#vault-items-creation-and-cookbook-attribute-settings-with-default-attributes)
    - [CA certificates](#ca-certificates)
    - [CA public keys (0.2.0 or later)](#ca-public-keys-020-or-later)
    - [SSH-CA KRL (0.3.0 or later)](#ssh-ca-krl-030-or-later)
    - [SSL server keys and certificates](#ssl-server-keys-and-certificates)
  - [References of deployed key and certificate file paths (with default attributes)](#references-of-deployed-key-and-certificate-file-paths-with-default-attributes)
  - [Helper methods](#helper-methods)
- [License and Authors](#license-and-authors)

## Requirements

### packages
- none.

## Attributes

### ssl_cert::default

|Key|Type|Description, example|Default|
|:--|:--|:--|:--|
|`['ssl_cert']['ca_names']`|Array|deployed CA certificates from chef-vault|empty|
|`['ssl_cert']['ca_pubkey_names']`|Array|deployed CA public keys from chef-vault (0.2.0 or later)|empty|
|`['ssl_cert']['ssh_ca_krl_name']`|String|deployed SSH-CA KRL (Key Revocation List) from chef-vault (0.3.0 or later)|`nil`|
|`['ssl_cert']['common_names']`|Array|deployed server keys and/or certificates from chef-vault|empty|
|`['ssl_cert']['debian']['key_access_mode']`|Private key file mode (ver. 0.3.4 or later).|`0640`|
|`['ssl_cert']['rhel']['key_access_mode']`|Private key file mode (ver. 0.3.4 or later).|`0400`|
|`['ssl_cert']['rhel']['key_access_group']`|String|RHEL family's key access group (ver. 0.1.5 or later)|`'ssl-cert'`|
|`['ssl_cert']['chef_gem']['clear_sources']`|Boolean|chef_gem resource's clear_sources property.|`false`|
|`['ssl_cert']['chef_gem']['source']`|String|chef_gem resource's source property.|`nil`|
|`['ssl_cert']['chef_gem']['options']`|String|chef_gem resource's options property.|`nil`|
|`['ssl_cert']['chef-vault']['version']`|String|chef-vault installation version.|`'~> 2.6'`|
|`['ssl_cert']['env_context']`|String|node's environment or nil/empty.|`node.chef_environment`|
|`['ssl_cert']['vault_item_suffix']`|String|vault item name's suffix.|`".#{node['ssl_cert']['env_context']}"`|
|`['ssl_cert']['ca_cert_vault']`|String|CA certificate stored vault name.|`'ca_certs'`|
|`['ssl_cert']['ca_cert_vault_item_key']`|String|CA certificate stored vault item key name. (single key or nested hash key path delimited by slash)|`'public'`|
|`['ssl_cert']['ca_cert_file_prefix']`|String|CA certificate file name's prefix.|`''`|
|`['ssl_cert']['ca_cert_file_extension']`|String|CA certificate file name's extension. (0.3.0 or later)|`'crt'`|
|`['ssl_cert']['ca_pubkey_vault']`|String|CA public key stored vault name. (0.2.0 or later)|`'ca_pubkeys'`|
|`['ssl_cert']['ca_pubkey_vault_item_key']`|String|CA public key stored vault item key name. (single key or nested hash key path delimited by slash. 0.2.0 or later)|`'public'`|
|`['ssl_cert']['ca_pubkey_file_prefix']`|String|CA public key file name's prefix. (0.2.0 or later)|`''`|
|`['ssl_cert']['ca_pubkey_file_extension']`|String|CA public key file name's extension. (0.3.0 or later)|`'pub'`|
|`['ssl_cert']['ssh_ca_krl_vault']`|String|SSH-CA KRL stored vault name. (0.3.0 or later)|`'ssh_ca_krls'`|
|`['ssl_cert']['ssh_ca_krl_vault_item_key']`|String|SSH-CA KRL stored vault item key name. (single key or nested hash key path delimited by slash. 0.3.0 or later)|`'public'`|
|`['ssl_cert']['ssh_ca_krl_file_prefix']`|String|SSH-CA KRL file name's prefix. (0.3.0 or later)|`''`|
|`['ssl_cert']['ssh_ca_krl_file_extension']`|String|SSH-CA KRL file name's extension. (0.3.0 or later)|`'krl'`|
|`['ssl_cert']['server_key_vault']`|String|SSL server key stored vault name.|`'ssl_server_keys'`|
|`['ssl_cert']['server_key_vault_item_key']`|String|SSL server key stored vault item key name. (single key or nested hash key path delimited by slash)|`'private'`|
|`['ssl_cert']['server_key_file_prefix']`|String|SSL server key file name's prefix.|`''`|
|`['ssl_cert']['server_key_file_extension']`|String|SSL server key file name's extension. (0.3.0 or later)|`'key'`|
|`['ssl_cert']['server_cert_vault']`|String|SSL server certificate stored vault name.|`'ssl_server_certs'`|
|`['ssl_cert']['server_cert_vault_item_key']`|String|SSL server certificate stored vault item key name. (single key or nested hash key path delimited by slash)|`'public'`|
|`['ssl_cert']['server_cert_file_prefix']`|String|SSL server certificate file name's prefix.|`''`|
|`['ssl_cert']['server_cert_file_extension']`|String|SSL server certificate file name's extension. (0.3.0 or later)|`'crt'`|
|`['ssl_cert']['certs_src_dir']`|String||See `attributes/default.rb`.|
|`['ssl_cert']['certs_dir']`|String||See `attributes/default.rb`.|
|`['ssl_cert']['private_dir']`|String||See `attributes/default.rb`.|
|`['ssl_cert']["#{ca}_cert_src_path"]`|String|CA certificate source file path. (0.3.3 or later)|See `attributes/default.rb`.|
|`['ssl_cert']["#{ca}_cert_path"]`|String|deployed CA certificate file path.|See `attributes/default.rb`.|
|`['ssl_cert']["#{ca}_pubkey_path"]`|String|deployed CA public key file path. (0.2.0 or later)|`"#{node['ssl_cert']['certs_dir']}/#{node['ssl_cert']['ca_pubkey_file_prefix']}#{ca}.#{node['ssl_cert']['ca_pubkey_file_extension']}"`|
|`['ssl_cert']["#{undotted_cn}_key_path"]`|String|deployed SSL server key file path.|`"#{node['ssl_cert']['private_dir']}/#{node['ssl_cert']['server_key_file_prefix']}#{undotted_cn}.#{node['ssl_cert']['server_key_file_extension']}"`|
|`['ssl_cert']["#{undotted_cn}_cert_path"]`|String|deployed SSL server certificate file path.|`"#{node['ssl_cert']['certs_dir']}/#{node['ssl_cert']['server_cert_file_prefix']}#{undotted_cn}.#{node['ssl_cert']['server_cert_file_extension']}"`|

## Usage

### recipes
- `ssl_cert::default` - deploys CA certificates, SSL server keys and/or certificates.
- `ssl_cert::ca_certs` - deploys CA certificates.
- `ssl_cert::ca_pubkeys` - deploys CA public keys for SSH-CA, ... (0.2.0 or later)
- `ssl_cert::ssh_ca_krl` - deploys a SSH-CA KRL (Key Revocation List) file. (0.3.0 or later)
- `ssl_cert::server_key_pairs` - deploys SSL server keys and certificates.
- `ssl_cert::server_keys` - deploys SSL server keys.
- `ssl_cert::server_certs` - deploys SSL server certificates.

### Vault items creation and cookbook attribute settings (with default attributes)

#### CA certificates

- create vault items.

```text
$ ruby -rjson -e 'puts JSON.generate({"public" => File.read("grid_ca.prod.crt")})' \
> > ~/tmp/grid_ca.prod.crt.json

$ cd $CHEF_REPO_PATH

$ knife vault create ca_certs grid_ca.prod \
> --json ~/tmp/grid_ca.prod.crt.json
```

- grant reference permission to the appropriate nodes

```text
$ knife vault update ca_certs grid_ca.prod -S 'name:*.example.com'
```

- add cookbook attributes.

```ruby
override_attributes(
  'ssl_cert' => {
    'ca_names' => [
      'grid_ca',
      # ...
    ],
  },
)
```

#### CA public keys (0.2.0 or later)

- create vault items.

```text
$ ruby -rjson -e 'puts JSON.generate({"public" => File.read("grid_ssh_ca.prod.pub")})' \
> > ~/tmp/grid_ssh_ca.prod.pub.json

$ cd $CHEF_REPO_PATH

$ knife vault create ca_pubkeys grid_ssh_ca.prod \
> --json ~/tmp/grid_ssh_ca.prod.pub.json
```

- grant reference permission to the appropriate nodes

```text
$ knife vault update ca_pubkeys grid_ssh_ca.prod -S 'name:*.example.com'
```

- add cookbook attributes.

```ruby
override_attributes(
  'ssl_cert' => {
    'ca_pubkey_names' => [
      'grid_ssh_ca',
      # ...
    ],
  },
)
```

#### SSH-CA KRL (0.3.0 or later)

- create vault items.

```text
$ ruby -rjson -e 'puts JSON.generate({"public" => File.read("grid_ssh_ca.prod.krl")})' \
> > ~/tmp/grid_ssh_ca.prod.krl.json

$ cd $CHEF_REPO_PATH

$ knife vault create ssh_ca_krls grid_ssh_ca.prod \
> --json ~/tmp/grid_ssh_ca.prod.krl.json
```

- grant reference permission to the appropriate nodes

```text
$ knife vault update ssh_ca_krls grid_ssh_ca.prod -S 'name:*.example.com'
```

- add cookbook attributes.

```ruby
override_attributes(
  'ssl_cert' => {
    'ssh_ca_krl_name' => 'grid_ssh_ca',
  },
)
```

#### SSL server keys and certificates

- create vault items.

```text
$ ruby -rjson -e 'puts JSON.generate({"private" => File.read("node_example_com.prod.key")})' \
> > ~/tmp/node_example_com.prod.key.json

$ ruby -rjson -e 'puts JSON.generate({"public" => File.read("node_example_com.prod.crt")})' \
> > ~/tmp/node_example_com.prod.crt.json

$ cd $CHEF_REPO_PATH

$ knife vault create ssl_server_keys node.example.com.prod \
> --json ~/tmp/node_example_com.prod.key.json

$ knife vault create ssl_server_certs node.example.com.prod \
> --json ~/tmp/node_example_com.prod.crt.json
```

- grant reference permission to the appropriate nodes

```text
$ knife vault update ssl_server_keys node.example.com.prod -S 'name:node.example.com'
$ knife vault update ssl_server_certs node.example.com.prod -S 'name:node.example.com'
```

- add cookbook attributes

```ruby
override_attributes(
  'ssl_cert' => {
    'common_names' => [
      'node.example.com',
      # ...
    ],
  },
)
```

### References of deployed key and certificate file paths (with default attributes)

- `node['ssl_cert']["#{ca}_cert_path"]`: e.g. `node['ssl_cert']['grid_ca_cert_path']`
- `node['ssl_cert']["#{ca}_pubkey_path"]`: e.g. `node['ssl_cert']['grid_ssh_ca_pubkey_path']`
- `node['ssl_cert']["#{ca}_krl_path"]`: e.g. `node['ssl_cert']['grid_ssh_ca_krl_path']`
- `node['ssl_cert']["#{undotted_cn}_key_path"]`: e.g. `node['ssl_cert']['node_example_com_key_path']`
- `node['ssl_cert']["#{undotted_cn}_cert_path"]`: e.g. `node['ssl_cert']['node_example_com_cert_path']`

### Helper methods

- `SSLCert::Helper.get_vault_item_value(vault, name)`: return vault item value string.
- `SSLCert::Helper.append_ca_name(ca_name)`: append CA name which certificate is deployed.
- `SSLCert::Helper.ca_cert_path(ca_name)`: return CA certificate file path string.
- `SSLCert::Helper.ca_pubkey_path(ca_name)`: return CA public key file path string.
- `SSLCert::Helper.ca_krl_path(ca_name)`: return CA KRL file path string.
- `SSLCert::Helper.append_server_ssl_cn(common_name)`: append server common name which key and certificate are deployed.
- `SSLCert::Helper.server_key_content(common_name)`: return server private key content string.
- `SSLCert::Helper.server_cert_content(common_name)`: return server certificate content string.
- `SSLCert::Helper.server_key_path(common_name)`: return server private key file path string.
- `SSLCert::Helper.server_cert_path(common_name)`: return server certificate file path string.
- `SSLCert::Helper.append_members_to_key_access_group(members_array)`: append members to the key access group (default: `ssl-cert`).

```ruby
::Chef::Recipe.send(:include, SSLCert::Helper)

append_members_to_key_access_group(['openldap'])
grid_ca_cert_path = ca_cert_path('grid_ca')
ldap_key_path = server_key_path('ldap.grid.example.com')
ldap_cert_path = server_cert_path('ldap.grid.example.com')
``` 

## License and Authors

- Author:: whitestar at osdn.jp

```text
Copyright 2016, whitestar

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
