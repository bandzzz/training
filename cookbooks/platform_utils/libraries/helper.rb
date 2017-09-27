#
# Cookbook Name:: platform_utils
# Library:: Helper
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

require 'shellwords'
require_relative './virt_utils.rb'

module PlatformUtils
  # Helper methods
  module Helper
    include PlatformUtils::VirtUtils

    def load_kernel_module(mod_name)
      unless container_guest_node?
        # for old distributions.
        dir = '/etc/modules-load.d'
        resources(directory: dir) rescue directory dir do
          owner 'root'
          group 'root'
          mode '0755'
        end

        exec_name = "load_#{mod_name}_kernel_module"
        resources(execute: exec_name) rescue execute exec_name do
          command "modprobe #{mod_name}"
          not_if "lsmod | grep #{mod_name}"
        end

        file_name = "/etc/modules-load.d/#{mod_name}.conf"
        resources(file: file_name) rescue file file_name do
          content "#{mod_name}\n"
          owner 'root'
          group 'root'
          mode '0644'
        end
      end
    end

    def validate_shellwords(words)
      invalid_word = words.find {|word|
        word =~ /[;\|&<>`]/
      }
      unless invalid_word.nil?
        Chef::Log.fatal("Command string includes the invalid character (;|&<>`): #{invalid_word}")
        raise
      end
    end

    def touch_subid_files
      subid_files = [
        '/etc/subuid',
        '/etc/subgid',
      ]

      subid_files.each {|subid_file|
        resources(file: subid_file) rescue file subid_file do
          owner 'root'
          group 'root'
          mode '0644'
          action :touch
          not_if { File.exist?(subid_file) }
        end
      }

      subid_files
    end

    def normalize_notifies(item)
      ret = nil

      if item.is_a?(Array)
        ret = {
          'action' => item[0],
          'resource' => item[1],
          'timer' => item[2].nil? ? :delayed : item[2],
        }
      elsif item.is_a?(Hash)
        ret = {
          'action' => item['action'],
          'resource' => item['resource'],
          'timer' => item['timer'].nil? ? :delayed : item['timer'],
        }
      end

      ret
    end

    def normalize_notifies_props(conf)
      nconf = []

      if conf.is_a?(Array)
        if conf[0].is_a?(Symbol)
          nconf.push(normalize_notifies(conf))
        else
          conf.each {|item|
            nconf.push(normalize_notifies(item))
          }
        end
      elsif conf.is_a?(Hash)
        nconf.push(normalize_notifies(conf))
      end

      nconf
    end

    def append_subusers(users, notifies_conf = nil)
      subid_files = touch_subid_files
      nconf = notifies_conf.nil? ? nil : normalize_notifies_props(notifies_conf)

      this_recipe = self
      users.each {|uname|
        blk_name = "adds_subid_entries_#{uname}"
        resources(ruby_block: blk_name) rescue ruby_block blk_name do
          action :run
          not_if "cat /etc/subuid | grep #{uname}"
          not_if "cat /etc/subgid | grep #{uname}"
          unless nconf.nil?
            nconf.each {|item|
              notifies item['action'], item['resource'], item['timer']
            }
          end
          block do
            subid_files.each {|subid_file|
              max_start_id = 100_000
              offset = 0
              already_exist = false

              begin
                File.open(subid_file) {|file|
                  file.each_line {|line|
                    entry = line.split(':')
                    if entry[0] == uname
                      already_exist = true
                      break
                    end
                    if entry[1].to_i >= max_start_id
                      max_start_id = entry[1].to_i
                      offset = entry[2].to_i
                    end
                  }
                }

                if already_exist
                  this_recipe.log "#{uname} already exists in #{subid_file}"
                else
                  File.open(subid_file, 'a') {|file|
                    entry_str = "#{uname}:#{max_start_id + offset}:65536"
                    this_recipe.log "#{uname} (#{entry_str}) is added in #{subid_file}"
                    file.puts entry_str
                  }
                end
              rescue IOError => e
                puts e
              end
            }
          end
        end
      }
    end
  end
end
