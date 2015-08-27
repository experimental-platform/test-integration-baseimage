# -*- mode: ruby -*-
# # vi: set ft=ruby :
require 'erb'

Vagrant.require_version ">= 1.6.0"

hostname = "test-frontend"

Vagrant.configure("2") do |config|
  config.vm.hostname = hostname
  config.ssh.insert_key = false
  config.ssh.username = false
  config.ssh.private_key_path = '/.ssh/id_rsa'
  config.vm.synced_folder '.', '/vagrant', :disabled => true
  config.vm.box = 'digital_ocean'
  config.vm.box_version = ">= 308.0.1"
  config.vm.box_url = 'http://beta.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json'
  # config.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
  config.vm.define hostname do |foobar|
  end
  config.vm.provider :digital_ocean do |provider, override|
    provider.user_data = ERB.new(IO.read('/cloud-config.yaml')).result
    provider.name = ENV.fetch('HOSTNAME')
    provider.ssh_key_name = 'CircleCI Integration Test: ' + ENV.fetch('HOSTNAME')
    provider.token = ENV.fetch('APIKEY')
    provider.image = ENV.fetch('IMAGE')
    provider.region = 'nyc2'
    provider.size = '1gb'
    provider.check_guest_additions = false
    provider.functional_vboxsf = false
  end
end
