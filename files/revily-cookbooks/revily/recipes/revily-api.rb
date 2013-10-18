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

revily_api_dir = node['revily']['revily-api']['dir']
revily_api_etc_dir = File.join(revily_api_dir, "etc")
revily_api_working_dir = File.join(revily_api_dir, "working")
revily_api_tmp_dir = File.join(revily_api_dir, "tmp")
revily_api_log_dir = node['revily']['revily-api']['log_directory']

[
  revily_api_dir,
  revily_api_etc_dir,
  revily_api_working_dir,
  revily_api_tmp_dir,
  revily_api_log_dir
].each do |dir_name|
  directory dir_name do
    owner node['revily']['user']['username']
    mode '0700'
    recursive true
  end
end

should_notify = OmnibusHelper.should_notify?("revily-api")

env_config = File.join(revily_api_etc_dir, "#{node['revily']['revily-api']['environment']}.rb")
session_store_config = File.join(revily_api_etc_dir, "session_store.rb")
secret_token_config = File.join(revily_api_etc_dir, "secret_token.rb")
config_ru = File.join(revily_api_etc_dir, "config.ru")

revily_api_url = "http://#{node['revily']['revily-api']['listen']}"
revily_api_url << ":#{node['revily']['revily-api']['port']}"

template env_config do
  source "revily-api-config.rb.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
    :revily_url => revily_api_url
  }.merge(node['revily']['revily-api'].to_hash))
  notifies :restart, 'service[revily-api]' if should_notify
end

link "/opt/revily/embedded/service/revily-api/config/environments/#{node['revily']['revily-api']['environment']}.rb" do
  to env_config
end

template session_store_config do
  source "revily-api-session_store.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(node['revily']['revily-api'].to_hash)
  notifies :restart, 'service[revily-api]' if should_notify
end

link "/opt/revily/embedded/service/revily-api/config/initializers/session_store.rb" do
  to session_store_config
end

template secret_token_config do
  source "revily-api-secret_token.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(node['revily']['revily-api'].to_hash)
  notifies :restart, 'service[revily-api]' if should_notify
end

link "/opt/revily/embedded/service/revily-api/config/initializers/secret_token.rb" do
  to secret_token_config
end

template config_ru do
  source "revily-api.ru.erb"
  mode "0644"
  owner "root"
  group "root"
  variables(node['revily']['revily-api'].to_hash)
  notifies :restart, 'service[revily-api]' if should_notify
end

file "/opt/revily/embedded/service/revily-api/config.ru" do
  action :delete
  not_if "test -h /opt/revily/embedded/service/revily-api/config.ru"
end

link "/opt/revily/embedded/service/revily-api/config.ru" do
  to config_ru
end

unicorn_listen = node['revily']['revily-api']['listen']
unicorn_listen << ":#{node['revily']['revily-api']['port']}"

unicorn_config File.join(revily_api_etc_dir, "unicorn.rb") do
  listen unicorn_listen => {
    :backlog => node['revily']['revily-api']['backlog'],
    :tcp_nodelay => node['revily']['revily-api']['tcp_nodelay']
  }
  worker_timeout node['revily']['revily-api']['worker_timeout']
  working_directory revily_api_working_dir
  worker_processes node['revily']['revily-api']['worker_processes']
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, 'service[revily-api]' if should_notify
end

link "/opt/revily/embedded/service/revily-api/tmp" do
  to revily_api_tmp_dir
end

execute "chown -R #{node['revily']['user']['username']} /opt/revily/embedded/service/revily-api/public"

runit_service "revily-api" do
  down node['revily']['revily-api']['ha']
  options({
    :log_directory => revily_api_log_dir
  }.merge(params))
end

if node['revily']['bootstrap']['enable']
  execute "/opt/revily/bin/revily-ctl start revily-api" do
    retries 20
  end
end

