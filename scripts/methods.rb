require 'spreadsheet'
require 'rubyXL'
require 'csv'
require 'yaml'
require 'json'
require 'set'
require 'fileutils'
require 'pp'

HEADINGS_INSERT = [
  "BANK",
  "IFSC",
  "BRANCH",
  "ADDRESS",
  "CONTACT",
  "CITY",
  "DISTRICT",
  "STATE"
]

# These are invalid sublets
# given out by RBI
# because they result in 1 bank
# having 2 different codes
IGNORED_SUBLETS = [
  # Typo? in this one (AKJB|AJKB)
  'AKJB0000001',
  # DLSC and DSCB are the same
  'DLSC0000001',
  # FIRN and FIRX are the same
  'FIRN0000001',
  # KANG and KCOB are the same
  'KANG0000001',
  # SJSB and SJSX are the same
  'SJSB0000001',
  # SKSB and SHKX are the same
  'SKSB0000001'
]

def parse_sublet_sheet()
  sublet_mappings = Hash.new
  file = 'sheets/SUBLET.xlsx'
  sheet = RubyXL::Parser.parse(file).worksheets[0]
  row_index = 0
  sheet.each do |row|
    row_index += 1
    next if row_index == 1
    row = (0..4).map { |e| row[e] ? row[e].value : nil}
    bank_code = row[1].strip
    ifsc_code = row[4].strip
    if ifsc_code.size == 11 and ifsc_code[0..3] != bank_code and not IGNORED_SUBLETS.include?(ifsc_code)
      sublet_mappings[ifsc_code] = bank_code
    end
  end
  return Hash[sublet_mappings.sort]
end

def parse_sheets
  data = []

  file_ifsc_mappings = Hash.new

  Dir.glob('sheets/IFCB*') do |file|
    log "Parsing #{file}"
    basename = File.basename file
    extension = File.extname file
    case extension
    when '.xls'
      sheet = Spreadsheet.open(file).worksheet 0
      headings = sheet.row(0)[0,9]

      sheet.each 1 do |row|
        row = row[0,9]
        next if row.compact.empty?

        data_mapped = map_data(row, headings)
        data_to_insert = [HEADINGS_INSERT, data_mapped]

        begin
          x = data_to_insert.transpose.to_h
          x.each do |key, value|
            if value.is_a? Spreadsheet::Excel::Error
              puts "ERROR: #{file} #{x['IFSC']}"
              x[key] = nil
            end
          end
          data.push x
          file_ifsc_mappings[basename] = x['IFSC'][0..3]
        rescue Exception => e
          puts "Faced an Exception"
          puts data_to_insert.to_json
          puts e
          exit
        end
      end
    when '.xlsx'
      sheet = RubyXL::Parser.parse(file).worksheets[0]
      headings = sheet.sheet_data[0]
      headings = (0..8).map {|e| headings[e].value}
      row_index = 0
      sheet.each do |row|
        row_index += 1
        row = (0..8).map { |e| row[e] ? row[e].value : nil}
        next if row_index == 1
        next if row.compact.empty?
        data_to_insert = [HEADINGS_INSERT, map_data(row, headings)]
        begin
          x = data_to_insert.transpose.to_h
          data.push x
          file_ifsc_mappings[basename] = x['IFSC'][0..3]
        rescue Exception => e
          puts "Faced an Exception"
          puts data_to_insert.to_json
          puts e
          exit
        end
      end
    end
  end
  [data, file_ifsc_mappings]
end

def map_data(row, headings)
  data = []

  # Renames
  mappings = {
    'BANKNAME' => 'BANK',
    'CENTRE'   => 'CITY',
    'CONTACT1'  => 'CONTACT',
    'IFSC CODE' => 'IFSC'
  }
  # Find the heading in HEADINGS_INSERT
  headings.each_with_index do |header, heading_index|
    header = header.strip
    index = HEADINGS_INSERT.find_index(header).nil? ?
      HEADINGS_INSERT.find_index(mappings[header]) : HEADINGS_INSERT.find_index(header)

    case header
    when 'BANKNAME', 'CENTRE'
      data[index] = row[heading_index]
    when 'CONTACT', 'CONTACT1'
      scan = row[heading_index].to_s.gsub(/[\s-]/, '').scan(/^(\d+)\D?/).last
      data[index] = (scan.nil? or scan==0 or scan=="0" or (scan.is_a? Array and scan==["0"])) ? nil : scan.first
    when 'IFSC CODE'
      data[index] = row[heading_index]
    else
      data[index] = row[heading_index] if index
    end
  end
  data
end

def export_csv(data)
  CSV.open("data/IFSC.csv", "wb") do |csv|
    csv << data[0].keys
    data.each do |row|
      csv << row.values
    end
  end
end

def export_yml(data)
  File.open("data/IFSC.yml", 'w') { |f| YAML.dump(data, f) }
end

def export_marshal(data)
  File.open("data/IFSC.marshal", 'w') { |f| Marshal.dump(data, f) }
end

def export_json(hash)
  File.open("data/IFSC.json", 'w') { |f| f.write JSON.pretty_generate(hash) }
end

def export_sublet_json(hash)
  File.open("../src/sublet.json", 'w') { |f| f.write JSON.pretty_generate(hash) }
  FileUtils.cp('../src/sublet.json', 'data/sublet.json')
end

def export_yml_list(list)
  File.open("data/IFSC-list.yml", 'w') { |f| YAML.dump(list, f) }
end

def export_json_list(list)
  File.open("data/IFSC-list.json", 'w') { |f| JSON.dump(list, f) }
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
    hash = Hash.new
    branches = find_bank_branches(bank, list)
    branches.sort.each do |code|
      hash[code] = ifsc_hash[code]
    end

    File.open("data/by-bank/#{bank}.json", 'w') { |f| f.write JSON.pretty_generate(hash) }
  end
end

def make_ranges(list)
  ranges = []
  range_index = index = 0
  while index < list.size
    item = list[index]
    ranges[range_index] = [item] if ranges[range_index].nil?

    if item.is_a? String
      ranges[range_index] = item
      index+=1
      range_index+=1
      next
    end

    unless list[index + 1].nil?
      if list[index].is_a? Integer and list[index] + 1 != list[index + 1]
        if ranges[range_index] != [item]
          ranges[range_index] << item
        end
        range_index+=1
      end
    else
      if ranges[range_index] != [item]
        ranges[range_index] << item
      end
    end
    index+=1
  end
  #return ranges
  ranges.map { |x| x.size==1 ? x[0] : x }
end

def export_to_code_json(list, ifsc_hash)
  banks = find_bank_codes list
  banks_hash = Hash.new

  banks.each do |bank|
    banks_hash[bank] = find_bank_branches(bank, list).map do |code|
      # this is to drop lots of zeroes
      branch_code = code[-6,6]
      if branch_code.match(/^(\d)+$/)
        branch_code.to_i
      else
        branch_code
      end
    end
    banks_hash[bank] = make_ranges banks_hash[bank]
  end

  File.open('../src/IFSC.json', 'w') do |file|
    file.puts banks_hash.to_json
  end
end

def log(msg)
  puts msg
end
