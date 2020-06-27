module UrlHelper
  def absolute_url(relative_url)
    "https://#{config[:host]}#{relative_url}"
  end

  def friendly_url(page)
    page.url.sub(/\.html$/, '')
  end
end
