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

name "revily"
maintainer "Applied Awesome LLC."
homepage "http://revi.ly"

replaces        "revily"
install_path    "/opt/revily"
build_version   Omnibus::BuildVersion.new.semver
build_iteration 1

# creates required build directories
dependency "preparation"

# revily dependencies/components
# dependency "nginx"
# dependency "runit"
# dependency "unicorn"

# backend
# dependency "postgresql"
# dependency "redis"

# revily itself
dependency "revily-api"
dependency "revily-web"

# version manifest file
dependency "version-manifest"

exclude "\.git*"
exclude "bundler\/git"
