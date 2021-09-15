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
def fix_row_alignment!(row)
  log "#{row['IFSC']}: Using State = '#{row['CITY2']}' STD_CODE=#{row['STATE']}, PHONE=#{row['STD CODE']} and discarding PHONE=#{row['PHONE']}", :info
  row['STATE'],row['STD CODE'], row['PHONE'] = row['CITY2'], row['STATE'], row['STD CODE']
end

def fix_pipe_delimited_address!(row)
  log "Splitting address= #{row['ADDRESS']}. New values=", :info

  d = row['ADDRESS'].split '|'

  row['PHONE'] =  d[-1]
  row['STD CODE'] =  d[-2]
  row['STATE'] =  d[-3]
  row['CITY2'] =  d[-4]
  row['CITY1'] =  d[-5]
  row['ADDRESS'] =  d[-6]
  log row.select{|k,v| ['ADDRESS','PHONE', 'STD CODE', 'STATE', 'CITY1', 'CITY2'].include? k}, :info
end

def bank_name_from_code(code)
  Razorpay::IFSC::IFSC.bank_name_for(code)
end
