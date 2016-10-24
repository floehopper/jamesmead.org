###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page "/path/to/file.html", layout: :otherlayout

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

# General configuration

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
end

###
# Helpers
###

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

# Build-specific configuration
configure :build do
  # Minify CSS on build
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript
end

activate :blog do |blog|
  blog.prefix = "blog"
  blog.permalink = "{year}-{month}-{day}-{title}.html"
end

config[:feed_url] = 'http://feeds.jamesmead.org/floehopper-blog'
config[:host] = 'jamesmead.org'

config[:textile] = { no_span_caps: true }
config[:css_dir] = 'style'

config[:markdown] = { auto_ids: false }

activate :deploy do |deploy|
  deploy.deploy_method = :rsync
  deploy.host = 'skua.jamesmead.org'
  deploy.user = 'travisci'
  deploy.path = '/var/www/jamesmead.org'
  deploy.clean = true
end
