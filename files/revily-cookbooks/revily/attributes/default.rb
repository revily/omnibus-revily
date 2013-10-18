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

###
# High level options
###
# default['revily']['api_version'] = "11.0.2"
# default['revily']['flavor'] = "osc" # Open Source Chef

# default['revily']['notification_email'] = "info@example.com"
# default['revily']['bootstrap']['enable'] = true

####
# The Revily User that services run as
####
# The username for the revily services user
default['revily']['user']['username'] = "revily"
# The shell for the revily services user
default['revily']['user']['shell'] = "/bin/sh"
# The home directory for the revily services user
default['revily']['user']['home'] = "/opt/revily/embedded"

####
# Redis
####
default['revily']['rabbitmq']['enable'] = true
default['revily']['rabbitmq']['ha'] = false
default['revily']['rabbitmq']['dir'] = "/var/opt/revily/redis"
default['revily']['rabbitmq']['data_dir'] = "/var/opt/revily/redis/db"
default['revily']['rabbitmq']['log_directory'] = "/var/log/revily/redis"
default['revily']['rabbitmq']['node_ip_address'] = '127.0.0.1'
default['revily']['rabbitmq']['node_port'] = 16379

####
# Revily API
####
default['revily']['revily-api']['enable'] = true
default['revily']['revily-api']['ha'] = false
default['revily']['revily-api']['dir'] = "/var/opt/revily/revily-api"
default['revily']['revily-api']['log_directory'] = "/var/log/revily/revily-api"
default['revily']['revily-api']['svlogd_size'] = 1000000
default['revily']['revily-api']['svlogd_num'] = 10
default['revily']['revily-api']['environment'] = 'production'
default['revily']['revily-api']['listen'] = '127.0.0.1'
default['revily']['revily-api']['vip'] = '127.0.0.1'
default['revily']['revily-api']['port'] = 9001
default['revily']['revily-api']['backlog'] = 1024
default['revily']['revily-api']['tcp_nodelay'] = true
default['revily']['revily-api']['worker_timeout'] = 3600
default['revily']['revily-api']['umask'] = "0022"
default['revily']['revily-api']['worker_processes'] = 2
default['revily']['revily-api']['session_key'] = "_revily_api_session"
default['revily']['revily-api']['cookie_domain'] = "all"
default['revily']['revily-api']['cookie_secret'] = "ce75a8f9a9dd21c8e4bcc9a68c21939a17bbd8dbd1d8aa8fc68eefbb8d8bbf92ab82a4a62d0124a25b68afea2d0a8dcfaea3dc84686ff906a3e184f032e7b306"

####
# Revily Web UI
####
default['revily']['revily-web']['enable'] = true
default['revily']['revily-web']['ha'] = false
default['revily']['revily-web']['dir'] = "/var/opt/revily/revily-web"
default['revily']['revily-web']['log_directory'] = "/var/log/revily/revily-web"
default['revily']['revily-web']['environment'] = 'production'
default['revily']['revily-web']['listen'] = '127.0.0.1'
default['revily']['revily-web']['vip'] = '127.0.0.1'
default['revily']['revily-web']['port'] = 9002
default['revily']['revily-web']['backlog'] = 1024
default['revily']['revily-web']['tcp_nodelay'] = true
default['revily']['revily-web']['worker_timeout'] = 3600
default['revily']['revily-web']['umask'] = "0022"
default['revily']['revily-web']['worker_processes'] = 2
default['revily']['revily-web']['session_key'] = "_revily_web_session"
default['revily']['revily-web']['cookie_domain'] = "all"
default['revily']['revily-web']['cookie_secret'] = "706fb638d82c90b3f6496900da5215de7f77211e73e0b611e68f3d4c62c351d2fb8db7a82f59e1863d479db0b60d405c8bdde82a4d5ee6bfc2935182fbf5cfa2"

###
# Load Balancer
###
default['revily']['lb']['enable'] = true
default['revily']['lb']['vip'] = "127.0.0.1"
default['revily']['lb']['api_fqdn'] = node['fqdn']
default['revily']['lb']['web_ui_fqdn'] = node['fqdn']
default['revily']['lb']['debug'] = false
default['revily']['lb']['upstream']['revily-api'] = [ "127.0.0.1" ]
default['revily']['lb']['upstream']['revily-web'] = [ "127.0.0.1" ]

