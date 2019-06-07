require 'json'
require 'httparty'

# Main Razorpay module
module Razorpay
  # IFSC Module
  module IFSC
    class InvalidCodeError < StandardError; end
    class ServerError < StandardError; end
    # Primary class for handling IFSC Codes
    class IFSC
      API = 'https://ifsc.razorpay.com/'.freeze

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

      # Returns the bank name taking sublet branches
      # into consideration. Returns the normal branch
      # name otherwise
      def bank_name
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
          new(ifsc).get
        end

        def validate!(code)
          raise InvalidCodeError unless valid? code
          true
        end

        def valid?(code)
          return false unless code.size == 11
          return false unless code[4] == '0'

          bank_code = code[0..3].upcase
          branch_code = code[5..-1].upcase

          return false unless data.key? bank_code

          if branch_code =~ /^(\d)+$/
            data[bank_code].include? branch_code.to_i
          else
            data[bank_code].include? branch_code
          end
        end

        def bank_name_for(code)
          sublet_code = sublet_data[code]
          regular_code = code[0..3].upcase
          custom_name = bank_name_via_custom_sublet code
          custom_name || bank_name_data[sublet_code || regular_code]
        end

        private

        # See getCustomSubletName in IFSC.php
        def bank_name_via_custom_sublet(code)
          custom_sublet_data.each do |prefix, value|
            if prefix == code[0..prefix.length - 1]
              if value.length == 4
                return bank_name_data[value]
              else
                return value
              end
            end
          end
          return nil
        end

        def parse_json_file(file)
          file = "../#{file}.json"
          JSON.parse(File.read(File.join(__dir__, file)))
        end

        def data
          @data ||= parse_json_file 'IFSC'
        end

        def bank_name_data
          @bank_name_data ||= parse_json_file 'banknames'
        end

        def sublet_data
          @sublet_data ||= parse_json_file 'sublet'
        end

        def custom_sublet_data
          @custom_sublet_data ||= parse_json_file 'custom-sublets'
        end
      end
    end
  end
end
