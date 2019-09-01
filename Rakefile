require 'middleman-gh-pages'

desc 'builds and deploys the website'
task 'deploy' do
  sh 'middleman build'
  sh 'rsync -avz build/ travisci@skua.jamesmead.org:/var/www/jamesmead.org'
end
