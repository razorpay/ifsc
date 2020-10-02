import requests
import json


class IFSC(object):
    """ A client for accessing the Razorpay API. """

    """
        Initializes the Twilio Client
        sets the BASE_URL
        :returns IFSC object
    """

    def __init__(self):
        self.BASE_URL = 'https://ifsc.razorpay.com/'
        with open("../IFSC.json") as json_file:
            self.bankdata = json.loads(json_file.read())
        pass

    """
    validate
    :returns True if the code is valid
    """

    def validate(self, code: str):
        if len(code) != 11:
            return False
        if code[4] != '0':
            return False
        _bankcode = code[0:4].upper()
        _branchcode = code[5:].upper()

        if not _bankcode in self.bankdata:
            return False

        _banklist = set(self.bankdata[_bankcode])

        if _branchcode.isdigit():
            return int(_branchcode) in _banklist

        return _branchcode in _banklist

    """
    Fetches details for given code
    :returns response from  razorpay api for ifsc
    :raises ValueErro for invalid data
    """

    def fetch_details(self, code: str):
        _final_URL = self.BASE_URL + code

        if not self.validate(code):
            raise ValueError(f'provided code is invalid')
        headers = {
            'Content-Type': 'application/json',
        }
        #https://nedbatchelder.com/blog/200711/rethrowing_exceptions_in_python.html ( gives a full stack trace for exception)
        try:
            response = requests.get(_final_URL, headers=headers)
        except Exception as e:
            import sys
            raise sys.exc_info()[1]

        return response.json()
