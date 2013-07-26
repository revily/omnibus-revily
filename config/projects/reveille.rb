
name "reveille"
maintainer "CHANGE ME"
homepage "CHANGEME.com"

replaces        "reveille"
install_path    "/opt/reveille"
build_version   Omnibus::BuildVersion.new.semver
build_iteration 1

# creates required build directories
dependency "preparation"

# reveille dependencies/components
# dependency "somedep"

# version manifest file
dependency "version-manifest"

exclude "\.git*"
exclude "bundler\/git"
