require 'spreadsheet'
require 'rubyXL'
require 'csv'
require 'yaml'
require 'json'
require 'set'
require 'fileutils'

HEADINGS_INSERT = %w[
  BANK
  IFSC
  BRANCH
  ADDRESS
  CONTACT
  CITY
  DISTRICT
  STATE
].freeze

def parse_sublet_json
  JSON.parse File.read('nach.json')
end

def parse_neft
  data = {}
  codes = Set.new
  sheets = 0..3
  sheets.each do |sheet_id|
    row_index = 0
    headings = []
    log "Parsing #IFSC-#{sheet_id}.csv"
    headers = CSV.foreach("sheets/IFSC-#{sheet_id}.csv", encoding: 'utf-8', return_headers: false, headers: true, skip_blanks: true) do |row|
      row = row.to_h
      scan_contact = row['CONTACT'].to_s.gsub(/[\s-]/, '').scan(/^(\d+)\D?/).last
      row['CONTACT'] = scan_contact.nil? || (scan_contact == 0) || (scan_contact == '0') || (scan_contact.is_a?(Array) && (scan_contact == ['0'])) ? nil : scan_contact.first
      row['ADDRESS'] = row['ADDRESS'].to_s.strip
      row['IFSC'] = row['IFSC'].upcase.gsub(/[^0-9A-Za-z]/, '')
      codes.add row['IFSC']
      row['NEFT'] = true

      if data.key? row['IFSC']
        "Second Entry found for #{row['IFSC']}, discarding"
        next
      end
      data[row['IFSC']] = row
    end
  end
  data
end

def parse_rtgs
  data = {}
  sheets = 1..2
  sheets.each do |sheet_id|
    row_index = 0
    headings = []
    log "Parsing #RTGS-#{sheet_id}.csv"
    headers = CSV.foreach("sheets/RTGS-#{sheet_id}.csv", encoding: 'utf-8', return_headers: false, headers: true, skip_blanks: true) do |row|
      row = row.to_h
      micr_match = row['MICR_CODE'].to_s.strip.match('\d{9}')
      row['MICR'] = micr_match[0] if micr_match
      row['BANK'] = row.delete('BANK NAME')
      row.delete('Date')
      row.delete('MICR_CODE')
      scan_contact = row['CONTACT'].to_s.gsub(/[\s-]/, '').scan(/^(\d+)\D?/).last
      row['CONTACT'] = scan_contact.nil? || (scan_contact == 0) || (scan_contact == '0') || (scan_contact.is_a?(Array) && (scan_contact == ['0'])) ? nil : scan_contact.first

      # There is a second header in the middle of the sheet.
      # :facepalm: RBI
      next if row['IFSC'] == 'IFSC_CODE'

      original_ifsc = row['IFSC']
      row['IFSC'] = row['IFSC'].upcase.gsub(/[^0-9A-Za-z]/, '').strip

      if row['IFSC'].length != 11
        ifsc_11 = row['IFSC'][0..10]
        puts "IFSC code longer than 11 characters: #{original_ifsc}, using #{ifsc_11}"
        row['IFSC'] = ifsc_11
      end

      if data.has_key? row['IFSC']
        puts "Second Entry found for #{row['IFSC']}, discarding"
        next
      end
      row['ADDRESS'] = row['ADDRESS'].to_s.strip
      row['RTGS'] = true
      data[row['IFSC']] = row
    end
  end
  data
end

def export_csv(data)
  CSV.open('data/IFSC.csv', 'wb') do |csv|
    keys = data[0].keys
    csv << keys
    data.each do |row|
      sorted_data = []
      for key in keys
        sorted_data << row[key]
      end
      csv << sorted_data
    end
  end
end

def export_sublet_json(_hash)
  FileUtils.cp('../src/sublet.json', 'data/sublet.json')
end

def find_bank_codes(list)
  banks = Set.new

  list.each do |code|
    banks.add code[0...4] if code
  end
  banks
end

def find_bank_branches(bank, list)
  list.select do |code|
    if code
      bank == code[0...4]
    else
      false
    end
  end
end

def export_json_by_banks(list, ifsc_hash)
  banks = find_bank_codes list
  banks.each do |bank|
    hash = {}
    branches = find_bank_branches(bank, list)
    branches.sort.each do |code|
      hash[code] = ifsc_hash[code]
    end

    File.open("data/by-bank/#{bank}.json", 'w') { |f| f.write JSON.pretty_generate(hash) }
  end
end

def parse_ifsc_rtgs(data_neft, data_rtgs)
  data = []
  h = {}

  set_neft = Set.new data_neft.keys
  set_rtgs = Set.new data_rtgs.keys

  combined_set = set_neft + set_rtgs

  combined_set.each do |ifsc|
    data_from_neft = data_neft.fetch ifsc, {}
    data_from_rtgs = data_rtgs.fetch ifsc, {}

    # Give preference to NEFT dataset
    combined_data = data_from_rtgs.merge data_from_neft

    combined_data['NEFT'] ||= false
    combined_data['RTGS'] ||= false
    combined_data['MICR'] ||= nil
    h[ifsc] = combined_data

    data << combined_data

  end
  [data, h]
end

def export_json_list(list)
  File.open("data/IFSC-list.json", 'w') { |f| JSON.dump(list, f) }
end


def export_to_code_json(list, _ifsc_hash)
  banks = find_bank_codes list
  banks_hash = {}

  banks.each do |bank|
    banks_hash[bank] = find_bank_branches(bank, list).map do |code|
      # this is to drop lots of zeroes
      branch_code = code.strip[-6, 6]
      if branch_code =~ /^(\d)+$/
        branch_code.to_i
      else
        branch_code
      end
    end
  end

  File.open('../../src/IFSC.json', 'w') do |file|
    file.puts banks_hash.to_json
  end
end

def log(msg)
  puts msg
end
