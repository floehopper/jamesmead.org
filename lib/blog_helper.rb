module BlogHelper
  
  def articles(options = {})
    pages = @pages.find(:all, options.merge(:in_directory => '/blog', :sort_by => 'created_at', :reverse => true))
    pages.reject { |page| page.filename == 'index' }
  end
  
end

Webby::Helpers.register(BlogHelper)