require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
require 'mina/rvm'    # for rvm support. (http://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :domain, '107.170.193.248'
set :deploy_to, '/home/yours'
set :repository, 'git@github.com:ws2367/xoxo.git'
#set :repository, 'https://github.com/ws2367/xoxo.git'
set :branch, 'sys/SSL'

# Optional SSH settings:
# SSH forward agent to ensure that credentials are passed through for git operations
set :forward_agent, true

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config/database.yml', 'log', 'config/apple_push_notification.pem', 
                    'config/app_credentials', 'config/photo_bucket_name', 'config/ssl/server.crt',
                    'config/ssl/server.key']

set :rails_env, 'development'
set :term_mode, :nil 
set :rvm_path, '/usr/local/rvm/scripts/rvm'

# Optional settings:
  set :user, 'deployer'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  invoke :'rvm:use[ruby-2.0.0-p353]'
  
end
##########################################################################
#
# Create new host tasks
# Tasks below are related to deploying a new version of the application
#
##########################################################################

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  queue  %[echo "-----> Fill in information below to populate 'shared/config/database.yml'."]
  invoke :'setup:db:database_yml'
end

# Populate file database.yml with the appropriate rails_env
# Database name and user name are based on convention
# Password is defined by the user during setup
desc "Populate database.yml"
task :'setup:db:database_yml' => :environment do
  db_name = "moose_#{rails_env}"
  puts "Database name is #{db_name}"
  #puts "Enter a name for the new database"
  #db_name = STDIN.gets.chomp
  # puts "Enter a user for the new database"
  # db_username = STDIN.gets.chomp
  # puts "Enter a password for the new database"
  # db_pass = STDIN.gets.chomp
  # Virtual Host configuration file
  database_yml = <<-DATABASE.dedent
    #{rails_env}:
      adapter: mysql2
      encoding: utf8
      database: #{db_name}
      pool: 5
      username: root
      password: moose
  DATABASE
  queue! %{
    echo "-----> Populating database.yml"
    echo "#{database_yml}" > #{deploy_to!}/shared/config/database.yml
    echo "-----> Done"
  }
end


desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    queue  %[cd #{deploy_to}/current; RAILS_ENV=#{rails_env} rake db:create]
    invoke :'rails:db_migrate'
    # invoke :'rails:db_migrate:force'
    
    to :launch do
      queue "touch #{deploy_to}/tmp/restart.txt"
      queue! %[cd #{deploy_to}/current; RAILS_ENV=#{rails_env} thin start --ssl --ssl-key-file config/ssl/server.key --ssl-cert-file config/ssl/server.crt -d]
    end
  end
end



task :log do
  queue 'echo "Contents of the log file are as follows:"'
  queue %[cd #{deploy_to!}/current && tail -f log/thin.log]
end


task :down do
  invoke :restart
  invoke :log
end

task :restart do
  queue 'sudo service nginx restart'
end

#########################################################################
#
# Libraries
#
##########################################################################
 
#
# See https://github.com/cespare/ruby-dedent/blob/master/lib/dedent.rb
#
class String
  def dedent
    lines = split "\n"
    return self if lines.empty?
    indents = lines.map do |line|
      line =~ /\S/ ? (line.start_with?(" ") ? line.match(/^ +/).offset(0)[1] : 0) : nil
    end
    min_indent = indents.compact.min
    return self if min_indent.zero?
    lines.map { |line| line =~ /\S/ ? line.gsub(/^ {#{min_indent}}/, "") : line }.join "\n"
  end
end
# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers

