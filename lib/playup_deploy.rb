#!/usr/bin/env ruby

require 'rubygems'
require 'optparse'
require 'yaml'

begin
  require 'fog'
rescue LoadError
  warn "fog not installed"
end

def dew_account_path(account_name)
  File.join(ENV['HOME'], '.dew', 'accounts', "#{account_name}.yaml")
end

def fetch_ec2_server_by_logical_id(account_name, region, environment, logical_id)

  load_account_info(account_name)
  # puts @account_info.inspect

  ec2 = Fog::Compute.new(
    :region => region,
    :provider => "AWS",
    :aws_access_key_id => @account_info['aws']['access_key_id'],
    :aws_secret_access_key => @account_info['aws']['secret_access_key']
  )

  ec2_dns_names = []

  if ENV['NEW_HOST_DEPLOYMENT']
    puts "Derected a new host deployment - not querying AWS for host information"
    puts "New host is #{ENV['NEW_HOST_DEPLOYMENT']}"
    ec2_dns_names[0] = ENV['NEW_HOST_DEPLOYMENT']
  else
    puts "Querying the AWS API to find #{logical_id} in environment #{environment}."
    instances = ec2.servers.all
    instances.reject!{|instance| instance.dns_name.nil? }  #dead or out of service instances dont have a dns

    instances.each do |instance|
      matching_instance_stack = instance.tags.any?{|instance_tag_key,instance_tag_val|
        instance_tag_key == "aws:cloudformation:stack-name" && instance_tag_val.match(/^#{environment}/)
      }
      matching_instance_id = instance.tags.any?{|instance_tag_key,instance_tag_val|
        instance_tag_key == "aws:cloudformation:logical-id" && instance_tag_val.match(/^#{logical_id}/)
      }
      ec2_dns_names << instance.dns_name if matching_instance_stack && matching_instance_id
    end
  end
  ec2_dns_names
end

def load_account_info(account_name)
  @account_info = YAML.load_file(dew_account_path(account_name))
end



