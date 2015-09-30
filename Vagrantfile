# -*- mode: ruby -*-
# # vi: set ft=ruby :
require 'erb'

Vagrant.require_version ">= 1.6.0"

hostname = ENV.fetch('CIRCLE_PROJECT_REPONAME') + "-" + ENV.fetch('CIRCLE_BUILD_NUM')
channel = ENV.fetch('IMAGE', 'beta')
region = 'us-west-2'

def aws_image_parse(aws_image)
	version = aws_image.name.split("-")[2].split(".")
	{:release => version[0].to_i, :branch => version[1].to_i, :patch => version[2].to_i, :id => aws_image.image_id }
end

def get_coreos_amis_for_channel(channel, region)
	default = 'beta'
	chan = case channel
	when 'coreos-stable'
		'stable'
	when 'coreos-alpha'
		'alpha'
	when 'coreos-beta'
		'beta'
	else
		default
	end

	ec2 = Aws::EC2::Client.new(region: region)

	name_glob = "CoreOS-" + chan + "-*"
	result = ec2.describe_images({
		filters: [
	    { name: "virtualization-type", values: ["hvm"] },
			{ name: "name",	values: ["CoreOS-beta-7*"] }
	  ]})

	result.images.map{|x| aws_image_parse(x) }
end

def pick_latest_ami_id(imagelist)
	imagelist.sort_by{ |e| [ e[:release], e[:branch], e[:patch] ]}.last
end

print "Finding AMI ID for '" + channel + "'... "
images = get_coreos_amis_for_channel(channel, region)
ami = pick_latest_ami_id(images)
print ami[:id] + "\n"

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
    aws.ami = ami[:id]
    aws.tags = {:Name => hostname}
    aws.region = region
    aws.subnet_id = 'subnet-849f0add'
    override.ssh.username = "root"
    override.ssh.private_key_path = "/.ssh/id_rsa"
  end
end
