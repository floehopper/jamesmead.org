#!/usr/bin/env bash
set -e
apt-get update --yes
apt-get install software-properties-common
apt-add-repository ppa:brightbox/ruby-ng
apt-get update --yes
apt-get --yes install ruby2.3

# For building native extensions
apt-get --yes install ruby2.3-dev

# For building event-machine native extension
apt-get --yes install g++

# JavaScript runtime for coffee-script
apt-get --yes install node.js

apt-get install --yes apache2

cat <<EOF >/etc/apache2/sites-available/jamesmead.dev.conf
<VirtualHost *:80>
  ServerName jamesmead.dev
  DocumentRoot /vagrant/build
  <Directory "/vagrant/build">
    Require all granted
    Options MultiViews
  </Directory>
</VirtualHost>
EOF

a2ensite jamesmead.dev

systemctl start apache2

gem install bundler
