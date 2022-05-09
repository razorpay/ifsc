# frozen_string_literal: true
# The bank.rb file is generated from `bank.rb.tpl` using constants
# from banknames.json. Run `make generate-constants` to
# update this file
module Razorpay
  module IFSC
    module Bank{{ range  .Value }}
      {{ . }} = :{{ . }}{{ end }}

      class << self
        def get_details(code)
          h = data[code]
          h[:bank_code] = (h[:micr][3..5] if h.key? :micr)
          h
        end

        def parse_json_file(file)
          file = "../#{file}.json"
          JSON.parse(File.read(File.join(__dir__, file)), symbolize_names: true)
        end

        def data
          @data ||= parse_json_file 'banks'
        end
      end
    end
  end
end
