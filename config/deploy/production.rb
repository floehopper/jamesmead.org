server 'argonaut.slice', :app, :web, :db, :primary => true

manifest :app, %{
  floehopper::webby_app {'jamesmead.org':
    deploy_to => "<%= deploy_to %>",
    domain => 'jamesmead.org'
  }
}