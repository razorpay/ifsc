require './methods'

data = parse_sheets()

hash = Hash.new
data.each { |row| hash[row['IFSC']] = row }
ifsc_codes_list = hash.keys

export_csv(data)
export_yml(hash)
export_marshal(hash)
export_json(hash)

export_lookup_table_marshal(ifsc_codes_list)
export_yml_list(ifsc_codes_list)
export_json_list(ifsc_codes_list)