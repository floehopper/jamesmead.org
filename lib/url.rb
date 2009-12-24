module UrlHelper
  
  def absolute_url(relative_url)
    "http://#{Webby.site.host}#{relative_url}"
  end
  
  def friendly_url(page)
    page.url.sub(/\.html$/, '')
  end
  
end

Webby::Helpers.register(UrlHelper)