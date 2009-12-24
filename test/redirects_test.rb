require 'net/http'

expectations = {
  # original typo-style URL
  'http://floehopper.local/articles/2009/11/02/activerecord-model-class-name-clash' => {
    :url => 'http://floehopper.local/blog/2009-11-02-activerecord-model-class-name-clash',
    :code => '301'
  },
  # no URLs like this should have escaped into the wild, but just in case...
  'http://floehopper.local/blog/2009-11-02-activerecord-model-class-name-clash.html' => {
    :url => 'http://floehopper.local/blog/2009-11-02-activerecord-model-class-name-clash',
    :code => '301'
  }
  'http://floehopper.local/blog/2009-11-02-activerecord-model-class-name-clash' => {
    :code => '200'
  },
}

expectations.each do |request_url, expected_attributes|
  puts "Requesting: #{request_url}"
  
  url = URI.parse(request_url)
  request = Net::HTTP::Get.new(url.path)
  response = Net::HTTP.start(url.host, url.port) do |http|
    http.request(request)
  end
  
  if redirection_url = expected_attributes[:url]
    raise "Expected '#{redirection_url}' in the Location header but got '#{response['Location']}'." unless redirection_url == response['Location']
  end
  if status_code = expected_attributes[:code]
    raise "Expected status code of (#{status_code}) but got (#{response.code})." unless status_code == response.code
  end
end