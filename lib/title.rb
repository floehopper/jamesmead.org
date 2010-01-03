module TitleHelper
  
  def title(page)
    title = page.title
    return title if title == 'James Mead'
    [title, 'James Mead'].join(' - ')
  end
  
end

Webby::Helpers.register(TitleHelper)