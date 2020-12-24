module TitleHelper
  def title(page)
    [page.data.title, 'James Mead'].uniq.compact.join(' - ')
  end
end
