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

def parse_sublet_json()
  return JSON.parse File.read('nach.json')
end

def parse_sheets
  data = []

  Dir.glob('sheets/IFCB*') do |file|
    log "Parsing #{file}"
    basename = File.basename file
    extension = File.extname file
    case extension
    when '.xls'
      sheet = Spreadsheet.open(file).worksheet 0
      headings = sheet.row(0)[0,9]

      row_count = 0
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
        rescue Exception => e
          puts "Faced an Exception"
          puts data_to_insert.to_json
          puts e
          exit
        end
        row_count += 1
      end
      puts "[+] #{row_count} rows processed"
    when '.xlsx'
      sheet = RubyXL::Parser.parse(file).worksheets[0]
      headings = sheet.sheet_data[0]
      max = headings.size
      headings = (0...max).map {|e| headings[e].value}
      row_index = 0
      sheet.each do |row|
        row_index += 1
        row = (0...max).map { |e| row[e] ? row[e].value : nil}
        next if row_index == 1
        next if row.compact.empty?
        data_to_insert = [HEADINGS_INSERT, map_data(row, headings)]
        begin
          x = data_to_insert.transpose.to_h
          data.push x
        rescue Exception => e
          puts "Faced an Exception"
          puts data_to_insert.to_json
          puts e
          exit
        end
      end
      puts "[+] #{row_index} rows processed"
    end
  end
  data
end

def parse_rtgs
  data = []


  # The first sheet has bank codes
  # the second and third are the ones we need
  sheets = [1,2]
  sheets.each do |sheet_id|
    row_index = 0
    headings = []
    log "Parsing #RTGS-#{sheet_id}.csv"
    headers = CSV.foreach("sheets/RTGS-#{sheet_id}.csv", encoding:'utf-8', return_headers: true) do |row|

      headings = row if row_index == 0

      row_index+=1

      next if row_index == 1
      next if row.compact.empty?

      data_to_insert = [HEADINGS_INSERT, map_data(row, headings)]

      begin
        x = data_to_insert.transpose.to_h
        # IFSC values are in smaller case
        x["IFSC"] = x["IFSC"].upcase.gsub(/[^0-9A-Za-z]/, '')
        # RTGS Flag
        x["RTGS"] = true
        data.push x
      rescue Exception => e
        puts "Faced an Exception"
        puts data_to_insert.to_json
        puts e
        exit
      end
      puts row_index if row_index%1000 ==0
    end
  end
  data
end

def map_data(row, headings)
  data = []

  # Renames
  mappings = {
    'BANKNAME' => 'BANK',
    'CENTRE'   => 'CITY',
    'CONTACT1'  => 'CONTACT',
    'IFSC CODE' => 'IFSC',
    'BRANCH NAME' => 'BRANCH',
    'BANK NAME'   => 'BANK',
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

def export_sublet_json(hash)
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


def parse_ifsc_rtgs(data_ifsc, data_rtgs)
  ifsc = Hash.new
  rtgs = Hash.new
  hash = Hash.new

  data_ifsc.each { |row| ifsc[row['IFSC']] = row }
  ifsc_keys = ifsc.keys

  data_rtgs.each { |row| rtgs[row['IFSC']] = row }
  rtgs_keys = rtgs.keys

  data = []

  rtgs.each do |key, value|
    if not ifsc_keys.include? key
      # already RTGS = true will be there in value
      data.push(value)
    end
  end

  ifsc.each do |key, value|
    ifsc = value
    if rtgs_keys.include? key
      value['RTGS'] = true
    end
    value['IFSC'] = value['IFSC'].gsub(/[^0-9A-Za-z]/, '')
    data.push(value)
  end

  data.each { |row| hash[row['IFSC']] = row }

  [data, hash]
end

def export_to_code_json(list, ifsc_hash)
  banks = find_bank_codes list
  banks_hash = Hash.new

  banks.each do |bank|
    banks_hash[bank] = find_bank_branches(bank, list).map do |code|
      # this is to drop lots of zeroes
      branch_code = code.strip[-6,6]
      if branch_code.match(/^(\d)+$/)
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
