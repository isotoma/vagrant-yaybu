#! /bin/bash

sudo aptitude purge rubygems ruby-rvm
sudo aptitude install zlib1g-dev # might need earlier version

bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)

echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"' >> ~/.bash_profile

. "$HOME/.rvm/scripts/rvm"

rvm install 1.9.2
rvm use 1.9.2
rvm --default 1.9.2

gem update
gem install vagrant --version 0.8.7
gem install vagrant-snap vagrant-yaybu

