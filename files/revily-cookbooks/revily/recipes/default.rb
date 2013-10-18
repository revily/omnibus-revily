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

require 'openssl'

ENV['PATH'] = "/opt/revily/bin:/opt/revily/embedded/bin:#{ENV['PATH']}"

directory "/etc/revily" do
  owner "root"
  group "root"
  mode "0775"
  action :nothing
end.run_action(:create)

if File.exists?("/etc/revily/revily.json")
  Chef::Log.warn("Please move to /etc/revily/revily.rb for configuration - /etc/revily/revily.json is deprecated.")
else
  Revily[:node] = node
  if File.exists?("/etc/revily/revily.rb")
    Revily.from_file("/etc/revily/revily.rb")
  end
  node.consume_attributes(Revily.generate_config(node['fqdn']))
end

if File.exists?("/var/opt/revily/bootstrapped")
  node.set['revily']['bootstrap']['enable'] = false
end

# Create the Revily User
include_recipe "revily::users"

directory "/etc/revily" do
  owner "root"
  group node['revily']['user']['username']
  mode "0775"
  action :create
end

directory "/var/opt/revily" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

# Install our runit instance
include_recipe "runit"

# Configure Services
[
  "postgresql",
  "redis",
  "revily-api",
  "revily-web",
  "nginx"
].each do |service|
  if node["revily"][service]["enable"]
    include_recipe "revily::#{service}"
  else
    include_recipe "revily::#{service}_disable"
  end
end

file "/etc/revily/revily-running.json" do
  owner node['revily']['user']['username']
  group "root"
  mode "0600"
  content Chef::JSONCompat.to_json_pretty({ "revily" => node['revily'].to_hash, "run_list" => node.run_list })
end
