require 'spreadsheet'
require 'csv'
require 'yaml'
require 'json'
require 'set'
require 'bloom-filter'

def parse_sheets
  data = []
  headings = [
    "BANK",
    "IFSC",
    "MICR",
    "BRANCH",
    "ADDRESS",
    "CONTACT",
    "CITY",
    "DISTRICT",
    "STATE"
  ]

  Dir.glob('sheets/*') do |file|
    log "Parsing #{file}"
    sheet = Spreadsheet.open(file).worksheet 0
    sheet.each 1 do |row|
      row = row[0,9]
      data.push [headings, row].transpose.to_h
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

def log(msg)
  puts msg
end