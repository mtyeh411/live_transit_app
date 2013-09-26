# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

Vagrant.configure('2') do |config|
  config.vm.define "local" do |local|
    local.vm.box     = 'precise64'
    local.vm.box_url = 'http://files.vagrantup.com/precise64.box'

    local.vm.hostname = 'gtfsr'
    local.vm.network :forwarded_port, guest: 3000, host: 3000
    local.vm.network :forwarded_port, guest: 5001, host: 5001 
    local.vm.network :forwarded_port, guest: 6379, host: 6379
  end

  if File.exists? 'config/vagrant/aws.yml'
    CONFIG = YAML.load File.read('config/vagrant/aws.yml')
    config.vm.define "aws" do |aws|
      aws.vm.box      = 'dummy'
      aws.vm.box_url  = 'https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box'

      aws.vm.provider :aws do |aws, override|
        apply_settings aws, CONFIG['aws']

        CONFIG['aws']['override'].keys.each do |k|
          apply_settings override.send(k), CONFIG['aws']['override'][k]
        end
        
      end
    end

    config.vm.define "aws-32" do |aws|
      aws.vm.box      = 'dummy'
      aws.vm.box_url  = 'https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box'

      aws.vm.provider :aws do |aws, override|
        apply_settings aws, CONFIG['aws']
        aws.ami = 'ami-e1ade488'

        CONFIG['aws']['override'].keys.each do |k|
          apply_settings override.send(k), CONFIG['aws']['override'][k]
        end
        
      end
    end
  end

  config.vm.provider 'virtualbox' do |vb|
    vb.gui = true
    # http://github.com/rubygems/rubygems/issues/513#issuecomment-24156984
    vb.customize ['modifyvm', :id, '--natdnsproxy1', 'off'] 
    vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'off']
  end

  config.vm.provision :shell, path: 'config/vagrant/bootstrap_puppet.sh'
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path   = 'puppet/manifests'
    puppet.module_path      = 'puppet/modules'
    puppet.manifest_file    = 'default.pp'
    puppet.options          = '--verbose'
  end
end

def apply_settings(obj, settings)
  settings.each do |key, value|
    msg = "#{key}="
    obj.send(msg, value) if obj.respond_to?(msg)
  end
end
