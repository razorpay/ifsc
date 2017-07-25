require 'json'

module Razorpay
  class IFSC
    class << self
      def data
        @data ||= JSON.load(File.read(File.join(__dir__, '../../IFSC.json')))
      end

      def validate(code)
        return false unless code.size == 11
        return false unless code[4] == '0'

        bank_code = code[0..3].upcase
        branch_code = code[5..-1].upcase

        return false unless data.has_key? bank_code

        list = data[bank_code]

        if (branch_code.match(/^(\d)+$/))
          lookup_numeric(list, branch_code)
        else
          lookup_string(list, branch_code)
        end
      end

      private

      def lookup_numeric(list, branch_code)
        branch_code = branch_code.to_i

        return true if list.include? branch_code

        lookup_ranges list, branch_code
      end

      def lookup_ranges(list, branch_code)
        list.each do |item|
          return false unless item.is_a?(Array) && item.size == 2

          (item[0]...item[1]) === branch_code
        end
      end

      def lookup_string(list, branch_code)
        list.include? branch_code
      end
    end
  end
end
