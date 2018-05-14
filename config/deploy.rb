set :application, 'vatican_exhibits'
set :repo_url, 'https://github.com/sul-dlss/vatican_exhibits.git'

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :deploy_to, '/srv/app'

set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets}
