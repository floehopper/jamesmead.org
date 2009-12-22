module BlogHelper
  
  def blog_articles
    articles = @pages.find(:all, :in_directory => '/blog', :sort_by => 'created_at', :reverse => true)
    articles.reject { |page| page.filename == 'index' }
  end
  
end

Webby::Helpers.register(BlogHelper)