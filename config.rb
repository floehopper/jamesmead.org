###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.xml.erb', layout: false
page '/*.json', layout: false
page '/*.js', layout: false
page '/*.txt', layout: false

# With alternative layout
# page "/path/to/file.html", layout: :otherlayout

page 'index.html', layout: :home

page 'blog/index.html', layout: :other
page 'blog/*', layout: :blog

page 'adventures/*', layout: :other
page 'legacy/*', layout: :other
page 'pages/*', layout: :other
page 'projects/*', layout: :other
page 'talks/*', layout: :other
page 'wiki/*', layout: :other

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

# General configuration

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
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript
end

activate :blog do |blog|
  blog.prefix = "blog"
  blog.permalink = "{year}-{month}-{day}-{title}.html"
end

config[:feed_url] = 'http://feeds.jamesmead.org/floehopper-blog'
config[:host] = 'jamesmead.org'

config[:textile] = { no_span_caps: true }

config[:markdown] = { auto_ids: false }

Time::DATE_FORMATS[:long] = "%d %b %Y at %H:%M"
