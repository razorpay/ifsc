require '../../src/ruby/ifsc'

def sanitize(str)
  return nil if str.nil? or str.length==0
  ["┬ô", "┬û",'┬ö','┬Æ','┬á','┬æ','┬ù','ý','ý','┬á','Â'].each do |pattern|
    str.gsub!(pattern,' ')
  end
  str.gsub!('├ë','e')
  str.gsub!('├å','a')
  str.gsub!('├ë','e')
  str.gsub!('`',"'")
  str.gsub!('Ã½'," ")
  # replace newlines
  str.gsub!("\n", " ")
  # Remove all spaces (including nbsp) at the start and end of the string
  str.gsub(/\A[[:space:]]+|[[:space:]]+\z/, '')
end

# Some rows have last 2 columns shifted by 2
# Check for numeric values of STATE in RTGEB0815.xlsx for examples
# This checks and fixes those
def fix_row_alignment_for_rtgs(row)
  log "#{row['IFSC']}: Switching State(#{row['STATE']}) and ADDRESS(#{row['ADDRESS']})", :info
  row['STATE'], row['ADDRESS'] = row['ADDRESS'], row['STATE']
  return row
end

def bank_name_from_code(code)
  Razorpay::IFSC::IFSC.bank_name_for(code)
end
