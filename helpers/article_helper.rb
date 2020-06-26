module ArticleHelper
  def article_class
    case current_page.path
    when %r{^blog/index.html$}
      nil
    when %r{^blog/}
      'h-entry'
    when %r{^index.html$}
      'h-card'
    else
      nil
    end
  end

  def title_class
    case current_page.path
    when %r{^blog/index.html$}
      nil
    when %r{^blog/}
      'p-name'
    when %r{^index.html$}
      'p-name'
    else
      nil
    end
  end

  def article_tag(&block)
    content_tag(:article, class: article_class) do
      h1 = content_tag(:h1, current_page.data.title, class: title_class)

      h1 + block.call
    end
  end
end
