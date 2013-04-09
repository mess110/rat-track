load 'deploy'

DEPLOY_TO = '/home/cristian/rat-track'

default_run_options[:pty] = true

set :application, 'rat-track'
set :user, 'cristian'

ssh_options[:forward_agent] = true

set :scm, :git
set :repository, 'git@github.com:mess110/rat-track.git'

server 'northpole.ro', :app, :primary => true
set :deploy_to, DEPLOY_TO
set :keep_releases, 5

namespace :rat do
  task :stop, :roles => :app, :on_error => :continue do
    path = File.join(DEPLOY_TO, 'current')
    sudo 'whoami'
    run "cd #{path}; rvmsudo bundle exec thin stop;"
  end

  task :start, :roles => :app do
    path = File.join(DEPLOY_TO, 'current')
    sudo 'whoami'
    run "cd #{path}; rvmsudo bundle exec thin -C ~/rat-track/current/config.yml start"
  end

  task :symlink do
    run "rm -rf #{release_path}/public/videos"
    run "mkdir -p #{shared_path}/videos"
    run "ln -nfs #{shared_path}/videos #{release_path}/public/videos"
  end
end

before "deploy", "rat:stop"
after "deploy", "rat:start"
after "deploy:update", "deploy:cleanup"

after "deploy:update_code", "rat:symlink"
