require 'spreadsheet'
require 'csv'
require 'yaml'
require 'json'
require 'set'
require 'bloom-filter'
require 'erb'
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

def parse_sheets
  data = []

  file_ifsc_mappings = Hash.new

  Dir.glob('sheets/*') do |file|
    log "Parsing #{file}"
    basename = File.basename file
    sheet = Spreadsheet.open(file).worksheet 0
    headings = sheet.row(0)[0,9]

    sheet.each 1 do |row|
      row = row[0,9]
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
  [data, file_ifsc_mappings]
end

def map_data(row, headings)
  data = []

  # Find the heading in HEADINGS_INSERT
  headings.each_with_index do |header, heading_index|
    header = header.strip
    index = HEADINGS_INSERT.find_index header
    case header
    when 'CONTACT'
      scan = row[heading_index].to_s.scan(/^(\d+)\D?/).last
      data[index] = (scan.nil? or scan==0 or scan=="0" or (scan.is_a? Array and scan==["0"])) ? nil : scan.first
    when 'IFSC CODE'
      index = HEADINGS_INSERT.find_index 'IFSC'
      data[index] = row[heading_index]
      
    else
      data[index] = row[heading_index] if index
    end
  end
  data
end

def export_bank_names(file_ifsc_mappings)
  # This is all the files that we have downloaded with names
  contents = File.read('data/names.json')
  data_hash = JSON.parse(contents)

  res = Hash.new

  data_hash.each do |filename, name|
    if file_ifsc_mappings.key? filename
      res[file_ifsc_mappings[filename]] = name
    else
      puts "No IFSC code found for #{filename}"
    end
  end

  File.open("../src/banknames.json", "w") do |file|
    file.write JSON.pretty_generate res
  end

  File.delete "data/names.json"
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

def export_lookup_table_marshal(list)  
  File.open("data/IFSC-list.marshal", 'w') { |f| Marshal.dump(list, f) }
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

def export_bloom_filter(list)
  # 128_000 is the approx size of our current list
  filter = BloomFilter.new size: 150_000, error_rate: 0.001
  list.each do |code|
    filter.insert code
  end

  filter.dump "data/IFSC-list.bloom"
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