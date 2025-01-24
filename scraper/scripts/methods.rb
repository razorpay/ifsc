require 'csv'
require 'yaml'
require 'json'
require 'set'
require 'fileutils'
require 'nokogiri'
require 'open-uri'
require './methods_nach'
require './utils'
require './iso3166'

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

    # These are virtual branches, so we fix them to NPCI HQ for now
    data[row[:ifsc]] = {
      'BANK' => banknames[code],
      'IFSC' => row[:ifsc],
      'BRANCH' => "#{banknames[code]} IMPS",
      'CENTRE' => 'NA',
      'DISTRICT' => 'NA',
      'STATE' => 'MAHARASHTRA',
      'ADDRESS' => 'NA',
      'CONTACT' => nil,
      'IMPS' => true,
      'CITY' => 'MUMBAI',
      'UPI' => banks[code][:upi] ? true : false
    }
  end
  data
end

# TODO: Return state/UT ISO code and use that instead
def fix_state!(row)
  return unless row['STATE']
  possible_state = final_state = row['STATE'].strip.upcase
  map = {
    /ANDHRAPRADESH/ => 'ANDHRA PRADESH',
    /ANDAMAN/ => 'ANDAMAN AND NICOBAR ISLANDS',
    /BANGALORE/ => 'KARNATAKA',
    /BARDEZ/ => 'GOA',
    /BHUSAWAL/ => 'MAHARASHTRA',
    /BTM/ => 'KARNATAKA',
    /BULDHANA/ => 'MAHARASHTRA',
    /BUNDI/ => 'RAJASTHAN',
    /RAJAS/ => 'RAJASTHAN',
    /KARANATAKA/ => 'KARNATAKA',
    /CARMELARAM/ => 'KARNATAKA',
    # Chandigarh is not a state, but the branches there are ambigous b/w Haryana and Punjab
    # /CHANDIGARH/ => 'PUNJAB',
    /CHEMBUR/ => 'PUNJAB',
    /CHENNAI/ => 'TAMIL NADU',
    /CHHATIS/ => 'CHHATTISGARH',
    # Double H, Single T
    /CHHATISHGARH/ => 'CHHATTISGARH',
    # Single H, Double T
    /CHATTISGARH/ => 'CHHATTISGARH',
    /DADRA/ => 'DADRA AND NAGAR HAVELI AND DAMAN AND DIU',
    /DAHEGAM/ => 'GUJARAT',
    /DAHEJ/ => 'GUJARAT',
    /DELHI/ => 'DELHI',
    /DINDORI/ => 'MADHYA PRADESH',
    /MADHYAPRADESH/ => 'MADHYA PRADESH',
    # Do not use DAMAN as that clashes with ANDAMAN
    /DIU/ => 'DADRA AND NAGAR HAVELI AND DAMAN AND DIU',
    # Do an exact match for Daman instead
    'DAMAN' => 'DADRA AND NAGAR HAVELI AND DAMAN AND DIU',
    /GOA/ => 'GOA',
    /HIMANCHAL/ => 'HIMACHAL PRADESH',
    /HIMACHAL/ => 'HIMACHAL PRADESH',
    /HYDERABAD/ => 'ANDHRA PRADESH',
    /IDAR/ => 'ANDHRA PRADESH',
    /INDORE/ => 'MADHYA PRADESH',
    /JAMMU/ => 'JAMMU AND KASHMIR',
    /MADURAI/ => 'TAMIL NADU',
    /MALEGAON/ => 'MAHARASHTRA',
    /MUMBAI/ => 'MAHARASHTRA',
    /NASHIK/ => 'MAHARASHTRA',
    /NASIK/ => 'MAHARASHTRA',
    /PONDICHERRY/ => 'PUDUCHERRY',
    /SAMBRA/ => 'KARNATAKA',
    /SANTACRUZ/ => 'MAHARASHTRA',
    /TAMIL/ => 'TAMIL NADU',
    /UTTARA/ => 'UTTARAKHAND',
    /UTTARPRADESH/ => 'UTTAR PRADESH',
    /UTTRAKHAND/ => 'UTTARAKHAND',
    /WEST/ => 'WEST BENGAL',
    /CHURU/ => 'RAJASTHAN',
    /AHMEDABAD/ => 'GUJARAT',
    /GUJRAT/ =>  'GUJARAT',
    /HARKHAND/ => 'JHARKHAND',
    /JHAGRAKHAND/ => 'JHARKHAND',
    /ORISSA/ => 'ODISHA',
    /PUNE/ => 'MAHARASHTRA',
    /TELENGANA/ => 'TELANGANA',
    /PANJAB/ => 'PUNJAB',
    /MEGHALAY/ => 'MEGHALAYA',
    # Only if the branch is specifically marked as a UT branch
    # Otherwise, it could be Haryana or Punjab
    /CHANDIGARH UT/ => 'CHANDIGARH'
  }

  if possible_state.size == 2
    final_state = {
      "AP" => "ANDHRA PRADESH",
      "KA" => "KARNATAKA",
      "TN" => "TELANGANA",
      "MH" => "MAHARASHTRA",
      "CG" => "CHHATTISGARH",
      "ML" => "MEGHALAYA",
      "MP" => "MADHYA PRADESH"
    }[possible_state]
  else
    map.each_pair do |r, state|
      if r.is_a? Regexp and r.match? possible_state
        final_state = state
      elsif r == possible_state
        final_state = state
      end
    end
  end

  if final_state != row['STATE']
    log "#{row['IFSC']}: Setting State=(#{final_state}) instead of (#{row['STATE']})"
    row['STATE'] = final_state
  end
