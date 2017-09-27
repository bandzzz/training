platform_utils Cookbook
=======================

This cookbook provides platform utility recipes.

## Contents

- [Requirements](#requirements)
    - [Platforms](#platforms)
    - [Packages](#packages)
    - [Cookbooks](#cookbooks)
- [Attributes](#attributes)
- [Usage](#usage)
    - [Recipes](#recipes)
        - [platform_utils::default](#platform_utilsdefault)
        - [platform_utils::crond (ver. 0.4.0 or later)](#platform_utilscrond-ver-040-or-later)
        - [platform_utils::kernel_modules (ver. 0.4.2 or later)](#platform_utilskernel_modules-ver-042-or-later)
        - [platform_utils::kernel_user_namespace (ver. 0.4.2 or later)](#platform_utilskernel_user_namespace-ver-042-or-later)
        - [platform_utils::ntpd (ver. 0.4.0 or later)](#platform_utilsntpd-ver-040-or-later)
        - [platform_utils::platform_update](#platform_utilsplatform_update)
        - [platform_utils::subid](#platform_utilssubid)
        - [platform_utils::sudo](#platform_utilssudo)
        - [platform_utils::sysctl (ver. 0.4.3 or later)](#platform_utilssysctl-ver-043-or-later)
        - [platform_utils::tcp_wrappers (ver. 0.4.0 or later)](#platform_utilstcp_wrappers-ver-040-or-later)
- [License and Authors](#license-and-authors)

## Requirements

### Platforms
- CentOS, Red Hat Enterprise Linux
- Debian, Ubuntu

### Packages
- none.

### Cookbooks
- none.

## Attributes

|Key|Type|Description, example|Default|
|:--|:--|:--|:--|
|`['platform_utils']['kernel_modules']['loaded_modules']`|Array|Loaded extra kernel module names.|`[]`|
|`['platform_utils']['platform_update']['auto_update']`|Boolean|whether update automatically or not.|`true`|
|`['platform_utils']['platform_update']['timer']`|Symbol|update execution timing.|`:delayed`|
|`['platform_utils']['platform_update']['apt-get']['command']`|String|apt-get upgrade/dist-upgrade command string.|`'apt-get upgrade -y'`|
|`['platform_utils']['platform_update']['yum']['command']`|String|yum update command string.|`'yum update -y'`|
|`['platform_utils']['subid']['users']`|Array|Subordinate user (=group) names.|`[]`|
|`['platform_utils']['subid']['notifies']`|Array, Hash|Notifies by the subordinate user/group file update.|`[]`, See `attributes/default.rb`|
|`['platform_utils']['sudo']['sudoers.d']`|Hash|sudoers file configurations.|`{}` See `attributes/default.rb`|
|`['platform_utils']['sudo']['group']['members']`|Array|Members appended to the `sudo` group.|`[]`|
|`['platform_utils']['sysctl']['configs']`|Hash|sysctl configurations. (ver. 0.4.3 or later)|`{}`, See `attributes/default.rb`|
|`['platform_utils']['tcp_wrappers']['host_allow']`|Array|Entries in `/etc/hosts.allow` (ver. 0.4.0 or later)|`[]`|
|`['platform_utils']['tcp_wrappers']['host_deny']`|Array|Entries in `/etc/hosts.deny` (ver. 0.4.0 or later)|`[]`|

## Usage

### Recipes

#### platform_utils::default

This recipe does nothing.

#### platform_utils::crond (ver. 0.4.0 or later)

This recipe installs cron package and enables & starts the service.

#### platform_utils::kernel_modules (ver. 0.4.2 or later)

This recipe loads the extra kernel modules.

#### platform_utils::kernel_user_namespace (ver. 0.4.2 or later)

This recipe activates the kernel user namespace feature.

#### platform_utils::ntpd (ver. 0.4.0 or later)

This recipe installs ntpd package and enables & starts the service.

#### platform_utils::platform_update

This recipe updates the platform.

#### platform_utils::subid

This recipe sets up the `/etc/subuid` and the `/etc/subgid`.

#### platform_utils::sudo

This recipe sets up sudo.

#### platform_utils::sysctl (ver. 0.4.3 or later)

This recipe sets up sysctl (Kernel parameters).

#### platform_utils::tcp_wrappers (ver. 0.4.0 or later)

This recipe sets up hosts.allow and hosts.deny.

## License and Authors

- Author:: whitestar at osdn.jp

```text
Copyright 2016-2017, whitestar

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
