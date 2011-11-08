#! /bin/sh

sudo aptitude install ruby1.8-dev ruby1.8 ri1.8 rdoc1.8 irb1.8 libreadline-ruby1.8 libruby1.8 libopenssl-ruby wget
sudo ln -s /usr/bin/ruby1.8 /usr/bin/ruby
sudo ln -s /usr/bin/ri1.8 /usr/bin/ri
sudo ln -s /usr/bin/rdoc1.8 /usr/bin/rdoc
sudo ln -s /usr/bin/irb1.8 /usr/bin/irb

cd /tmp
wget http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz
tar xvzf rubygems-1.3.7.tgz
cd rubygems-1.3.7
sudo ruby setup.rb
sudo ln -s /usr/bin/gem1.8 /usr/bin/gem

sudo gem update --system
sudo gem install vagrant vagrant-snap vagrant-yaybu

