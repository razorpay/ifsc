require './methods'

rtgs_data = parse_rtgs

puts "Got #{rtgs_data.keys.size} entries"
ifsc_data = parse_neft
puts "Got #{ifsc_data.keys.size} entries"

# Using IFSC data and marking rtgs=true for the applicable ifsc's

log 'Combining the RTGS and IFSC lists'
data, hash = parse_ifsc_rtgs(ifsc_data, rtgs_data)

puts "Got total #{hash.keys.size} entries"

if File.exist? 'sheets/SUBLET.xlsx'
  sublet_data = parse_sublet_sheet
  log 'Exporting Sublet JSON'
  export_sublet_json(sublet_data)
end

ifsc_codes_list = rtgs_data.keys + ifsc_data.keys

log 'Exporting CSV'
export_csv(data)

log 'Exporting JSON by Banks'
export_json_by_banks(ifsc_codes_list, hash)

log "Exporting JSON List"
export_json_list(ifsc_codes_list)

log 'Exporting to source code'
export_to_code_json(ifsc_codes_list, hash)

log 'Export done'
