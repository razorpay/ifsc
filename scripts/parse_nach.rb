require 'nokogiri'
require 'json'
require 'uri'

doc = Nokogiri::HTML(open('nach.html'))

doc.css('a').each do |link|
  if link.text == 'List of Live bank'
  	url =  URI::parse link.attr('href')
  	puts "http://www.npci.org.in/#{url}"
  end
end
