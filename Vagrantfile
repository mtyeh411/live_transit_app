# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'json'

PACKER_AWS_CONFIG = JSON.parse(File.read('ops/app_image.json'))['builders'].select { |b| b['type'] == 'amazon-ebs' }.first

Vagrant.configure('2') do |config|
  config.vm.define "local" do |local|
    local.vm.box     = 'precise64'
    local.vm.box_url = 'http://files.vagrantup.com/precise64.box'

    local.vm.hostname = 'gtfsr'
    local.vm.network :forwarded_port, guest: 3000, host: 3000
    local.vm.network :forwarded_port, guest: 5001, host: 5001 
    local.vm.network :forwarded_port, guest: 6379, host: 6379

    local.vm.provision :shell, path: 'ops/bootstrap_puppet.sh'
    local.vm.provision :puppet do |puppet|
      puppet.manifests_path   = 'ops/puppet/manifests'
      puppet.module_path      = 'ops/puppet/modules'
      puppet.manifest_file    = 'default.pp'
      puppet.options          = '--verbose'
    end
  end


  config.vm.define "aws2" do |aws|
    aws.vm.box      = 'dummy'
    aws.vm.box_url  = 'https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box'
    aws.vm.provider :aws do |aws, override|
      aws.access_key_id = PACKER_AWS_CONFIG['access_key']
      aws.secret_access_key = PACKER_AWS_CONFIG['secret_key']

      aws.ami = 'ami-1d633474' # packer artifact
      aws.instance_type = PACKER_AWS_CONFIG['instance_type']
      aws.region = PACKER_AWS_CONFIG['region']

      aws.security_groups = ['node', 'web', 'ssh', 'redis']
      aws.keypair_name = 'ride-ontime.com'

      aws.tags = {
        :name => 'gtfsr'
      }

      override.vm.synced_folder ".", "/vagrant", disabled: true
      override.ssh.username = 'ubuntu'
      override.ssh.private_key_path = '/Users/myeh/proj/ec2_keypairs/rideon/ride-ontime.com/ride-ontime.com.pem'
    end
  end

  config.vm.provider 'virtualbox' do |vb|
    vb.gui = true
    # http://github.com/rubygems/rubygems/issues/513#issuecomment-24156984
    vb.customize ['modifyvm', :id, '--natdnsproxy1', 'off'] 
    vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'off']
  end
end
