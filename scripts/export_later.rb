require './methods'
require './ifsc'

ifsc = IFSC.new

list = JSON.parse ifsc.list
data = JSON.parse ifsc.data

#export_bloom_filter(list)
#export_json_by_banks(list, data)
#export_to_php(list,data)
export_to_ruby(list, data)