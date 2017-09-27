ssl_cert CHANGELOG
==================

0.4.1
-----
- adds `SSLCert::Helper.append_ca_name` method. 
- adds `SSLCert::Helper.append_server_ssl_cn` method. 

0.4.0
-----
- adds `SSLCert::Helper.server_{cert,key}_content` method.

0.3.9
-----
- adds the Concourse pipeline configuration.
- revises documents.

0.3.8
-----
- bug fix: follows Debian family's certificates symlink rule.
- revises documents.

0.3.7
-----
- adds `SSLCert::Helper.get_vault_item_value` method.

0.3.6
-----
- refactoring.

0.3.5
-----
- bug fix: key access group modification.
- adds `SSLCert::Helper.append_members_to_key_access_group` method.

0.3.4
-----
- adds the `['ssl_cert']['debian']['key_access_mode']` attribute.
- adds the `['ssl_cert']['rhel']['key_access_mode']` attribute.

0.3.3
-----
- bug fix: adds CA certificate update sequece for system level.
- adds the `['ssl_cert']['certs_src_dir']` attribute.
- refactoring.

0.3.2
-----
- refactoring.

0.3.1
-----
- Cleanup for FoodCritic and RuboCop.

0.3.0
-----
- add `ssh_ca_krl` recipe for SSH-CA
- add deployed filename extension attributes.

0.2.0
-----
- add `ca_pubkeys` recipe for SSH-CA, ...

0.1.5
-----
- add `['ssl_cert']['rhel']['key_access_group']` attribute.

0.1.4
-----
- improvement for vault item key setting (add nested hash key path format delimited by slash)

0.1.3
-----
- add `{ca_cert,server_key,server_cert}_file_prefix` attributes.

0.1.2
-----
- add some attributes.

0.1.1
-----
- a little modified.

0.1.0
-----
- Initial release of ssl_cert

