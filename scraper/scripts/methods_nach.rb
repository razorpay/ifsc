require 'nokogiri'
require 'json'
require 'uri'

def write_sublet_json(sublets)
  File.open('data/sublet.json', 'w') do |f|
    f.write JSON.pretty_generate(Hash[sublets.sort])
    log 'Saved data/sublet.json'
  end
end

def write_banks_json(banks)
  File.open('data/banks.json', 'w') do |f|
    f.write JSON.pretty_generate(Hash[banks.sort])
    log 'Saved data/banks.json'
  end
end

def match_length_or_nil(data, expected_length)
  data = data.text.strip
  data.length === expected_length ? data : nil
end

def get_value(data)
  (data != nil && data.text.strip == 'Yes') ? true : false
end

def bank_data(bank_code, data, _ifsc)
  {
    code: bank_code,
    type: data[3].text.strip,
    # IFSC codes are 11 characters long
    ifsc: match_length_or_nil(data[4], 11),
    # MICR codes are 9 digits long
    micr: match_length_or_nil(data[5], 9),
    # IINs are 6 digits long
    iin: match_length_or_nil(data[6], 6),
    apbs: data[7].text.strip == 'Yes',
    ach_credit: data[8].text.strip == 'Yes',
    ach_debit: data[9].text.strip == 'Yes',
    nach_debit: get_value(data[10])
  }
end

def parse_upi
  doc = Nokogiri::HTML(open('upi.html'))
  header_cleared = false
  count = doc.css('table>tbody')[0].css('tr').size

  upi_patch_filename = '../../src/patches/banks/upi-enabled-banks.yml'
  # Count the number of banks we have in our UPI patch file:
  data = YAML.safe_load(File.read(upi_patch_filename), [Symbol])
  if data['banks'].size != count
    log "Number of UPI-enabled banks (#{data['banks'].size}) does not match the count on the NPCI website (#{count})}", :critical
    log "Please check https://www.npci.org.in/what-we-do/upi/live-members and update src/patches/banks/upi-enabled-banks.yml", :debug
    exit 1
  end

end

def parse_nach
  doc = Nokogiri::HTML(open('nach.html'))
  header_cleared = false
  sublets = {}
  banks = {}

  doc.css('table')[0].css('tr').each do |row|
    if header_cleared
      data = row.css('td')
      ifsc = data[4].text.strip
      bank_code = data[1].text.strip
      sublets[ifsc] = bank_code if ifsc.size == 11 && ifsc[0..3] != bank_code

      banks[bank_code] = bank_data(bank_code, data, ifsc)
    end
    header_cleared = true
  end

  write_sublet_json(sublets)
  # This is where the upi:true parameter to banks.json gets added
  banks = apply_bank_patches(banks)
  write_banks_json(banks)
  banks
end
