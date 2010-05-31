require 'test/unit'
require 'test_helper'

class FloehopperOrgRedirectsTest < Test::Unit::TestCase
  
  include TestHelper
  
  def test_legacy_feedburner_source
    assert_redirects blog_floehopper_org('/feedburner.xml'), jamesmead_org('/blog/index.xml')
  end
  
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
    assert_redirects blog_floehopper_org('/xml/atom/feed.xml'), feedburner_url
    assert_redirects blog_floehopper_org('/xml/atom10/feed.xml'), feedburner_url
    assert_redirects blog_floehopper_org('/xml/rss/feed.xml'), feedburner_url
    assert_redirects blog_floehopper_org('/xml/rss20/feed.xml'), feedburner_url
  end
  
  def test_archives
    assert_redirects blog_floehopper_org('/articles/2009/11/02/'), jamesmead_org('/archives')
    assert_redirects blog_floehopper_org('/articles/2009/11/02'), jamesmead_org('/archives')
    assert_redirects blog_floehopper_org('/articles/2009/11/'), jamesmead_org('/archives')
    assert_redirects blog_floehopper_org('/articles/2009/11'), jamesmead_org('/archives')
    assert_redirects blog_floehopper_org('/articles/2009/'), jamesmead_org('/archives')
    assert_redirects blog_floehopper_org('/articles/2009'), jamesmead_org('/archives')
  end
  
  def test_articles_index
    assert_redirects blog_floehopper_org('/articles/'), jamesmead_org('/blog/')
    assert_redirects blog_floehopper_org('/articles'), jamesmead_org('/blog/')
  end

end