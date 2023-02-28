import json
import requests
from importlib.resources import files

pkg_path = files("ifsc.data")

with open(pkg_path.joinpath("IFSC.json")) as f:
    ifscs = json.load(f)

with open(pkg_path.joinpath("banknames.json")) as f:
    bank_names = json.load(f)

with open(pkg_path.joinpath("sublet.json")) as f:
    sublets = json.load(f)

with open(pkg_path.joinpath("custom-sublets.json")) as f:
    custom_sublets = json.load(f)


class IFSC:
    def __init__(self):
        self.base_url = "https://ifsc.razorpay.com/"
        self.ifscs = ifscs
        self.bank_names = bank_names
        self.sublets = sublets
        self.custom_sublets = custom_sublets

    def validate(self, code):
        if len(code) != 11:
            return False

        if code[4] != "0":
            return False

        _bank_code = code[:4].upper()
        _branch_code = code[5:].upper()

        if not _bank_code in self.ifscs:
            return False

        if _branch_code.isnumeric():
            _branch_code = int(_branch_code)
            return _branch_code in self.ifscs[_bank_code]

        return _branch_code in self.ifscs[_bank_code]

    def get_details(self, code):
        url = self.base_url + code
        if not self.validate(code):
            raise ValueError("Invalid IFSC code")

        data = {}
        try:
            res = requests.get(url)
            if res.status_code == 200:
                data = res.json()
            elif res.status_code == 404:
                raise ValueError("Invalid IFSC code")
            else:
                raise ValueError(
                    "IFSC API returned an invalid response for {}".format(code)
                )
        except Exception as e:
            raise ValueError("Invalid IFSC code")

        return data

    def get_bank_name(self, code: str) -> str:
        if code in self.bank_names:
            return self.bank_names[code]

        if self.validate(code):
            if code in self.sublets:
                bank_code = self.sublets[code]
                return self.bank_names[bank_code]
            else:
                return self.get_custom_sublet(code)
        else:
            raise ValueError("Invalid IFSC code")

    def get_custom_sublet(self, code: str) -> str:
        for key, value in self.custom_sublets:
            if len(code) >= len(key) and code[: len(key)] == key:
                if value in self.bank_names:
                    return self.bank_names[value]
                else:
                    return value

        raise ValueError("Invalid IFSC code")


if __name__ == "__main__":
    ifsc = IFSC()
    print(ifsc.get_bank_name("SBIN0000001"))
    print(ifsc.get_details("SBIN0000001"))
