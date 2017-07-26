require 'json'
require 'open-uri'

module Razorpay
  module IFSC
    class InvalidCodeError < StandardError; end
    class ServerError < StandardError; end

    class IFSC
      API = 'https://ifsc.razorpay.com/'

      attr_reader :bank, :ifsc, :branch, :address, :contact, :city, :district, :state

      def initialize(ifsc)
        @ifsc = ifsc
      end

      def valid?
        @valid ||= self.class.valid? ifsc
      end

      def get
        raise InvalidCodeError unless valid?
        @bank = api_data['BANK']
        @branch = api_data['BRANCH']
        @address = api_data['ADDRESS']
        @contact = api_data['CONTACT']
        @city = api_data['CITY']
        @district = api_data['DISTRICT']
        @state = api_data['STATE']
        self
      end

      def get_bank_name
        @bank = self.class.bank_name_for @ifsc
      end

      private

      def api_data
        @api_data ||= JSON.parse(URI.join(API, ifsc).read)
      rescue OpenURI::HTTPError, SocketError => e
        raise ServerError, e.message
      end

      class << self
        def find(ifsc)
          self.new(ifsc).get
        end

        def validate!(code)
          if valid? code
            true
          else
            raise InvalidCodeError
          end
        end

        def valid?(code)
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

        def bank_name_for(code)
          sublet_code = sublet_data[code]
          regular_code = code[0..3].upcase
          bank_name_data[sublet_code || regular_code]
        end

        private

        def data
          @data ||= JSON.load(File.read(File.join(__dir__, '../../IFSC.json')))
        end

        def bank_name_data
          @bank_name_data ||= JSON.load(File.read(File.join(__dir__, '../../banknames.json')))
        end

        def sublet_data
          @sublet_data ||= JSON.load(File.read(File.join(__dir__, '../../sublet.json')))
        end

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
end
