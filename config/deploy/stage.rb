server 'vatican-dev.sul.stanford.edu', user: 'centos', roles: %w{app db web background}, my_property: :my_value

set :rails_env, 'production'

set :sidekiq_roles, :background
set :sidekiq_processes, 2
