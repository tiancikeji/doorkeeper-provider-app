set :application, "doorkeeper-provider-app"
set :use_sudo, false
set :scm, :none
# set :branch, 'master'
set :repository,  '.'
set :keep_releases, 5
set :user, "root"
set :deploy_to, '/apps/doorkeeper'
set :rails_env, 'production'


role :web ,'10.96.126.17' #, '10.96.126.17' ,'10.96.126.20'
role :app ,'10.96.126.17' #, '10.96.126.17' ,'10.96.126.20'
role :db, '10.96.126.17', :primary => true #'10.96.126.17' ,'10.96.126.20', 

# set :deploy_via, :remote_cache
set :deploy_via, :copy

namespace :bundle do
  desc "run bundle install and ensure all gem requirements are met"
  task :install do
    run "cd #{current_path} && bundle install"
  end
end

namespace :assets do
  desc "run asstes:precompile"
  task :precompile do
    run "cd #{current_path} && bundle exec rake assets:precompile:primary"
  end
end

namespace :deploy do
  task :copy_config_files, :roles => [:app] do
    config_files = "#{shared_path}/config/*.yml"
    run "cp #{config_files} #{release_path}/config/"
  end
  desc "Start the Thin processes"
  task :start do 
    run "cd  #{current_path} && bundle exec thin start -C config/thin.yml"
  end
  task :stop do 
    run "cd  #{current_path} && bundle exec thin stop -C config/thin.yml"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "cd  #{current_path} && bundle exec thin restart -C config/thin.yml"
  end
  task :seed do
    run "cd  #{current_path} && bundle exec rake RAILS_ENV=#{rails_env} db:seed"
  end
end

before "deploy:migrate", "bundle:install"
before "deploy:restart", "deploy:migrate" 
#after "deploy:migrate", "deploy:seed"

after "bundle:install", "assets:precompile"

after "deploy:finalize_update", "deploy:copy_config_files" 
after "deploy:restart", "deploy:cleanup" 


