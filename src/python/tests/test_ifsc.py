import json
from ifsc import IFSC


class TestIFSC:
    @classmethod
    def setup_class(cls):
        cls.ifsc = IFSC()
        cls.test_groups = json.loads(
            open("./tests/validator_asserts.json").read()
        )
        cls.sublets_fixtures = {
            "SKUX": "IBKL0116SBK",
            "SPTX": "IBKL0116SSB",
            "VCOX": "IBKL0116VMC",
            "AURX": "IBKL01192AC",
            "NMCX": "IBKL0123NMC",
            "MSSX": "IBKL01241MB",
            "TNCX": "IBKL01248NC",
            "URDX": "IBKL01263UC",
        }
        cls.custom_sublets_fixtures = {
            "KSCB0006001": "Tumkur District Central Bank",
            "WBSC0KPCB01": "Kolkata Police Co-operative Bank",
            "YESB0ADB002": "Amravati District Central Co-operative Bank",
        }

    @classmethod
    def teardown_class(cls):
        pass

    def test_validate_bank_names(self):
        for bank_code, expected in self.sublets_fixtures.items():
            actual = self.ifsc.get_bank_name(bank_code)
            expected = self.ifsc.get_bank_name(bank_code[0:4])
            assert actual == expected

        for bank_code, expected in self.custom_sublets_fixtures.items():
            actual = self.ifsc.get_bank_name(bank_code)
            assert actual == expected

    def test_validator(self):
        for test_cases in self.test_groups:
            for code in self.test_groups[test_cases]:
                assert (
                    self.ifsc.validate(code)
                    == self.test_groups[test_cases][code]
                )

    def test_validate_bank_code(self):
        assert self.ifsc.validate_bank_code("ABCX") == True
        assert self.ifsc.validate_bank_code("Aaaa") == False
