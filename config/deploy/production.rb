server 'argonaut.slice', :app, :web, :db, :primary => true

set :environment, 'production'

manifest :app, %{
  floehopper::app {'jamesmead.org':
    deploy_to => "<%= deploy_to %>",
    domain => 'jamesmead.org'
  }
}