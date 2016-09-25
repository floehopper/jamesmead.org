module BlogHelper
  def articles
    blog.articles.sort_by { |a| a.data.created_at }.reverse
  end
end
