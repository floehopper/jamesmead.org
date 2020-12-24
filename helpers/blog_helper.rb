module BlogHelper
  def articles
    blog('blog').articles.sort_by { |a| a.data.created_at }.reverse
  end

  def notes
    blog('notes').articles.sort_by { |a| a.data.created_at }.reverse
  end
end
