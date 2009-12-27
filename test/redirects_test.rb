require 'test/unit'
require 'net/http'

class RedirectsTest < Test::Unit::TestCase
  
  def test_home_page
    assert_success jamesmead_org('/')
  end
  
  def test_blog_index
    assert_success jamesmead_org('/blog/')
    assert_redirects jamesmead_org('/blog'), jamesmead_org('/blog/')
  end
  
  def test_blog_article
    assert_success jamesmead_org(new_article_path)
  end
  
  def test_presentations_index
    assert_success jamesmead_org('/presentations/')
    assert_redirects jamesmead_org('/presentations'), jamesmead_org('/presentations/')
  end
  
  def test_sitemap
    assert_success jamesmead_org('/sitemap.xml')
  end
  
  def test_feedburner_source
    assert_success jamesmead_org('/feedburner.xml')
  end
  
  def test_legacy_feedburner_source
    assert_redirects blog_floehopper_org('/feedburner.xml'), jamesmead_org('/feedburner.xml')
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
    assert_redirects blog_floehopper_org('/xml/atom/feed.xml'), feeds_floehopper_org('/floehopper-blog')
    assert_redirects blog_floehopper_org('/xml/atom10/feed.xml'), feeds_floehopper_org('/floehopper-blog')
    assert_redirects blog_floehopper_org('/xml/rss/feed.xml'), feeds_floehopper_org('/floehopper-blog')
    assert_redirects blog_floehopper_org('/xml/rss20/feed.xml'), feeds_floehopper_org('/floehopper-blog')
  end
  
  private
  
  def assert_success(url)
    response = get_response(url)
    assert response.is_a?(Net::HTTPSuccess), "Request to #{url} failed with #{response}"
  end
  
  def assert_redirects(origin_url, target_url)
    url = origin_url
    while (response = get_response(url)) && response.is_a?(Net::HTTPRedirection)
      url = response['Location']
    end
    assert response.is_a?(Net::HTTPSuccess), "Request to #{url} failed with #{response}"
    assert_equal(target_url, url)
  end
  
  def get_response(url)
    Net::HTTP.get_response(URI.parse(url))
  end
  
  def jamesmead_org(path)
    "http://jamesmead.local#{path}"
  end
  
  def floehopper_org(path)
    "http://floehopper.local#{path}"
  end
  
  def blog_floehopper_org(path)
    "http://blog.floehopper.local#{path}"
  end
  
  def www_floehopper_org(path)
    "http://www.floehopper.local#{path}"
  end
  
  # keep .org TLD as this sub-domain points directly at feedburner domain
  def feeds_floehopper_org(path)
    "http://feeds.floehopper.org#{path}"
  end
  
  def old_article_path
    "/articles/2009/11/02/activerecord-model-class-name-clash"
  end
  
  def new_article_path
    "/blog/2009-11-02-activerecord-model-class-name-clash"
  end
  
end
