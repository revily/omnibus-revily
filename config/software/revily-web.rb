#
# Copyright:: Copyright (c) 2013 Applied Awesome, Inc.
# License:: MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

name "revily-web"
version "1.0.0"

dependency "ruby"
dependency "bundler"
# dependency "libxml2"
# dependency "libxslt"
dependency "curl"
dependency "rsync"

source :git => "https://github.com/revily/revily-web"

relative_path "revily-web"

env = {
  "LANG"     => "en_US.UTF-8",
  "LANGUAGE" => "en_US.UTF-8",
  "LC_ALL"   => "en_US.UTF-8"
}

build do
  bundle "install --without development test --path=#{install_dir}/embedded/service/gem", :env => env
  command "mkdir -p #{install_dir}/embedded/service/revily-web"
  command "#{install_dir}/embedded/bin/rsync -a --delete --exclude=.git/*** --exclude=.gitignore ./ #{install_dir}/embedded/service/revily-web/"
end
