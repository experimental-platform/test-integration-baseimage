# -*- mode: ruby -*-
# # vi: set ft=ruby :
require 'erb'

Vagrant.require_version ">= 1.6.0"

hostname = ENV.fetch('CIRCLE_PROJECT_REPONAME') + "-" + ENV.fetch('CIRCLE_BUILD_NUM')

#channel = ENV.fetch('IMAGE') == 'coreos-alpha'? 'alpha' : 'beta'
# TODO retrieve AMI based on CoreOS channel and AWS region
ami = 'ami-27988717' # CoreOS beta 766.4.0

Vagrant.configure("2") do |config|
  config.vm.hostname = hostname
  config.ssh.insert_key = false
  config.ssh.username = false
  config.vm.synced_folder '.', '/vagrant', :disabled => true
  config.vm.box = 'dummy'
  config.vm.define hostname do |foobar|
  end
  config.vm.provider :aws do |aws, override|
    aws.user_data = ERB.new(IO.read('/cloud-config.yaml')).result
    aws.access_key_id = ENV.fetch('AWS_ACCESS_KEY_ID')
    aws.secret_access_key = ENV.fetch('AWS_SECRET_ACCESS_KEY')
    aws.security_groups = ['sg-7021b314', 'sg-a520b2c1'] # SSH ingress and Dokku security groups
    aws.block_device_mapping = [{ 'DeviceName' => '/dev/xvda', 'Ebs.VolumeSize' => 25 }]
    aws.instance_type = 't2.small'
    aws.associate_public_ip = true
    aws.ami = ami
    aws.tags = {:Name => hostname, :Test => "true"}
    aws.region = 'us-west-2'
    aws.subnet_id = 'subnet-849f0add'
    override.ssh.username = "root"
    override.ssh.private_key_path = "/.ssh/id_rsa"
  end
end
