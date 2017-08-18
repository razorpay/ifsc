require 'ifsc'

describe Razorpay::IFSC::IFSC do
  tests = JSON.parse File.read 'tests/validator_asserts.json'

  tests.each do |test_name, test_cases|
    it  "should #{test_name}" do
      test_cases.each do |ifsc, expected_value|
        expect(Razorpay::IFSC::IFSC.valid? ifsc).to eq expected_value
      end
    end
  end
end
