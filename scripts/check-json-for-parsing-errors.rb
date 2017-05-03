# Check JSON for parsing errors
#
# Given a few file paths, this script will check if there have been any Excel
# parsing errors, because of problems in the source excel file.
# To run on a whole directory of JSON files:
# $ ruby scripts/check-json-for-parsing-errors.rb ../ifsc-api/data/*.json

require 'json'

puts "We have to check #{ARGV.length} files for errors"

ARGV.each do |file_path|
	file_obj = JSON.parse(File.read(file_path))
	file_obj.keys.each do |ifsc_code|
		ifsc_details_obj = file_obj[ifsc_code]
		ifsc_details_obj.keys.each do |obj_key|
			if ifsc_details_obj[obj_key] != nil and ifsc_details_obj[obj_key].to_s.match(/excel::error/i)
				puts "#{file_path}: #{ifsc_code}.#{obj_key} has a problem!"
			end
		end
	end
end
