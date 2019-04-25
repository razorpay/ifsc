require 'nokogiri'
require 'json'
require 'uri'

# These are invalid sublets
# given out by RBI
# because they result in 1 bank
# having 2 different codes
IGNORED_SUBLETS = [
  'RSBL0000001',
  'APGV0000001',
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
  'SKSB0000001',
  # UFSB and UJVN are the same
  'UJVN0000001',
  # PKGB and PKGX are the same
  'PKGB0000001',
  # IPOS and IPPB are the same
  'IPOS0000001',
  # FSFB and FINF are the same
  'FSFB0000001',
  # Same as SHIX
  'SMCB0000001'
].freeze


def write_sublet_json(sublets)
  File.open('data/sublet.json', 'w') do |f|
    f.write JSON.pretty_generate(Hash[sublets.sort])
    log "Saved data/sublet.json"
  end
end

def write_banks_json(banks)
  File.open('data/banks.json', 'w') do |f|
    f.write JSON.pretty_generate(Hash[banks.sort])
    log "Saved data/banks.json"
  end
end

def bank_data(bank_code, data, ifsc)
  micr = data[5].text.strip
  micr = micr.length == 9 ? micr : nil

  iin = data[6].text.strip
  iin = iin.length == 6 ? iin : nil
  {
    code: bank_code,
    type: data[3].text.strip,
    ifsc: IGNORED_SUBLETS.include?(ifsc) == false ? ifsc : nil,
    micr: micr,
    iin: iin,
    apbs: data[7].text.strip == 'Yes',
    ach_credit: data[8].text.strip == 'Yes',
    ach_debit: data[9].text.strip == 'Yes',
    nach_debit: data[10].text.strip == 'Yes'
  }
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
      if (ifsc.size == 11) && (ifsc[0..3] != bank_code) && (IGNORED_SUBLETS.include?(ifsc) == false)
        sublets[ifsc] = bank_code
      end

      banks[bank_code] = bank_data(bank_code, data, ifsc)
    end
    header_cleared = true
  end

  write_sublet_json(sublets)
  write_banks_json(banks)

  banks
end
