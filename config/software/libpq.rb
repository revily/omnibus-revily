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

name "libpq"
version "9.3.1"

dependency "zlib"
dependency "openssl"
dependency "libedit"
dependency "ncurses"

source :url => "http://ftp.postgresql.org/pub/source/v9.3.1/postgresql-#{version}.tar.gz",
       :md5 => "58edfab25d6bb243ff2c8bf2d2df34d3"

relative_path "postgresql-#{version}"
# libpq_source_dir = "#{project_dir}/src/interfaces/libpq"

env = {
  "LDFLAGS" => "-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include",
  "CFLAGS" => "-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include",
  "LD_RUN_PATH" => "#{install_dir}/embedded/lib"
}

build do
  command [ "./configure",
            "--prefix=#{install_dir}/embedded",
            "--with-libedit-preferred",
            "--with-openssl",
            "--with-includes=#{install_dir}/embedded/include",
            "--with-libraries=#{install_dir}/embedded/lib" ].join(" "), :env => env
  command "make -j #{max_build_jobs}", :env => { "LD_RUN_PATH" => "#{install_dir}/embedded/lib"}
  # command "make install"
  command "mkdir -p #{install_dir}/embedded/include/postgresql"
  command "make -C src/include install"
  command "make -C src/interfaces install"
  command "make -C src/bin/pg_config install"

  %w[ libpq-fe.h libpq-events.h  ]
end

# build do
#   command [ "./configure",
#             "--prefix=#{install_dir}/embedded",
#             "--with-libedit-preferred",
#             "--with-openssl",
#             "--with-includes=#{install_dir}/embedded/include",
#             "--with-libraries=#{install_dir}/embedded/lib" ].join(" "), :env => configure_env
#   command "make -j #{max_build_jobs}", :env => {"LD_RUN_PATH" => "#{install_dir}/embedded/lib"}
#   command "make install"
# end
