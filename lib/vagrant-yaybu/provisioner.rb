# Copyright 2011 Isotoma Limited
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'yaml'

$deploy_script = <<-EOS
#! /usr/bin/env python

import sys, StringIO
from yay.config import Config
from yaybu.core.remote import RemoteRunner
from yaybu.core.runcontext import RunContext

class opts:
    log_level = "info"
    logfile = "-"
    host = "<%= ssh_user %>@<%= ssh_host %>:<%= ssh_port %>"
    user = "root"
    ypath = [
<% searchpath.each do |path| %>
        "<%= path %>",
<% end %>
        ]
    simulate = False
    verbose = False
    resume = True
    no_resume = False
    env_passthrough = []

vagrant_config = StringIO.StringIO("""
<%= vagrant %>
""")

includes = StringIO.StringIO("""
<% if includes.length > 0 %>
.include:
  <% includes.each do |include| %>
  - <%= include %>
  <% end %>
<% end %>
""")

raw_config = StringIO.StringIO("""
<%= yay %>
""")

config = Config(searchpath=opts.ypath)
config.load(vagrant_config)
config.load(includes)
config.load(raw_config)

ctx = RunContext(None, opts)
ctx.set_config(config)

r = RemoteRunner()
r.set_interactive(False)
r.set_identity_file("<%= private_key_path %>")
r.set_missing_host_key_policy("no")
r.load_host_keys("/dev/null")
rv = r.run(ctx)
sys.exit(rv)

EOS

module Vagrant
  module Provisioners
    class YaybuError < Vagrant::Errors::VagrantError
      error_namespace("vagrant.provisioners.yaybu")
    end

    class YaybuProvisioner < Base
      class Config < Vagrant::Config::Base
        attr_accessor :yay
        attr_accessor :python
        attr_accessor :searchpath
        attr_accessor :include
        attr_accessor :yay_version
        attr_accessor :yaybu_version

        def initialize
          super

          @yay = ""
          @python = "python"
          @searchpath = []
          @include = []

          @yay_version = nil
          @yaybu_version = nil
        end
      end

      def self.config_class
        Config
      end

      def bootstrap
        ssh = env[:vm].channel
        begin
          ssh.sudo("which yaybu", :error_class => YaybuError, :_key => :yaybu_not_detected, :binary => "yaybu")
        rescue
          env[:ui].info "Yaybu not found so attempting to install it"

          if not config.yay_version then
              env[:ui].info "yay version not specified in Vagrantfile, determining from host system"
              config.yay_version = get_local_version?("yay")
          end

          if not config.yaybu_version then
              env[:ui].info "Yaybu version not specified in Vagrantfile, determining from host system"
              config.yaybu_version = get_local_version?("Yaybu")
          end

          env[:ui].info "Running apt-get updating and checking setuptools"
          ssh.sudo("apt-get update")
          ssh.sudo("apt-get install python-setuptools -y")

          env[:ui].info "Running 'easy_install yay==#{config.yay_version}'"
          ssh.sudo("easy_install yay==#{config.yay_version}")

          env[:ui].info "Running 'easy_install Yaybu==#{config.yaybu_version}'"
          ssh.sudo("easy_install Yaybu==#{config.yaybu_version}")
        end
      end

      def prepare
      end

      def verify_import(mod)
          if not system("#{config.python}", "-c", "import #{mod}") then
            raise YaybuError.new "Module #{mod} not found"
          end
      end

      def verify_local_binary(binary)
          if not system("which #{binary}") then
            raise YaybuError.new "Local binary #{binary} not found"
          end
      end

      def get_local_version?(mod)
          version = `#{config.python} -c 'print __import__("pkg_resources").get_distribution("#{mod}").version'`.strip
          if $?.to_i != 0 then
              raise YaybuError.new "Failed to get host version for '#{mod}'"
          end

          version
      end

      def get_vagrant_yaml?
          data = {}
          vagrant = data['vagrant'] = {}
          vms = vagrant['vms'] = {}

          env[:vm].env.vms.each do |name, vm|
              info = {
                  "name" => vm.name.to_s,
                  "interfaces" => [],
                  }

              idx = 1
              vm.config.vm.networks.each do |type, ips|
                  ips.each do |ip|
                      info["interfaces"] << {
                          "name" => "eth#{idx}",
                          "address" => ip,
                          "netmask" => "255.255.255.0",
                          "gateway" => (ip.split(".").slice(0, 3) + [1]).join("."),
                          }
                      idx += 1
                  end
              end

              info["interfaces"] << {
                  "name" => "eth0",
                  "type" => "dhcp",
                  }

              vms[name.to_s] = info
          end

          name = env[:vm].name.to_s
          vagrant["vm"] = "${vagrant.vms.#{name}}"

          "#" + data.to_yaml
      end

      def provision!
        verify_import "yaybu"
        verify_import "yay"

        verify_local_binary "ssh"

        bootstrap

        deployment_script = TemplateRenderer.render_string($deploy_script, {
          :ssh_host => env[:vm].ssh.info[:host],
          :ssh_user => env[:vm].ssh.info[:username],
          :ssh_port => env[:vm].ssh.info[:port],
          :private_key_path => env[:vm].ssh.info[:private_key_path],
          :yay => config.yay,
          :vagrant => get_vagrant_yaml?,
          :searchpath => config.searchpath,
          :includes => config.include,
          })

        IO.popen("#{config.python} -c 'import sys; exec(sys.stdin.read())'", "r+") do |io|
          io.write(deployment_script)
          io.close_write

          while line = io.gets do
            env[:ui].info("#{line}")
          end
        end
      end
    end

  end
end

Vagrant.provisioners.register(:yaybu)         { Vagrant::Provisioners::YaybuProvisioner }

