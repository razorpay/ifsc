require './methods'

# Inspect RBI CSV headers to identify bank name columns
inspect_rbi_csv_headers(['RTGS-1', 'RTGS-2', 'RTGS-3', 'NEFT-0', 'NEFT-1'])

upi_banks = parse_upi

validate_sbi_swift

banks = parse_nach
log "[NPCI] Parsed the NACH sheet, got #{banks.keys.size} banks"

# Generate comprehensive banknames.json from multiple sources
comprehensive_bank_names = generate_comprehensive_banknames_json(['RTGS-1', 'RTGS-2', 'RTGS-3', 'NEFT-0', 'NEFT-1'])

imps = parse_imps(banks)
log "[NPCI] Got #{imps.keys.size} entries"

# The first sheet on RTGS gives summary numbers, which we ignore
rtgs = parse_csv(['RTGS-1', 'RTGS-2', 'RTGS-3'], banks, {"RTGS"=> true})
log "[RTGS] Got #{rtgs.keys.size} entries"

neft = parse_csv(['NEFT-0', 'NEFT-1'], banks, {"NEFT"=> true})
log "[NEFT] Got #{neft.keys.size} entries"

log 'Combining the above 3 lists'
dataset = merge_dataset(neft, rtgs, imps)

log "Got total #{dataset.keys.size} entries"

dataset = apply_bank_patches(dataset)
dataset = apply_patches(dataset)

export_csv(dataset)
export_json_by_banks(dataset.keys, dataset)
export_json_list(dataset.keys)
export_to_code_json(dataset.keys)

log 'Export done'
