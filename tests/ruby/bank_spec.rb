require 'ifsc'
require 'bank'

describe Razorpay::IFSC::Bank do
  it 'should define the relevant constants' do
    expect(described_class::PUNB).to eq :PUNB
  end

  it 'should return details from the bank code' do
    expect(described_class.get_details(:PUNB)).to eq(code: 'PUNB',
                                                     type: 'PSB',
                                                     upi: true,
                                                     ifsc: 'PUNB0244200',
                                                     micr: '110024001',
                                                     bank_code: '024',
                                                     iin: '508568',
                                                     apbs: true,
                                                     ach_credit: true,
                                                     ach_debit: true,
                                                     nach_debit: true)
  end

  it 'should match all constants defined in banknames.json' do
  	JSON.parse(File.read('src/banknames.json')).keys.each do |c|
  	  expect(described_class::const_get(c)).to eq c.to_sym
  	end
  end

end
