#
# Copyright:: Copyright (c) 2013 Applied Awesome, Inc.
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

name "revily-api"
version "1.0.0"

dependency "ruby"
dependency "libpq"
dependency "bundler"
dependency "unicorn"
dependency "curl"
dependency "rsync"

source :git => "https://github.com/revily/revily"

relative_path "revily-api"

env = {
  "LANG"     => "en_US.UTF-8",
  "LANGUAGE" => "en_US.UTF-8",
  "LC_ALL"   => "en_US.UTF-8"
}

build do
  bundle "install --without development test --path=#{install_dir}/embedded/service/gem", :env => env
  command "mkdir -p #{install_dir}/embedded/service/revily-api"
  command "#{install_dir}/embedded/bin/rsync -a --delete --exclude=.git/*** --exclude=.gitignore ./ #{install_dir}/embedded/service/revily-api/"
end
