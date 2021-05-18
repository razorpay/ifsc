def sanitize(str)
  return nil if str.nil? or str.length==0
  ["┬ô", "┬û",'┬ö','┬Æ','┬á','┬æ','┬ù','ý','ý','┬á'].each do |pattern|
    str.gsub!(pattern,' ')
  end
  str.gsub!('├ë','e')
  str.gsub!('├å','a')
  str.gsub!('├ë','e')
  # Remove all spaces (including nbsp) at the start and end of the string
  str.gsub(/\A[[:space:]]+|[[:space:]]+\z/, '')
end

# Some rows have last 2 columns shifted by 2
# Check for numeric values of STATE in RTGEB0815.xlsx for examples
# This checks and fixes those
def fix_row_alignment_for_rtgs(row)
  # List of recognized states
  unless KNOWN_STATES.include? row['CITY2'].to_s.strip
    log "#{row['IFSC']} has an unknown state (#{row['CITY2']}), please check"
    exit 1
  end
  # Start right shifting from the right-most column
  row['PHONE'] = row['STD CODE']
  # Move STATE's numeric value to STD CODE
  row['STD CODE'] = row['STATE']
  row['STATE'] = row['CITY2']
  # Fix CITY2 value by duplicating CITY1
  row['CITY2'] = row['CITY1']
  return row
end