end

# Parses the contact details on the RTGS Sheet
# TODO: Add support for parsing NEFT contact data as well
def parse_contact(std_code, phone)
  scan_contact = phone.to_s.gsub(/[\s-]/, '').scan(/^(\d+)\D?/).last
  scan_std_code = std_code.to_s.gsub(/[\s-]/, '').scan(/^(\d+)\D?/).last

  contact = scan_contact.nil? || (scan_contact == 0) || (scan_contact == '0') || (scan_contact.is_a?(Array) && (scan_contact == ['0'])) ? nil : scan_contact.first
  std_code = scan_std_code.nil? || (scan_std_code == 0) || (scan_std_code == '0') || (scan_std_code.is_a?(Array) && (scan_std_code == ['0'])) ? nil : scan_std_code.first

  # If std code starts with 0, strip that out
  if std_code and std_code[0] == '0'
    std_code = std_code[1..-1]
  end

  # If we have an STD code, use it correctly
  # Formatting as per E.164 format
  # https://en.wikipedia.org/wiki/E.164
  # if possible
  if std_code == '91'
    return "+#{std_code}#{contact}"
  # Toll free number
  elsif contact and contact[0..3]=='1800'
    return "+91022#{contact}"
  # Mobile Number
  elsif contact and contact.size == 10
    return "+91#{contact}"
  # STD codes can't be 5 digits long, so this is likely a mobile number split into two
  elsif std_code and contact and std_code.size==5 and contact.size==5 and ["6","7","8","9"].include? std_code[0]
    return "+91#{std_code}#{contact}"
  # We likely have a good enough STD code
  elsif std_code
    return "+91#{std_code}#{contact}"
  # This is a local number but we don't have a STD code
  # So we return the local number as-is
  # TODO: Try to guess the STD code from PIN/Address/State perhaps?
  elsif contact
    return contact
  else
    return nil
  end
end

def parse_csv(files, banks, additional_attributes = {})
  data = {}

  files.each do |file|
    row_index = 0
    headings = []
    log "Parsing #{file}"
    headers = CSV.foreach("sheets/#{file}.csv", encoding: 'utf-8', return_headers: false, headers: true, skip_blanks: true) do |row|
      # We have found the last row in the sheet, remaining rows are empty
      if row[0].nil? and row[1].nil? and row[2].nil?
        break
      end

      row = row.to_h

      # BDBL0001094 RTGS sheet, so it gets overridden with data from NEFT sheet
      if row['STATE'] == '0'
        row['STATE'] = nil
      end

      # Some column is missing, and the STATE column has shifted by one.
      if row['STATE'].to_s.strip.match('\d')
        fix_row_alignment!(row)
      end

      # The address somehow contains a pipe-delimited value for other columns
      if row['ADDRESS'] != nil and row['ADDRESS'].count('|') > 2
        fix_pipe_delimited_address!(row)
      end

      micr_match = row['MICR'].to_s.strip.match('\d{9}')

      if micr_match
        row['MICR'] = micr_match[0]
      else
        row['MICR'] = nil
      end

      row['CONTACT'] = parse_contact(row['STD CODE'], row['PHONE'])

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
        # TODO: Put a diff in the logs?
        log "Second Entry found for #{row['IFSC']}, discarding", :warn
        next
      end

      row['ADDRESS'] = sanitize(row['ADDRESS'])
      row['BRANCH'] = sanitize(row['BRANCH'])
      row['STATE'].strip! if row['STATE']
      fix_state!(row)

      row.merge!(additional_attributes)
      # This isn't accurate sadly, because RBI has both the columns
      # all over the place. As an example, check LAVB0000882 vs LAVB0000883
      # which have the flipped values for CITY1 and CITY2
      row['CITY'] = sanitize(row['CITY2'])
      row['CENTRE'] = sanitize(row['CITY1'])
      row['DISTRICT'] = sanitize(row['CITY1'])

      # Delete rows we don't want in output
      # Merged into CONTACRT
      row.delete('STD CODE')
      row.delete('PHONE')
      row.delete('CITY1')
      row.delete('CITY2')
      data[row['IFSC']] = row
    end
  end
  data
