module PageHelper
  
  def sorted_pages_without_index(directory)
    pages = @pages.find(:all, :in_directory => directory, :sort_by => 'created_at', :reverse => true)
    pages.reject { |page| page.filename == 'index' }
  end
  
end

Webby::Helpers.register(PageHelper)