####
# Nginx
####
default['revily']['nginx']['enable'] = true
default['revily']['nginx']['ha'] = false
default['revily']['nginx']['dir'] = "/var/opt/revily/nginx"
default['revily']['nginx']['log_directory'] = "/var/log/revily/nginx"
default['revily']['nginx']['ssl_port'] = 443
default['revily']['nginx']['enable_non_ssl'] = false
default['revily']['nginx']['non_ssl_port'] = 80
default['revily']['nginx']['server_name'] = node['fqdn']
default['revily']['nginx']['url'] = "https://#{node['fqdn']}"
# These options provide the current best security with TSLv1
#default['revily']['nginx']['ssl_protocols'] = "-ALL +TLSv1"
#default['revily']['nginx']['ssl_ciphers'] = "RC4:!MD5"
# This might be necessary for auditors that want no MEDIUM security ciphers and don't understand BEAST attacks
#default['revily']['nginx']['ssl_protocols'] = "-ALL +SSLv3 +TLSv1"
#default['revily']['nginx']['ssl_ciphers'] = "HIGH:!MEDIUM:!LOW:!ADH:!kEDH:!aNULL:!eNULL:!EXP:!SSLv2:!SEED:!CAMELLIA:!PSK"
# The following favors performance and compatibility, addresses BEAST, and should pass a PCI audit
default['revily']['nginx']['ssl_protocols'] = "SSLv3 TLSv1"
default['revily']['nginx']['ssl_ciphers'] = "RC4-SHA:RC4-MD5:RC4:RSA:HIGH:MEDIUM:!LOW:!kEDH:!aNULL:!ADH:!eNULL:!EXP:!SSLv2:!SEED:!CAMELLIA:!PSK"
default['revily']['nginx']['ssl_certificate'] = nil
default['revily']['nginx']['ssl_certificate_key'] = nil
default['revily']['nginx']['ssl_country_name'] = "US"
default['revily']['nginx']['ssl_state_name'] = "WA"
default['revily']['nginx']['ssl_locality_name'] = "Seattle"
default['revily']['nginx']['ssl_company_name'] = "YouCorp"
default['revily']['nginx']['ssl_organizational_unit_name'] = "Operations"
default['revily']['nginx']['ssl_email_address'] = "you@example.com"
default['revily']['nginx']['worker_processes'] = node['cpu']['total'].to_i
default['revily']['nginx']['worker_connections'] = 10240
default['revily']['nginx']['sendfile'] = 'on'
default['revily']['nginx']['tcp_nopush'] = 'on'
default['revily']['nginx']['tcp_nodelay'] = 'on'
default['revily']['nginx']['gzip'] = "on"
default['revily']['nginx']['gzip_http_version'] = "1.0"
default['revily']['nginx']['gzip_comp_level'] = "2"
default['revily']['nginx']['gzip_proxied'] = "any"
default['revily']['nginx']['gzip_types'] = [ "text/plain", "text/css", "application/x-javascript", "text/xml", "application/xml", "application/xml+rss", "text/javascript", "application/json" ]
default['revily']['nginx']['keepalive_timeout'] = 65
default['revily']['nginx']['client_max_body_size'] = '250m'
default['revily']['nginx']['cache_max_size'] = '5000m'

###
# PostgreSQL
###
default['revily']['postgresql']['enable'] = true
default['revily']['postgresql']['ha'] = false
default['revily']['postgresql']['dir'] = "/var/opt/revily/postgresql"
default['revily']['postgresql']['data_dir'] = "/var/opt/revily/postgresql/data"
default['revily']['postgresql']['log_directory'] = "/var/log/revily/postgresql"
default['revily']['postgresql']['svlogd_size'] = 1000000
default['revily']['postgresql']['svlogd_num'] = 10
default['revily']['postgresql']['username'] = "revily-pgsql"
default['revily']['postgresql']['shell'] = "/bin/sh"
default['revily']['postgresql']['home'] = "/var/opt/revily/postgresql"
default['revily']['postgresql']['user_path'] = "/opt/revily/embedded/bin:/opt/revily/bin:$PATH"
default['revily']['postgresql']['sql_user'] = "revily"
default['revily']['postgresql']['sql_password'] = "lmaoifudevops"
default['revily']['postgresql']['sql_ro_user'] = "revily_ro"
default['revily']['postgresql']['sql_ro_password'] = "thoughltlealderl"
default['revily']['postgresql']['vip'] = "127.0.0.1"
default['revily']['postgresql']['port'] = 5432
default['revily']['postgresql']['listen_address'] = 'localhost'
default['revily']['postgresql']['max_connections'] = 200
default['revily']['postgresql']['md5_auth_cidr_addresses'] = [ ]
default['revily']['postgresql']['trust_auth_cidr_addresses'] = [ '127.0.0.1/32', '::1/128' ]
default['revily']['postgresql']['shmmax'] = kernel['machine'] =~ /x86_64/ ? 17179869184 : 4294967295
default['revily']['postgresql']['shmall'] = kernel['machine'] =~ /x86_64/ ? 4194304 : 1048575

if (node['memory']['total'].to_i / 4) > ((node['revily']['postgresql']['shmmax'].to_i / 1024) - 2097152)
  # guard against setting shared_buffers > shmmax on hosts with installed RAM > 64GB
  # use 2GB less than shmmax as the default for these large memory machines
  default['revily']['postgresql']['shared_buffers'] = "14336MB"
else
  default['revily']['postgresql']['shared_buffers'] = "#{(node['memory']['total'].to_i / 4) / (1024)}MB"
end

default['revily']['postgresql']['work_mem'] = "8MB"
default['revily']['postgresql']['effective_cache_size'] = "#{(node['memory']['total'].to_i / 2) / (1024)}MB"
default['revily']['postgresql']['checkpoint_segments'] = 10
default['revily']['postgresql']['checkpoint_timeout'] = "5min"
default['revily']['postgresql']['checkpoint_completion_target'] = 0.9
default['revily']['postgresql']['checkpoint_warning'] = "30s"