end

def export_csv(data)
  CSV.open('data/IFSC.csv', 'wb') do |csv|
    keys = ['BANK','IFSC','BRANCH','CENTRE','DISTRICT','STATE','ADDRESS','CONTACT','IMPS','RTGS','CITY','ISO3166','NEFT','MICR','UPI','SWIFT']
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
    combined_data['SWIFT'] = nil
    # Set the bank name considering sublets
    combined_data['BANK'] = bank_name_from_code(combined_data['IFSC'])
    combined_data.delete('DATE')
    combined_data['ISO3166'] = ISO3166_MAP[combined_data['STATE']]

    h[ifsc] = combined_data
  end
  h
end

def apply_bank_patches(dataset)
  Dir.glob('../../src/patches/banks/*.yml').each do |patch|
    log "Applying Bank level patch: #{patch}", :debug
    data = YAML.safe_load(File.read(patch), permitted_classes: [Symbol])
    banks = data['banks']
    patch = data['patch']
    banks.each do |bankcode|
      if dataset.key? bankcode
        dataset[bankcode].merge!(patch)
      else
        log "#{bankcode} not found in the list of ACH banks while applying patch", :info
      end
    end
  end
  dataset
end

def apply_patches(dataset)
  Dir.glob('../../src/patches/ifsc/*.yml').each do |patch|
    log "Applying #{patch}", :debug
    data = YAML.safe_load(File.read(patch), permitted_classes: [Symbol])

    case data['action'].downcase
    when 'patch'
      codes = data['ifsc']
      patch = data['patch']
      codes.each do |code|
        log "Patching #{code}"
        dataset[code].merge!(patch) if dataset.has_key? code
      end
    when 'patch_multiple'
      codes = data['ifsc']
      codes.each_entry do |code, patch|
        log "Patching #{code}"
        dataset[code].merge!(patch) if dataset.has_key? code
      end
    when 'add_multiple'
      codes = data['ifsc']
      codes.each_entry do |code, data|
        log "Adding #{code}"
        dataset[code] = data
        dataset[code]['IFSC'] = code
      end
    when 'patch_bank'
      patch = data['patch']
      all_ifsc = dataset.keys
      banks = data['banks']
      banks.each do |bankcode|
        log "Patching #{bankcode}"
        codes = all_ifsc.select {|code| code[0..3] == bankcode}
        codes.each do |code|
          dataset[code].merge!(patch)
        end
      end

    when 'delete'
      codes = data['ifsc']
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

# Downloads the SWIFT data from
# https://sbi.co.in/web/nri/quick-links/swift-codes
def validate_sbi_swift
  doc = Nokogiri::HTML(URI.open("https://web.archive.org/https://sbi.co.in/hi/web/nri/quick-links/swift-codes"))
  table = doc.css('tbody')[0]
  website_bics = Set.new

  for row in table.css('tr')
    website_bics.add row.css('td')[2].text.gsub(/[[:space:]]/, '')
  end

  # Validate that all of these are covered in our swift patch
  patch_bics = YAML.safe_load(File.read('../../src/patches/ifsc/sbi-swift.yml'))['ifsc']
    .values
    .map {|x| x['SWIFT']}
    .to_set

  missing = (website_bics - patch_bics)
  if missing.size != 0
    log "[SBI] Missing SWIFT/BICs for SBI. Please match https://sbi.co.in/web/nri/quick-links/swift-codes to src/patches/ifsc/sbi-swift.yml", :critical
    log "[SBI] You can use https://www.sbi.co.in/web/home/locator/branch to find IFSC from BRANCH code or guess it as SBIN00+BRANCH_CODE", :info
    log "[SBI] Count of Missing BICS: #{missing.size}", :debug
    log "[SBI] Missing BICS follow", :debug
    log missing.to_a.join(", "), :debug
    exit 1
  end
end
