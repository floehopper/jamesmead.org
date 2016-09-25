module TitleHelper
  def title(page)
    title = page.data.title
    return title if title == 'James Mead'
    [title, 'James Mead'].join(' - ')
  end
end
