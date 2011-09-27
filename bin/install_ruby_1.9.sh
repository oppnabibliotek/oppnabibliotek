#!/bin/bash
#===============================================================================
#          FILE:  install_ruby_1.9.sh
# 
#         USAGE:  ./install_ruby_1.9.sh 
# 
#        AUTHOR: Ryan Schulze (rs), ryan@dopefish.de
#       CREATED: 07/07/2011 11:59:37 AM CDT
#===============================================================================
 
Version="1.9.2-p290"
GZFile="ruby-${Version}.tar.gz"
Download="http://ftp.ruby-lang.org/pub/ruby/1.9/${GZFile}"
 
if [[ "$(id -u)" != "0" ]]
then
        echo "You need root permission to execute this script"
        exit
fi
 
apt-get -q update
apt-get -qy upgrade
apt-get install -qy build-essential wget zlib1g-dev libssl-dev libffi-dev autoconf
 
cd /usr/local/src/
test -e ${GZFile} || wget ${Download}
tar -xzf ${GZFile}
cd ruby-${Version}
 
autoconf
./configure --with-ruby-version=${Version} --prefix=/usr --program-suffix=${Version} 
make
make install
 
mkdir -p /usr/lib/ruby/gems/${Version}/bin
update-alternatives \
        --install /usr/bin/ruby ruby /usr/bin/ruby${Version} $(echo ${Version//./}|cut -d- -f1) \
        --slave   /usr/share/man/man1/ruby.1.gz ruby.1.gz /usr/share/man/man1/ruby${Version}.1 \
        --slave   /usr/lib/ruby/gems/bin        gem-bin   /usr/lib/ruby/gems/${Version}/bin \
        --slave   /usr/bin/erb  erb  /usr/bin/erb${Version} \
        --slave   /usr/bin/irb  irb  /usr/bin/irb${Version} \
        --slave   /usr/bin/rdoc rdoc /usr/bin/rdoc${Version} \
        --slave   /usr/bin/ri   ri   /usr/bin/ri${Version} \
        --slave   /usr/bin/gem  gem  /usr/bin/gem${Version} \
 
update-alternatives --config ruby
update-alternatives --display gem >/dev/null 2>&1 && update-alternatives --remove-all gem
 
echo "[+] Done installing"
ruby -v

