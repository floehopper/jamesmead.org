module TitleHelper
  def title(page)
    title = page.data.title
    if title.blank?
      html = page.render(layout: false)
      text = Sanitize.clean(html)
      title = text.truncate_words(10)
    end
    [title, 'James Mead'].uniq.join(' - ')
  end
end
