module UrlHelper
  
  def absolute_url(relative_url)
    "http://#{Webby.site.host}#{relative_url}"
  end
  
end

Webby::Helpers.register(UrlHelper)