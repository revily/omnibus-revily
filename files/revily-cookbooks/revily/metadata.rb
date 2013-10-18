maintainer        "Applied Awesome LLC."
maintainer_email  "hi@revi.ly"
license           "Apache 2.0"
description       "Installs and configures Revily from Omnibus"
long_description       "Installs and configures Revily from Omnibus"
version           "0.1.0"
recipe            "revily", "Configures Revily from Omnibus"

%w{ ubuntu debian redhat centos }.each do |os|
  supports os
end

depends "runit"
