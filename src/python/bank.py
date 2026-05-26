import json
from importlib.resources import files
from .ifsc import IFSC

pkg_path = files("ifsc.data")


with open(pkg_path.joinpath("banks.json")) as f:
    banks = json.load(f)


class Bank:
    def __init__(self):
        self.banks = banks

    def get_bank_details(self, bank_code):
        if not bank_code in banks:
            return
        else:
            data = banks[bank_code]
            bank_name = IFSC().get_bank_name(bank_code)
            if bank_name:
                data["name"] = bank_name
            if data["micr"] != "":
                data["bank_code"] = data["micr"][3:6]

            return data
