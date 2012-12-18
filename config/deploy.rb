require 'bundler/capistrano'
require 'rvm/capistrano'

set :user,              'ubuntu'
set :application,       'whizz_kid'
set :scm,               :git
set :repository,        'git@github.com:benkitzelman/whizz_kid.git'

set :deploy_to,         "/home/#{user}/#{application}"
set :deploy_via,        :remote_cache
set :branch,            ENV['BRANCH'] || 'production'
# set :git_shallow_clone, 1
set :scm_verbose,       true
set :use_sudo,          false
set :keep_releases,     3

default_run_options[:pty]   = true  # Must be set for the password prompt from git to work
ssh_options[:forward_agent] = true  # use local keys for remote deployment

# rvm
set :rvm_path,          '/usr/local/rvm'
set :rvm_bin_path,      '/usr/local/rvm/bin'
set :rvm_ruby_string,   'ruby-1.9.3-p194'
set :rvm_type,          :system

# ----------------- based on playup api config ------------------------------------------

def stage name = nil
  return fetch(:stage) if name == nil      # so we can have a var named stage as well

  task name do
    set :stage, name.to_s
    yield
  end
end

def cloud_stage name, options = {}
  stage name do
    set :user, 'ubuntu'
    set :rails_env, name.to_s

    account         = options.fetch(:account, 'development')
    region          = options.fetch(:region, 'us-west-1')
    pem             = options.fetch(:pem, 'devops.pem')
    #dew_environment = options.fetch(:dew_environment, "#{application}-#{stage}")
    key             = options.fetch(:key, "~/.dew/accounts/keys/#{account}/#{region}/#{pem}")
    roles           = [:web, :app, :db] + [options.fetch(:extra_roles, [])].flatten

    ssh_options[:keys] = [key]
    application_group  = options[:application_group]
    set :account_info, load_account_info(account)

    # inconsistent environment names :'(
    app_env = "tms#{name}"

    # load app servers
    fetch_ec2_server_by_logical_id(account, region, app_env, application_group).each_with_index do |server_dns, i|
      puts "app server #{server_dns}"
      server server_dns, *roles, :primary => (i == 0)
    end

    yield if block_given?
  end
end

################################################################################
# Stages
################################################################################

cloud_stage :development,
  :application_group => 'TMSASGroup',
  :region => 'us-west-2',
  :pem => 'cloudformation-us-west-2.pem',
  :account => 'system-test' do
    set :server_name, 'localhost:9999'
end

cloud_stage :systest,
  :dew_environment => 'reboot-systest',
  :application_group => 'TMSASGroup',
  :region => 'us-west-2',
  :pem => 'cloudformation-us-west-2.pem',
  :account => 'system-test' do
    set :server_name, 'systest.tms.playupdev.com:9999'
end

cloud_stage :integration,
  :dew_environment => 'integration-API',
  :application_group => 'TMSASGroup',
  :region => 'us-west-2',
  :pem => 'cloudformation-us-west-2.pem',
  :account => 'system-test' do
    set :server_name, 'integration.tms.playupdev.com:9999'
end

cloud_stage :loadtest,
  :dew_environment => 'loadtesting3-API',
  :application_group => 'TMSASGroup',
  :region => 'us-west-2',
  :pem => 'cloudformation-us-west-2.pem',
  :account => 'system-test' do
    set :server_name, 'loadtest.tms.playupdev.com:9999'
end

cloud_stage :tiles,
  :dew_environment => 'tiles-API',
  :application_group => 'TMSASGroup',
  :region => 'us-west-2',
  :pem => 'cloudformation-us-west-2.pem',
  :account => 'system-test' do
    set :server_name, 'tiles.tms.playupdev.com:9999'
  end

cloud_stage :staging,
  :dew_environment => 'staging-API',
  :application_group => 'TMSASGroup',
  :region => 'us-west-2',
  :pem => 'cloudformation-us-west-2.pem',
  :account => 'system-test' do
    set :server_name, 'staging.tms.playupdev.com:9999'
end

before 'deploy:restart', 'deploy:nginx:configure'
after  'deploy:restart', 'deploy:tag'

namespace :assets do
  desc 'precompile assets'
  task :precompile do
    run "cd #{release_path} && ./bin/rake assetpack:build"
  end
end

namespace :deploy do
  APP_RESTART_ROLE = {:roles => :app, :except => { :no_release => true }}
  APP_ROLE         = {:roles => :app}

  after 'deploy:cold',
    'deploy:nginx:configure', 'deploy:nginx:restart', 'deploy:varnish:configure', 'deploy:varnish:restart'

  # NOP default migrations recipes.
  [:migrate, :migrations].each do |name|
    task(name) {}
  end

  desc 'restart server'
  task :restart, APP_RESTART_ROLE do
    run "cd #{current_path} && ./script/server -E #{stage} restart"
  end

  desc 'start server'
  task :start, APP_RESTART_ROLE do
    deploy.restart
  end

  namespace :varnish do
    desc 'setup varnish config'
    task :configure, APP_ROLE do
      base    = File.join(current_path, 'config/varnish')
      configs = {'varnish' => '/etc/default/varnish', 'default.vcl' => '/etc/varnish/default.vcl'}

      configs.each do |source, destination|
        source = File.join(base, source)
        sudo "/bin/bash -c 'rm -f #{destination}'"
        sudo "/bin/bash -c 'cp --force #{source} #{destination}'"
      end
    end

    desc 'restart varnish'
    task :restart, APP_ROLE do
      sudo "/bin/bash -c 'service varnish restart'"
    end
  end

  namespace :nginx do
    desc 'install nginx configs'
    task :configure, APP_ROLE do
      run  "cd #{current_path}/config/nginx && ln -sfT environments/#{stage} stage"
      sudo "cp #{current_path}/config/nginx/whizz_kid.conf /etc/nginx/sites-enabled/#{application}.conf"
    end

    desc 'reload nginx config'
    task :reload, APP_ROLE do
      sudo "service nginx reload"
    end

    desc 'restart nginx'
    task :restart, APP_ROLE do
      sudo "service nginx restart"
    end
  end

  desc 'tag deployed changeset'
  task :tag do
    tag   = stage.to_s.upcase
    user  = %x{git config --get user.name}.strip
    email = %x{git config --get user.email}.strip
    tag   = "#{tag}-#{Time.now.utc.strftime('%Y%m%d.%H%M%S')}"

    cli   = []
    cli  << %Q{git tag -m "#{tag} deployed off #{branch} by #{user} (#{email})" #{tag} #{branch}}
    cli  << %Q{git push --tags}

    cli.each do |command|
      if dry_run
        logger.debug "running locally: #{command}"
      else
        system(command) or raise "#{command} failed"
      end
    end
  end
end
