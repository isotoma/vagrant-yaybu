# This is a demo Vagrantfile to prove that vagrant-yaybu is working correctly

# When you install this gem (using ``gem install vagrant-yaybu``) you do not
# need to ``require`` the provisioner. We do so here so that the development
# version is loaded.
require "lib/vagrant-yaybu/provisioner.rb"


Vagrant::Config.run do |config|
  config.vm.box = "lucid64"
  # config.vm.box_url = "http://domain.com/path/to/above.box"


  config.vm.provision :yaybu do |cfg|

    # You can add directories and remote locations to the search path
    # Both Yay files and assets (templates, etc) will be fetched from here.
    # The default search path is the current working directory
    #cfg.searchpath << "file:///home/john/Projects/yaybu-configuration/"
    cfg.searchpath << "https://raw.github.com/isotoma/yaybu-examples/master/"

    # You can load any config that is on the searchpath
    cfg.include << "configuration/minecraft.yay"

    # The ``yay`` parameter lets you put arbritrary config inside your Vagrant file
    cfg.yay  = <<-EOS
      resources.append:
        - Execute:
            name: example
            comamnd: date
    EOS

    # Advanced Yaybu hackers might not want to use the default python or a packaged
    # version of Yaybu. You can set this to point at your development environment.
    cfg.python = "/opt/virtualenvs/yaybu/bin/python"

  end
end

