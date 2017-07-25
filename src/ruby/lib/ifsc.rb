require 'json'

module Razorpay
  class IFSC
    def self.data
      @data ||= JSON.load(File.read(File.join(__dir__, '../../IFSC.json')))
    end

    def self.validate(code)
      return false unless code.size == 11
      return false unless code[4] == '0'

      bank_code = code[0..3].upcase
      branch_code = code[4..-1].upcase

      return false unless data.has_key? bank_code

      list = data[bank_code]

      # puts "#{code} - " + (code =~ /[0-9]/)

      if (code =~ /[0-9]/)
        self.lookup_numeric(list, branch_code)
      else
        self.lookup_string(list, branch_code)
      end
    end

    def self.lookup_numeric(list, branch_code)
      branch_code = branch_code.to_i

      return true if list.include? branch_code

      lookup_ranges list, branch_code
    end

    def self.lookup_ranges(list, branch_code)
      list.each do |item|
        return false unless item.is_a?(Array) && item.size == 2

        (item[0]...item[1]) === branch_code
      end
    end

    def self.lookup_string(list, branch_code)
      list.include? branch_code
    end
  end
end
