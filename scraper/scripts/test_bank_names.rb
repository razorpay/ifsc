#!/usr/bin/env ruby

require './methods'

# Test script to verify bank name extraction from RBI CSV files
puts "Testing bank name extraction from RBI CSV files..."

# Inspect headers first
inspect_rbi_csv_headers(['RTGS-1', 'RTGS-2', 'RTGS-3', 'NEFT-0', 'NEFT-1'])

# Test with a sample of data
puts "\nTesting bank name extraction with sample data..."

# Load existing banks data
banks = parse_nach

# Test parsing a small sample
test_files = ['RTGS-1']
test_data = {}

test_files.each do |file|
  csv_file = "sheets/#{file}.csv"
  if File.exist?(csv_file)
    puts "Testing #{file}.csv..."
    
    # Read first 5 rows to test
    count = 0
    CSV.foreach(csv_file, encoding: 'utf-8', return_headers: false, headers: true, skip_blanks: true) do |row|
      break if count >= 5
      
      row = row.to_h
      next if row['IFSC'].nil? or ['IFSC_CODE', 'BANK OF BARODA', '', 'KPK HYDERABAD'].include?(row['IFSC'])
      
      bank_name = extract_bank_name_from_rbi_data(row)
      ifsc = row['IFSC'].to_s.upcase.gsub(/[^0-9A-Za-z]/, '').strip
      bankcode = ifsc[0..3]
      
      puts "  IFSC: #{ifsc}, Bank Code: #{bankcode}, Extracted Bank Name: #{bank_name || 'NOT FOUND'}"
      
      count += 1
    end
  else
    puts "File #{csv_file} not found"
  end
end

puts "\nTest completed!" 