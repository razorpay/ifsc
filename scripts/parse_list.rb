require 'nokogiri'
require 'uri'

doc = Nokogiri::HTML(open('list.html'))

doc.css('.tablebg a').each do |link|
  url = URI::parse link.attr('href')
  url.scheme = 'https'
  puts url.to_s
end