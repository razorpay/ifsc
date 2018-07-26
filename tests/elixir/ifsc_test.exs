defmodule IFSCTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  alias Razorpay.IFSC

  @sample_data %IFSC{
    bank: "Kotak Mahindra Bank",
    bank_code: "KKBK",
    ifsc: "KKBK0000261",
    branch: "GURGAON",
    address: "JMD REGENT SQUARE,MEHRAULI GURGAON ROAD,OPPOSITE BRISTOL HOTEL,",
    contact: "4131000",
    city: "GURGAON",
    district: "GURGAON",
    state: "HARYANA",
    rtgs: true,
  }

  setup do
    ExVCR.Config.cassette_library_dir("tests/fixture/exvcr")
  end

  describe "#get" do
    test "should fetch a valid code from the API correctly" do
      use_cassette "valid_ifsc", match_requests_on: [:url] do
        assert {:ok, @sample_data} = IFSC.get(@sample_data.ifsc)
      end
    end
    test "should return :invalid_ifsc for an invalid code" do
      use_cassette "invalid_ifsc", match_requests_on: [:url] do
        assert {:error, :invalid_ifsc} = IFSC.get("foobar")
      end
    end
  end

  describe "#validate" do
    test "should validate regular numeric branch codes" do
      assert {:ok, %IFSC{}} = IFSC.validate("KKBK0000261")
      assert {:ok, %IFSC{}} = IFSC.validate("HDFC0002854")
      assert {:ok, %IFSC{}} = IFSC.validate("KARB0000001")
      assert {:ok, %IFSC{}} = IFSC.validate("DLXB0000097")
    end

    test "should validate string branch codes" do
      assert {:ok, %IFSC{}} = IFSC.validate("BOTM0NEEMRA")
      assert {:ok, %IFSC{}} = IFSC.validate("BARB0ZOOTIN")
    end

    test "should not validate invalid codes" do
      assert {:error, _reason} = IFSC.validate("BOTM0XEEMRA")
      assert {:error, _reason} = IFSC.validate("BOTX0000000")
      assert {:error, _reason} = IFSC.validate("BOTX0000500")
      assert {:error, _reason} = IFSC.validate("BOTM0000500")
      assert {:error, _reason} = IFSC.validate("DLXB0000500")
    end

    test "should return the correct bank name and code for regular branches" do
      assert {:ok, %IFSC{
        bank: "Kotak Mahindra Bank",
        bank_code: "KKBK",
      }} = IFSC.validate("KKBK0000261")
    end

    test "should return the correct bank name and code for sublet branches" do
      assert {:ok, %IFSC{
        bank: "Allahabad Up Gramin Bank",
        bank_code: "AUGX",
      }} = IFSC.validate("ALLA0AU1002")
    end
  end
end
