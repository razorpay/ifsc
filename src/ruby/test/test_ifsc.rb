require 'ifsc'
require 'minitest/autorun'

module Razorpay
  # Tests for IFSC
  class IFSCTest < Minitest::Test
    def test_true_validator
      assert IFSC::Code.valid? 'KKBK0000261'
      assert IFSC::Code.valid? 'HDFC0002854'
      assert IFSC::Code.valid? 'KARB0000001'
    end

    def test_validate_range
      assert IFSC::Code.valid? 'DLXB0000097'
    end

    def test_validate_string_lookup
      assert IFSC::Code.valid? 'BOTM0NEEMRA'
      assert IFSC::Code.valid? 'BARB0ZOOTIN'
    end

    def test_validate_invalid_code
      refute IFSC::Code.valid? 'BOTM0XEEMRA'
      refute IFSC::Code.valid? 'BOTX0000000'
      refute IFSC::Code.valid? 'BOTX0000500'
      refute IFSC::Code.valid? 'BOTM0000500'
      refute IFSC::Code.valid? 'DLXB0000500'
    end
  end
end
