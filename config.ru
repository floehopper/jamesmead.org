require 'rubygems'
require 'bundler/setup'
require 'rack/static'
require 'rack/rewrite'

use Rack::Rewrite do
  rewrite %r{(.*)\/$}, '$1/index.html'
  rewrite %r{\/[^.]+$}, '$&.html'
end
use Rack::Static, :urls => [''], :root => 'output'

run Rack::Builder.new
