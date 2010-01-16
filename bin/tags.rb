require 'webby'

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

require 'delicious_oauth'
access_token = DeliciousOAuth.access_token
INTERVAL_TO_AVOID_THROTTLING = 1

articles.each do |article|
  params = {
    :url => absolute_url(friendly_url(article)),
    :title => article['title'] || '',
    :notes => article['description'] || '',
    :tags => (article['keywords'] || '').split(' ') + %w(jamesmead.org)
  }
  query = params.map { |k, v| "#{CGI.escape(k)}=#{CGI.escape(v)}" }.join('&')
  url = "https://api.del.icio.us/v1/posts/add?" + query
  access_token.get(url)
  sleep INTERVAL_TO_AVOID_THROTTLING
end