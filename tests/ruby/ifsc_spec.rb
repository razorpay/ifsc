require 'ifsc'
require 'bank'

describe Razorpay::IFSC::IFSC do
  let(:mocked_response) do
    {
      'BANK' => 'Kotak Mahindra Bank',
      'IFSC' => 'KKBK0000261',
      'BRANCH' => 'GURGAON',
      'ADDRESS' => 'JMD REGENT SQUARE,MEHRAULI GURGAON ROAD,OPPOSITE BRISTOL HOTEL,',
      'CONTACT' => '4131000',
      'CITY' => 'GURGAON',
      'DISTRICT' => 'GURGAON',
      'STATE' => 'HARYAN'
    }
  end
  let(:dummy_code) { 'foo' }
  let(:code_double) { double('code double') }
  let(:code) { described_class.new(mocked_response['IFSC']) }

  describe '.get' do
    before do
      allow(code).to receive(:api_data).and_return(mocked_response)
    end

    it 'should parse the IFSC details correctly from the server' do
      fetched_code = code.get

      expect(fetched_code.bank).to eq mocked_response['BANK']
      expect(fetched_code.ifsc).to eq mocked_response['IFSC']
      expect(fetched_code.branch).to eq mocked_response['BRANCH']
      expect(fetched_code.address).to eq mocked_response['ADDRESS']
      expect(fetched_code.contact).to eq mocked_response['CONTACT']
      expect(fetched_code.city).to eq mocked_response['CITY']
      expect(fetched_code.district).to eq mocked_response['DISTRICT']
      expect(fetched_code.state).to eq mocked_response['STATE']
    end

    it 'should set @valid to true and skip local validation' do
      fetched_code = code.get

      expect(fetched_code.instance_variable_get(:@valid)).to eq true
      expect(fetched_code.valid?).to eq true
    end
  end

  describe '.get_bank_name' do
    before do
      allow(code).to receive(:api_data).and_return(mocked_response)
    end

    it 'should load the bank name into the object' do
      expect(code.bank).to be_nil
      code.get
      expect(code.bank).to eq mocked_response['BANK']
    end
  end

  describe '.class' do
    describe '.find' do
      it 'should validate and return the fetched object' do
        expect(described_class).to receive(:new).with(dummy_code).and_return(code_double)
        expect(code_double).to receive(:get)
        described_class.find(dummy_code)
      end
    end

    describe '#bank_name_for(code)' do
      it 'should return the correct bank name' do
        expect(described_class.bank_name_for(mocked_response['IFSC'])).to eq mocked_response['BANK']
      end

      it 'should return the correct sublet bank name' do
        expect(described_class.bank_name_for('ALLA0AU1002')).to eq 'Allahabad Up Gramin Bank'
      end

      it 'should return the correct sublet bank name for custom sublets' do
        expect(described_class.bank_name_for('VIJB0SSB001')).to eq 'Shimsha Sahakara Bank Niyamitha'
        expect(described_class.bank_name_for('KSCB0006001')).to eq 'Tumkur District Central Bank'
        expect(described_class.bank_name_for('WBSC0KPCB01')).to eq 'Kolkata Police Co-operative Bank'
        expect(described_class.bank_name_for('YESB0ADB002')).to eq 'Amravati District Central Co-operative Bank'
      end
    end

    describe '#valid?' do
      it 'should validate regular numeric branch codes' do
        expect(described_class.valid?('KKBK0000261')).to eq true
        expect(described_class.valid?('HDFC0002854')).to eq true
        expect(described_class.valid?('KARB0000001')).to eq true
        expect(described_class.valid?('DLXB0000097')).to eq true
      end

      it 'should validate string branch codes' do
        expect(described_class.valid?('BOTM0NEEMRA')).to eq true
        expect(described_class.valid?('BARB0ZOOTIN')).to eq true
      end

      it 'should not validate invalid codes' do
        expect(described_class.valid?('BOTM0XEEMRA')).to eq false
        expect(described_class.valid?('BOTX0000000')).to eq false
        expect(described_class.valid?('BOTX0000500')).to eq false
        expect(described_class.valid?('BOTM0000500')).to eq false
        expect(described_class.valid?('DLXB0000500')).to eq false
      end
    end

    describe '#validate!' do
      context 'when valid? returns false' do
        before do
          allow(described_class).to receive(:valid?).with(dummy_code).and_return(false)
        end
        it 'should raise an error when validations fail' do
          expect { described_class.validate!(dummy_code) }.to raise_error(Razorpay::IFSC::InvalidCodeError)
        end
      end
    end
  end
end

describe Razorpay::IFSC::Bank do
  it 'should define the relevant constants' do
    expect(described_class::PUNB).to eq :PUNB
  end
end
