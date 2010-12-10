set :stages, %w(production)
set :default_stage, "production"

require 'freerange/deploy'
require 'freerange/puppet'
require 'floehopper/deploy'

set :repository, 'git@github.com:floehopper/jamesmead.org.git'
set :application, 'jamesmead.org'

namespace :deploy do
  task :migrate do ; end
end