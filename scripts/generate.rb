require './methods'

data, file_ifsc_mappings = parse_sheets()

hash = Hash.new
data.each { |row| hash[row['IFSC']] = row }
ifsc_codes_list = hash.keys

if File.exists? 'sheets/SUBLET.csv'
	sublet_data = parse_sublet_sheet()
	log "Exporting Sublet JSON"
	export_sublet_json(sublet_data)
end

log "Exporting CSV"
export_csv(data)

log "Exporting YAML"
export_yml(hash)

log "Exporting JSON"
export_json(hash)

log "Exporting YAML List"
export_yml_list(ifsc_codes_list)

log "Exporting JSON List"
export_json_list(ifsc_codes_list)

log "Exporting JSON by Banks"
export_json_by_banks(ifsc_codes_list, hash)

log "Exporting to source code"
export_to_code_json(ifsc_codes_list, hash)

log "Export done"
