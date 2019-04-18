set :application, 'vatican_exhibits'
set :repo_url, 'https://github.com/sul-dlss/vatican_exhibits.git'

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :deploy_to, '/srv/app'

set :linked_files, %w{config/honeybadger.yml public/robots.txt}

set :linked_dirs, %w{config/settings log tmp/pids tmp/cache tmp/sockets public/uploads}

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      within release_path do
        execute :rake, 'tmp:cache:clear'
      end
    end
  end
end
