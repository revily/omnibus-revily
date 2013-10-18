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

revily_web_dir = node['revily']['revily-web']['dir']
revily_web_etc_dir = File.join(revily_web_dir, "etc")
revily_web_working_dir = File.join(revily_web_dir, "working")
revily_web_tmp_dir = File.join(revily_web_dir, "tmp")
revily_web_log_dir = node['revily']['revily-web']['log_directory']

[
  revily_web_dir,
  revily_web_etc_dir,
  revily_web_working_dir,
  revily_web_tmp_dir,
  revily_web_log_dir
].each do |dir_name|
  directory dir_name do
    owner node['revily']['user']['username']
    mode '0700'
    recursive true
  end
end

should_notify = OmnibusHelper.should_notify?("revily-web")

env_config = File.join(revily_web_etc_dir, "#{node['revily']['revily-web']['environment']}.rb")
session_store_config = File.join(revily_web_etc_dir, "session_store.rb")
secret_token_config = File.join(revily_web_etc_dir, "secret_token.rb")
config_ru = File.join(revily_web_etc_dir, "config.ru")

revily_api_url = "http://#{node['revily']['revily-api']['listen']}"
revily_api_url << ":#{node['revily']['revily-api']['port']}"

template env_config do
  source "revily-web-config.rb.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
    :revily_url => revily_api_url
  }.merge(node['revily']['revily-web'].to_hash))
  notifies :restart, 'service[revily-web]' if should_notify
end

link "/opt/revily/embedded/service/revily-web/config/environments/#{node['revily']['revily-web']['environment']}.rb" do
  to env_config
end

template session_store_config do
  source "revily-web-session_store.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(node['revily']['revily-web'].to_hash)
  notifies :restart, 'service[revily-web]' if should_notify
end

link "/opt/revily/embedded/service/revily-web/config/initializers/session_store.rb" do
  to session_store_config
end

template secret_token_config do
  source "revily-web-secret_token.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(node['revily']['revily-web'].to_hash)
  notifies :restart, 'service[revily-web]' if should_notify
end

link "/opt/revily/embedded/service/revily-web/config/initializers/secret_token.rb" do
  to secret_token_config
end

template config_ru do
  source "revily-web.ru.erb"
  mode "0644"
  owner "root"
  group "root"
  variables(node['revily']['revily-web'].to_hash)
  notifies :restart, 'service[revily-web]' if should_notify
end

file "/opt/revily/embedded/service/revily-web/config.ru" do
  action :delete
  not_if "test -h /opt/revily/embedded/service/revily-web/config.ru"
end

link "/opt/revily/embedded/service/revily-web/config.ru" do
  to config_ru
end

unicorn_listen = node['revily']['revily-web']['listen']
unicorn_listen << ":#{node['revily']['revily-web']['port']}"

unicorn_config File.join(revily_web_etc_dir, "unicorn.rb") do
  listen unicorn_listen => {
    :backlog => node['revily']['revily-web']['backlog'],
    :tcp_nodelay => node['revily']['revily-web']['tcp_nodelay']
  }
  worker_timeout node['revily']['revily-web']['worker_timeout']
  working_directory revily_web_working_dir
  worker_processes node['revily']['revily-web']['worker_processes']
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, 'service[revily-web]' if should_notify
end

link "/opt/revily/embedded/service/revily-web/tmp" do
  to revily_web_tmp_dir
end

execute "chown -R #{node['revily']['user']['username']} /opt/revily/embedded/service/revily-web/public"

runit_service "revily-web" do
  down node['revily']['revily-web']['ha']
  options({
    :log_directory => revily_web_log_dir
  }.merge(params))
end

if node['revily']['bootstrap']['enable']
  execute "/opt/revily/bin/revily-ctl start revily-web" do
    retries 20
  end
end

