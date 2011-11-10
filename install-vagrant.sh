#! /bin/sh

bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)

echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"' >> ~/.bash_profile

. "$HOME/.rvm/scripts/rvm"

rvm install 1.9.2
rvm use 1.9.2
rvm --default 1.9.2

gem update
gem install vagrant vagrant-snap vagrant-yaybu

