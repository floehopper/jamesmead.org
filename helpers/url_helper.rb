module UrlHelper
  def absolute_url(relative_url)
    "http://#{config[:host]}#{relative_url}"
  end
end
