require './methods'

imps = parse_imps
puts "[NPCI] Got #{imps.keys.size} entries"

rtgs = parse_rtgs
puts "[RTGS] Got #{rtgs.keys.size} entries"

neft = parse_neft
puts "[NEFT] Got #{neft.keys.size} entries"

log 'Combining the above 3 lists'
data, hash = merge_dataset(neft, rtgs, imps)

puts "Got total #{hash.keys.size} entries"

ifsc_codes_list = rtgs.keys + neft.keys + imps.keys

log 'Exporting CSV'
export_csv(data)

log 'Exporting JSON by Banks'
export_json_by_banks(ifsc_codes_list, hash)

log 'Exporting JSON List'
export_json_list(ifsc_codes_list)

log 'Exporting to validation JSON'
export_to_code_json(ifsc_codes_list)

log 'Export done'
