require 'spreadsheet'
require 'rubyXL'
require 'csv'
require 'yaml'
require 'json'
require 'set'
require 'fileutils'
require './methods_nach'

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

def parse_imps(banks)
  data = {}
  banknames = JSON.parse File.read('../../src/banknames.json')
  banks.each do |code, row|
    next unless row[:ifsc] && row[:ifsc].strip.to_s.length == 11

    data[row[:ifsc]] = {
      'BANK' => banknames[code],
      'IFSC' => row[:ifsc],
      'BRANCH' => "#{banknames[code]} IMPS",
      'CENTRE' => 'NA',
      'DISTRICT' => 'NA',
      'STATE' => 'NA',
      'ADDRESS' => 'NA',
      'CONTACT' => nil,
      'IMPS' => true,
      'CITY' => 'NA',
      'UPI' => banks[code][:upi] ? true : false
    }
  end
  data
end

def parse_neft(banks)
  data = {}
  codes = Set.new
  sheets = 0..1
  sheets.each do |sheet_id|
    row_index = 0
    headings = []
    log "Parsing #NEFT-#{sheet_id}.csv"
    headers = CSV.foreach("sheets/NEFT-#{sheet_id}.csv", encoding: 'utf-8', return_headers: false, headers: true, skip_blanks: true) do |row|
      row = row.to_h
      scan_contact = row['CONTACT'].to_s.gsub(/[\s-]/, '').scan(/^(\d+)\D?/).last
      row['CONTACT'] = scan_contact.nil? || (scan_contact == 0) || (scan_contact == '0') || (scan_contact.is_a?(Array) && (scan_contact == ['0'])) ? nil : scan_contact.first

      row['MICR'] = row['MICR CODE']
      row.delete 'MICR CODE'
      row.delete 'STD CODE'
      row['ADDRESS'] = row['ADDRESS'].to_s.strip
      row['IFSC'] = row['IFSC'].upcase.gsub(/[^0-9A-Za-z]/, '')
      codes.add row['IFSC']
      row['NEFT'] = true

      # This hopefully is overwritten by RTGS dataset
      row['CENTRE'] = 'NA'
      bankcode = row['IFSC'][0..3]

      if banks[bankcode] and banks[bankcode].key? :upi and banks[bankcode][:upi]
        row['UPI'] = true
      else
        row['UPI'] = false
      end

      if data.key? row['IFSC']
        "Second Entry found for #{row['IFSC']}, discarding"
        next
      end
      data[row['IFSC']] = row
    end
  end
  data
end

def parse_rtgs(banks)
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
      next if row['IFSC'].nil? or ['IFSC_CODE', 'BANK OF BARODA', '', 'KPK HYDERABAD'].include?(row['IFSC'])

      original_ifsc = row['IFSC']
      row['IFSC'] = row['IFSC'].upcase.gsub(/[^0-9A-Za-z]/, '').strip

      bankcode = row['IFSC'][0..3]

      if banks[bankcode] and banks[bankcode].key? :upi and banks[bankcode][:upi]
        row['UPI'] = true
      else
        row['UPI'] = false
      end

      if row['IFSC'].length != 11
        ifsc_11 = row['IFSC'][0..10]
        log "IFSC code longer than 11 characters: #{original_ifsc}, using #{ifsc_11}", :warn
        row['IFSC'] = ifsc_11
      end

      if data.key? row['IFSC']
        log "Second Entry found for #{row['IFSC']}, discarding", :warn
        next
      end
      row['ADDRESS'] = row['ADDRESS'].to_s.strip
      row['RTGS'] = true
      # This is fallback option and we fake it
      # because the RTGS sheet does not have the CITY
      row['CITY'] = row['CENTRE']
      data[row['IFSC']] = row
    end
  end
  data
end

def export_csv(data)
  CSV.open('data/IFSC.csv', 'wb') do |csv|
    keys = ['BANK','IFSC','BRANCH','CENTRE','DISTRICT','STATE','ADDRESS','CONTACT','IMPS','RTGS','CITY','NEFT','MICR','UPI']
    csv << keys
    data.each do |code, ifsc_data|
      sorted_data = []
      keys.each do |key|
        sorted_data << ifsc_data.fetch(key, "NA")
      end
      csv << sorted_data
    end
  end
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

def merge_dataset(neft, rtgs, imps)
  h = {}
  combined_set = Set.new(neft.keys) + Set.new(rtgs.keys) + Set.new(imps.keys)

  combined_set.each do |ifsc|

    data_from_neft = neft.fetch ifsc, {}
    data_from_rtgs = rtgs.fetch ifsc, {}
    data_from_imps = imps.fetch ifsc, {}

    # Preference Order is:
    # NEFT > RTGS > IMPS
    combined_data = data_from_imps.merge(
      data_from_rtgs.merge(data_from_neft) do |key, oldval, newval|
        if oldval and oldval != 'NA'
          oldval
        else
          newval
        end
      end
    ) do |key, oldval, newval|
        if oldval and oldval != 'NA'
          oldval
        else
          newval
        end
      end
    combined_data['NEFT'] ||= false
    combined_data['RTGS'] ||= false
    # IMPS is true everywhere, till we have clarity on this from NPCI
    combined_data['IMPS'] ||= true
    combined_data['UPI']  ||= false
    combined_data['MICR'] ||= nil
    h[ifsc] = combined_data
  end
  h
end

def apply_bank_patches(dataset)
  Dir.glob('../../src/patches/banks/*.yml').each do |patch|
    data = YAML.safe_load(File.read(patch), [Symbol])
    banks = data['banks']
    patch = data['patch']
    banks.each do |bankcode|
      if dataset.key? bankcode
        dataset[bankcode].merge!(patch)
      else
        log "#{bankcode} not found", :critical
      end
    end
  end
  dataset
end

def apply_patches(dataset)
  Dir.glob('../../src/patches/ifsc/*.yml').each do |patch|
    data = YAML.safe_load(File.read(patch))

    codes = data['ifsc']

    case data['action'].downcase
    when 'patch'
      patch = data['patch']
      codes.each do |code|
        dataset[code].merge!(patch) if dataset.has_key? code
      end
    when 'delete'
      codes.each do |code|
        dataset.delete code
        log "Removed #{code} from the list", :info
      end
    end
  end
  dataset
end

def export_json_list(list)
  File.open('data/IFSC-list.json', 'w') { |f| JSON.dump(list, f) }
end

def export_to_code_json(list)
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

  File.open('data/IFSC.json', 'w') do |file|
    file.puts banks_hash.to_json
  end
end

def log(msg, status = :info)
  case status
  when :info
    msg = "[INFO] #{msg}"
  when :warn
    msg = "[WARN] #{msg}"
  when :critical
    msg = "[CRIT] #{msg}"
  when :debug
    msg = "[DEBG] #{msg}"
  end
  puts msg
end
