ask(:user, 'deploy_user')
ask(:server_name, 'server_name')
ask(:port, 'ssh_port')

set :deploy_to, '/srv/app'

server fetch(:server_name), user: fetch(:user), roles: %w(web db app), port: fetch(:port)
set :bundle_without, %w(test deployment development).join(' ')

set :rails_env, 'production'

set :sidekiq_role, :background
set :sidekiq_processes, 2

after 'deploy:updated', 'newrelic:notice_deployment'
 
