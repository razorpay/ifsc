package ifsc

import (
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
)

type httpClient interface {
	Get(url string) (resp *http.Response, err error)
}

var client httpClient

func init() {
	client = http.DefaultClient
}

const API_BASE = "https://ifsc.razorpay.com"

type IFSCResponse struct {
	Bank     *string `json:"bank"`
	Branch   *string `json:"branch"`
	Centre   *string `json:"centre"`
	District *string `json:"district"`
	State    *string `json:"state"`
	Address  *string `json:"address"`
	Contact  *string `json:"contact"`
	City     *string `json:"city"`
	IFSC     *string `json:"ifsc"`
	UPI      *bool   `json:"upi"`
	RTGS     *bool   `json:"rtgs"`
	MICR     *string `json:"micr"`
	NEFT     *bool   `json:"neft"`
	SWIFT    *string `json:"swift"`
	IMPS     *bool   `json:"imps"`
	BankCode *string `json:"bank_code"`
}

// LookUP fetches the response from ifsc api for
func LookUP(ifsc string) (*IFSCResponse, error) {
	var responseStruct *IFSCResponse
	resp, err := client.Get(API_BASE + "/" + ifsc)
	if err != nil {
		return nil, err
	}
	status := resp.StatusCode
	if status == http.StatusOK {
		responseBytes, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			return nil, err
		}
		responseMap := make(map[string]interface{})
		err = json.Unmarshal(responseBytes, &responseMap)
		if err != nil {
			return nil, err
		}
		responseStruct = NewIFSCResponse(responseMap)
		responseStruct.setBankCode()

	} else if status == http.StatusNotFound {
		return nil, ErrInvalidCode
	} else {
		return nil, ErrInvalidResponse
	}
	return responseStruct, nil
}
func NewIFSCResponse(input map[string]interface{}) *IFSCResponse {
	response := &IFSCResponse{}

	setVal(input["BANK"], &response.Bank)
	setVal(input["BRANCH"], &response.Branch)
	setVal(input["CENTRE"], &response.Centre)
	setVal(input["DISTRICT"], &response.District)
	setVal(input["STATE"], &response.State)
	setVal(input["ADDRESS"], &response.Address)
	setVal(input["CONTACT"], &response.Contact)
	setVal(input["CITY"], &response.City)
	setVal(input["IFSC"], &response.IFSC)
	setVal(input["UPI"], &response.UPI)
	setVal(input["RTGS"], &response.RTGS)
	setVal(input["MICR"], &response.MICR)
	setVal(input["NEFT"], &response.NEFT)
	setVal(input["SWIFT"], &response.SWIFT)
	setVal(input["IMPS"], &response.IMPS)

	return response
}

func setVal(input interface{}, output interface{}) {
	bytes, err := json.Marshal(input)
	if err != nil {
		log.Printf("error marshalling input. input:%v, error:%v. Setting bytes as null", input, err)
		bytes = []byte(`null`)
	}
	if err = json.Unmarshal(bytes, &output); err != nil {
		log.Printf("error unmarshalling to output. bytes:%v, error:%v. Setting output as nil", string(bytes), err)
		output = nil
	}

}

func (ifsc *IFSCResponse) setBankCode() {
	ifscCode := ifsc.GetBankCode()
	ifsc.BankCode = &ifscCode
}

func (ifsc *IFSCResponse) GetBankCode() string {
	ifscCode := *ifsc.IFSC
	return ifscCode[0:4]
}

func (ifsc *IFSCResponse) GetBankName() string {
	bankName, err := GetBankName(ifsc.GetBankCode())
	if err != nil {
		return ""
	}
	return bankName
}
