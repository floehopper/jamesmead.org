module LinkHelper
  
  def absolute_url(relative_url)
    "http://#{Webby.site.host}#{relative_url}"
  end
  
end

Webby::Helpers.register(LinkHelper)