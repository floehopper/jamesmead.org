require 'test/unit'
require 'test_helper'

class JamesmeadOrgRedirectsTest < Test::Unit::TestCase
  
  include TestHelper
  
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
    assert_success jamesmead_org('/talks/')
    assert_redirects jamesmead_org('/talks'), jamesmead_org('/talks/')
  end
  
  def test_projects_index
    assert_success jamesmead_org('/projects/')
    assert_redirects jamesmead_org('/projects'), jamesmead_org('/projects/')
  end
  
  def test_sitemap
    assert_success jamesmead_org('/sitemap.xml')
  end
  
  def test_pages
    assert_success jamesmead_org('/pages/biography')
    assert_success jamesmead_org('/pages/gner-complaint')
  end
  
  def test_feedburner_source
    assert_success jamesmead_org('/blog/index.xml')
  end
  
  def test_feedburner_cname
    assert_success feeds_jamesmead_org('/floehopper-blog')
  end
  
end