require './methods'

data = parse_sheets()

hash = Hash.new
data.each { |row| hash[row['IFSC']] = row }
ifsc_codes_list = hash.keys

log "Exporting CSV"
export_csv(data)

log "Exporting YAML"
export_yml(hash)

log "Exporting Marshal"
export_marshal(hash)

log "Exporting JSON"
export_json(hash)

log "Exporting Marshal List"
export_lookup_table_marshal(ifsc_codes_list)

log "Exporting YAML List"
export_yml_list(ifsc_codes_list)

log "Exporting JSON List"
export_json_list(ifsc_codes_list)

log "Exporting Bloom Filter"
export_bloom_filter(ifsc_codes_list)

log "Exporting JSON by Banks"
export_json_by_banks(ifsc_codes_list, hash)

log "Exporting to source code"
export_to_code_json(ifsc_codes_list, hash)

log "Export done"