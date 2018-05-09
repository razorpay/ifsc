require './methods'

# rtgs_data = parse_rtgs()
ifsc_data = parse_sheets()

# Using IFSC data and marking rtgs=true for the applicable ifsc's

data, hash = parse_ifsc_rtgs(ifsc_data, {})

# if File.exists? 'sheets/SUBLET.xlsx'
# 	sublet_data = parse_sublet_sheet()
# 	log "Exporting Sublet JSON"
# 	export_sublet_json(sublet_data)
# end

ifsc_codes_list = hash.keys

log "Exporting CSV"
export_csv(data)

log "Exporting YAML"
export_yml(hash)

log "Exporting YAML List"
export_yml_list(ifsc_codes_list)

log "Exporting JSON List"
export_json_list(ifsc_codes_list)

log "Exporting JSON by Banks"
export_json_by_banks(ifsc_codes_list, hash)

log "Exporting to source code"
export_to_code_json(ifsc_codes_list, hash)

log "Export done"
