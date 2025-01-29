require './methods'

upi_banks = parse_upi

validate_sbi_swift

banks = parse_nach
log "[NPCI] Parsed the NACH sheet, got #{banks.keys.size} banks"

imps = parse_imps(banks)
log "[NPCI] Got #{imps.keys.size} entries"

# The first sheet on RTGS gives summary numbers, which we ignore
rtgs = parse_csv(['RTGS-1', 'RTGS-2', 'RTGS-3'], banks, {"RTGS"=> true})
log "[RTGS] Got #{rtgs.keys.size} entries"

neft = parse_csv(['NEFT-0', 'NEFT-1'], banks, {"NEFT"=> true})
log "[NEFT] Got #{neft.keys.size} entries"

log 'Combining the above 3 lists'
dataset = merge_dataset(neft, rtgs, imps)

log "Got total #{dataset.keys.size} entries", :info

dataset = apply_patches(dataset)

log 'Applied patches', :info

# We do this once, to:
# 1. Ensure the same ordering in most datasets (consistency)
# 2. Remove any future .keys calls (speed)
ifsc_codes_list = dataset.keys.sort

log 'Exporting CSV'
export_csv(dataset)

log 'Exporting JSON by Banks'
export_json_by_banks(ifsc_codes_list, dataset)

log 'Exporting JSON List'
export_json_list(ifsc_codes_list)

log 'Exporting to validation JSON'
export_to_code_json(ifsc_codes_list)

log 'Export done'
