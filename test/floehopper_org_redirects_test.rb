require 'test/unit'
require 'test_helper'

class FloehopperOrgRedirectsTest < Test::Unit::TestCase
  
  include TestHelper
  
  # I don't think this is needed for now - we can just point feedburner at the new source
  # as long as this source url has never been used externally and I think it hasn't
  # def test_legacy_feedburner_source
  #   assert_redirects blog_floehopper_org('/feedburner.xml'), jamesmead_org('/blog/index.xml')
  # end
  
  def test_legacy_domain
    assert_redirects floehopper_org('/'), jamesmead_org('/')
  end
  
  def test_legacy_sub_domains
    assert_redirects blog_floehopper_org('/'), jamesmead_org('/')
    assert_redirects www_floehopper_org('/'), jamesmead_org('/')
  end
  
  def test_legacy_blog_articles
    assert_redirects blog_floehopper_org(old_article_path), jamesmead_org(new_article_path)
    assert_redirects www_floehopper_org(old_article_path), jamesmead_org(new_article_path)
    assert_redirects floehopper_org(old_article_path), jamesmead_org(new_article_path)
  end
  
  def test_legacy_feeds
    assert_redirects blog_floehopper_org('/xml/atom/feed.xml'), feed_url
    assert_redirects blog_floehopper_org('/xml/atom10/feed.xml'), feed_url
    assert_redirects blog_floehopper_org('/xml/rss/feed.xml'), feed_url
    assert_redirects blog_floehopper_org('/xml/rss20/feed.xml'), feed_url
  end
  
  def test_legacy_daily_archives
    assert_redirects blog_floehopper_org('/articles/2009/11/02/'), jamesmead_org('/archives')
    assert_redirects blog_floehopper_org('/articles/2009/11/02'), jamesmead_org('/archives')
    assert_redirects blog_floehopper_org('/articles/2009/11/02/page/1'), jamesmead_org('/archives')
    assert_redirects blog_floehopper_org('/articles/2009/11/2/'), jamesmead_org('/archives')
    assert_redirects blog_floehopper_org('/articles/2009/11/2'), jamesmead_org('/archives')
    assert_redirects blog_floehopper_org('/articles/2009/11/2/page/1'), jamesmead_org('/archives')
  end
  
  def test_legacy_monthly_archives
    assert_redirects blog_floehopper_org('/articles/2009/11/'), jamesmead_org('/archives')
    assert_redirects blog_floehopper_org('/articles/2009/11'), jamesmead_org('/archives')
    assert_redirects blog_floehopper_org('/articles/2009/11/page/1'), jamesmead_org('/archives')
    assert_redirects blog_floehopper_org('/articles/2009/3/'), jamesmead_org('/archives')
    assert_redirects blog_floehopper_org('/articles/2009/3'), jamesmead_org('/archives')
    assert_redirects blog_floehopper_org('/articles/2009/3/page/1'), jamesmead_org('/archives')
  end
  
  def test_legacy_yearly_archives
    assert_redirects blog_floehopper_org('/articles/2009/'), jamesmead_org('/archives')
    assert_redirects blog_floehopper_org('/articles/2009'), jamesmead_org('/archives')
    assert_redirects blog_floehopper_org('/articles/2009/page/1'), jamesmead_org('/archives')
  end
  
  def test_legacy_articles_index
    assert_redirects blog_floehopper_org('/articles/'), jamesmead_org('/blog/')
    assert_redirects blog_floehopper_org('/articles'), jamesmead_org('/blog/')
    assert_redirects blog_floehopper_org('/articles/page/1'), jamesmead_org('/blog/')
    assert_redirects blog_floehopper_org('/articles/page/2'), jamesmead_org('/blog/')
  end
  
  def test_legacy_articles_with_tags
    assert_redirects blog_floehopper_org('/articles/tag/mocha'), jamesmead_org('/tags')
    assert_redirects blog_floehopper_org('/articles/tag/mocha/page/1'), jamesmead_org('/tags')
    assert_redirects blog_floehopper_org('/articles/tag/mocha/page/2'), jamesmead_org('/tags')
  end

  def test_legacy_pages
    assert_redirects blog_floehopper_org('/pages/biography'), jamesmead_org('/pages/biography')
    assert_redirects blog_floehopper_org('/pages/gner-complaint'), jamesmead_org('/pages/gner-complaint')
  end
  
  def test_legacy_textile_reference
    assert_redirects blog_floehopper_org('/articles/markup_help/5'), 'http://redcloth.org/hobix.com/textile/'
  end
  
end