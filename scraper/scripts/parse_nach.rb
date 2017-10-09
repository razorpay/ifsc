require 'nokogiri'
require 'json'
require 'uri'

doc = Nokogiri::HTML(open('nach.html'))

header_cleared = false

banks = Hash.new

doc.css('table')[0].css('tr').each do |row|
    if header_cleared
        data = row.css('td')
        ifsc = data[4].text.strip
        bank_code = data[1].text.strip
        banks[ifsc] = bank_code if ifsc != 'NA'
    end
    header_cleared = true
end

File.open("../../src/sublet.json", "w") do |f|
    f.write JSON.pretty_generate(Hash[banks.sort])
end
