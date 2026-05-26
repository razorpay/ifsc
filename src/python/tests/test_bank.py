from ifsc import Bank


class TestBanks:
    @classmethod
    def setup_class(cls):
        cls.bank = Bank()

    @classmethod
    def teardown_class(cls):
        pass

    def test_get_bank_details(self):
        pnb_bank = {
            "name": "Punjab National Bank",
            "bank_code": "024",
            "code": "PUNB",
            "type": "PSB",
            "ifsc": "PUNB0244200",
            "micr": "110024001",
            "iin": "508568",
            "apbs": True,
            "ach_credit": True,
            "ach_debit": True,
            "nach_debit": True,
            "upi": True,
        }
        fino_bank = {
            "name": "Fino Payments Bank",
            "bank_code": "099",
            "code": "FINO",
            "type": "PB",
            "ifsc": "FINO0000001",
            "micr": "990099909",
            "iin": "608001",
            "apbs": True,
            "ach_credit": True,
            "ach_debit": False,
            "nach_debit": False,
            "upi": True,
        }
        assert pnb_bank == self.bank.get_bank_details("PUNB")
        assert fino_bank == self.bank.get_bank_details("FINO")
