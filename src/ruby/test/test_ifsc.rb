require 'ifsc'
require 'minitest/autorun'

module Razorpay
  # Tests for IFSC
  class IFSCTest < Minitest::Test
    def test_true_validator
      assert IFSC::validate 'KKBK0000261'
      assert IFSC::validate 'HDFC0002854'
      assert IFSC::validate 'KARB0000001'
    end

    def test_validate_range
      assert IFSC::validate 'DLXB0000097'
    end

    def test_validate_string_lookup
      assert IFSC::validate 'BOTM0NEEMRA'
      assert IFSC::validate 'BARB0ZOOTIN'
    end

    def test_validate_invalid_code
      refute IFSC::validate 'BOTM0XEEMRA'
      refute IFSC::validate 'BOTX0000000'
      refute IFSC::validate 'BOTX0000500'
      refute IFSC::validate 'BOTM0000500'
      refute IFSC::validate 'DLXB0000500'
    end
  end
end