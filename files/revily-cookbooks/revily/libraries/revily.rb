#
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# License:: Apache License, Version 2.0
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

require 'mixlib/config'
require 'chef/mash'
require 'chef/json_compat'
require 'chef/mixin/deep_merge'
require 'securerandom'

module Revily
  extend(Mixlib::Config)

  redis Mash.new
  lb Mash.new
  redis Mash.new
  postgresql Mash.new
  nginx Mash.new
  api_fqdn nil
  node nil
  notification_email nil

  class << self

    # guards against creating secrets on non-bootstrap node
    def generate_hex(chars)
      SecureRandom.hex(chars)
    end

    def generate_secrets(node_name)
      existing_secrets ||= Hash.new
      if File.exists?("/etc/revily/revily-secrets.json")
        existing_secrets = Chef::JSONCompat.from_json(File.read("/etc/revily/revily-secrets.json"))
      end
      existing_secrets.each do |k, v|
        v.each do |pk, p|
          Revily[k][pk] = p
        end
      end

      Revily['revily_web']['cookie_secret'] ||= generate_hex(50)
      Revily['revily_api']['cookie_secret'] ||= generate_hex(50)
      Revily['postgresql']['sql_password'] ||= generate_hex(50)
      Revily['postgresql']['sql_ro_password'] ||= generate_hex(50)

      if File.directory?("/etc/revily")
        File.open("/etc/revily/revily-secrets.json", "w") do |f|
          f.puts(
            Chef::JSONCompat.to_json_pretty({
              'revily_web' => {
                'cookie_secret' => Revily['revily_web']['cookie_secret'],
              },
              'revily_api' => {
                'cookie_secret' => Revily['revily_api']['cookie_secret'],
              },
              'postgresql' => {
                'sql_password' => Revily['postgresql']['sql_password'],
                'sql_ro_password' => Revily['postgresql']['sql_ro_password']
              },
            })
          )
          system("chmod 0600 /etc/revily/revily-secrets.json")
        end
      end
    end

    def generate_hash
      results = { "revily" => {} }
      [
        "revily_web",
        "revily_api",
        "redis",
        "lb",
        "postgresql",
        "nginx",
      ].each do |key|
        rkey = key.gsub('_', '-')
        results['revily'][rkey] = Revily[key]
      end
      results['revily']['notification_email'] = Revily['notification_email']

      results
    end

    def gen_api_fqdn
      Revily["lb"]["api_fqdn"] ||= Revily['api_fqdn']
      Revily["lb"]["web_ui_fqdn"] ||= Revily['api_fqdn']
      Revily["nginx"]["server_name"] ||= Revily['api_fqdn']

      # If the user manually set an Nginx URL in the config file all bets are
      # off...we just cross our fingers and hope they constructed the URL
      # correctly! We may want to remove this 'private' config value from the
      # documenation.
      if Revily["nginx"]["url"].nil?
        Revily["nginx"]["url"] = "https://#{Revily['api_fqdn']}"
        if Revily["nginx"]["ssl_port"]
          Revily["nginx"]["url"] << ":#{Revily["nginx"]["ssl_port"]}"
        end
      end

    end

    def generate_config(node_name)
      generate_secrets(node_name)
      Revily[:api_fqdn] ||= node_name
      gen_api_fqdn
      generate_hash
    end
  end
end
