#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'

require 'webby'
require 'delicious-api-via-oauth'
require 'yaml'

# See http://jamesmead.org/blog/2010-01-16-ruby-scripting-in-the-webby-environment

# load Sitefile
main = Webby::Apps::Main.new
main.init([])
main.app.init 'webby'
main.app.load_rakefile

# load helpers
include BlogHelper
include UrlHelper

# load pages, layouts, etc.
builder = Webby::Builder.new
builder.load_files
@pages = Webby::Resources.pages

# See http://jamesmead.org/blog/2010-01-14-ruby-wrapper-for-the-delicious-v2-api-using-the-oauth-gem

credentials = YAML.load_file('yahoo-credentials.yml')
api = Delicious::API.new(credentials[:api_key], credentials[:shared_secret])
INTERVAL_TO_AVOID_THROTTLING = 1

articles.each do |article|
  api.posts_add!(
    :url => absolute_url(friendly_url(article)),
    :description => article['title'] || '',
    :extended => article['description'] || '',
    :tags => [(article['keywords'] || ''), 'jamesmead.org', article.categories.map { |c| "category:#{c}"}.join(' ')].join(' ')
  )
  sleep INTERVAL_TO_AVOID_THROTTLING
end
