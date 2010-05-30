module BlogHelper
  
  def articles(options = {})
    pages = @pages.find(:all, {:in_directory => '/blog', :sort_by => 'created_at', :reverse => true}.merge(options))
    pages.reject { |page| %w(index feed).include?(page.filename) }
  end
  
end

Webby::Helpers.register(BlogHelper)