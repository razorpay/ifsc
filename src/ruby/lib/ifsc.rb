require 'json'
require 'httparty'

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
        @bank = api_data['BANK']
        @branch = api_data['BRANCH']
        @address = api_data['ADDRESS']
        @contact = api_data['CONTACT']
        @city = api_data['CITY']
        @district = api_data['DISTRICT']
        @state = api_data['STATE']
        @valid = true
        self
      end

      def get_bank_name
        @bank = self.class.bank_name_for @ifsc
      end

      private

      def api_data
        @api_data ||= begin
          response = HTTParty.get(URI.join(API, ifsc))
          raise InvalidCodeError, 'IFSC API returned 404' if response.code == 404
          JSON.parse(response.body)
        end
      rescue HTTParty::Error, SocketError => e
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

          if branch_code.match(/^(\d)+$/)
            data[bank_code].include? branch_code.to_i
          else
            data[bank_code].include? branch_code
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

      end
    end
  end
end
