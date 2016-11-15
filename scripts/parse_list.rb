require 'nokogiri'
require 'json'
require 'uri'

doc = Nokogiri::HTML(open('list.html'))

h = Hash.new

doc.css('.tablebg a').each do |link|
  url =  URI::parse link.attr('href')
  url.scheme = 'https'
  text = link.text
  puts url.to_s

  h[File.basename(url.path)] = text
end

File.open("data/names.json", "w") do |file|
	file.write JSON.pretty_generate h
end