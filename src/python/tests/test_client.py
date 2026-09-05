import json
from ifsc import IFSC
from unittest.mock import MagicMock, patch
import pytest


class TestIFSC:
    @classmethod
    def setup_class(cls):
        cls.ifsc = IFSC()

    @classmethod
    def teardown_class(cls):
        pass

    @patch("ifsc.ifsc.requests")
    def test_get_details_success(self, mock_requests):
        mock_response = MagicMock()

        mock_response.status_code = 200
        mock_response.json.return_value = {
            "MICR": "560226263",
            "BRANCH": "THE AGS EMPLOYEES COOP BANK LTD",
            "ADDRESS": "SANGMESH BIRADAR BANGALORE",
            "STATE": "KARNATAKA",
            "CONTACT": "+91802265658",
            "UPI": True,
            "RTGS": True,
            "CITY": "BANGALORE",
            "CENTRE": "BANGALORE URBAN",
            "DISTRICT": "BANGALORE URBAN",
            "NEFT": True,
            "IMPS": True,
            "SWIFT": "HDFCINBB",
            "BANK": "HDFC Bank",
            "BANKCODE": "HDFC",
            "IFSC": "HDFC0CAGSBK",
        }
        mock_requests.get.return_value = mock_response
        got = self.ifsc.get_details("HDFC0CAGSBK")
        want = mock_response.json.return_value
        assert want == got
        assert want['MICR'] == got['MICR']
        assert want['BRANCH'] == got['BRANCH']
        assert want['ADDRESS'] == got['ADDRESS']
        assert want['STATE'] == got['STATE']
        assert want['CONTACT'] == got['CONTACT']
        assert want['UPI'] == got['UPI']
        assert want['RTGS'] == got['RTGS']
        assert want['CITY'] == got['CITY']
        assert want['CENTRE'] == got['CENTRE']
        assert want['DISTRICT'] == got['DISTRICT']
        assert want['NEFT'] == got['NEFT']
        assert want['IMPS'] == got['IMPS']
        assert want['SWIFT'] == got['SWIFT']
        assert want['BANK'] == got['BANK']
        assert want['BANKCODE'] == got['BANKCODE']
        assert want['IFSC'] == got['IFSC']

    @patch("ifsc.ifsc.requests")
    def test_get_details_not_found(self, mock_requests):
        mock_response = MagicMock()
        mock_response.status_code = 404
        mock_requests.get.return_value = mock_response
        with pytest.raises(ValueError) as exc_info:
            self.ifsc.get_details("HDFC0CAGSBK")
        assert exc_info.value.args[0] == "Invalid IFSC code"

    @patch("ifsc.ifsc.requests")
    def test_get_details_server_error(self, mock_requests):
        mock_response = MagicMock()
        mock_response.status_code = 429
        mock_requests.get.return_value = mock_response
        ifsc_code = "HDFC0CAGSBK"
        with pytest.raises(ValueError) as exc_info:
            self.ifsc.get_details(ifsc_code)
        assert (
            exc_info.value.args[0] == "IFSC API returned an invalid response"
        )
