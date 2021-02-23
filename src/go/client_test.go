package ifsc

import (
	"bytes"
	"encoding/json"
	"errors"
	"io/ioutil"
	"net/http"
	"testing"

	"github.com/gyanesh-m/ifsc/src/go/mocks"
	"github.com/stretchr/testify/assert"
)

func getIfscResponse() *IFSCResponse {
	bytes := []byte(`{"bank": "Kotak Mahindra Bank",
	"branch": "GURGAON",
	"center": "GURGAON",
	"district": "GURGAON",
	"state": "HARYANA",
	"address": "JMD REGENT SQUARE,MEHRAULI GURGAON ROAD,OPPOSITE BRISTOL HOTEL,",
	"contact": "4131000",
	"city": null,
	"ifsc": "KKBK0000261",
	"upi": true,
	"rtgs": true,
	"micr": "110485003",
	"neft": null,
	"swift": "",
	"imps": true,
	"bank_code": "KKBK"}`)
	var response IFSCResponse
	if err := json.Unmarshal(bytes, &response); err != nil {
		return nil
	}
	return &response
}
func TestLookUP(t *testing.T) {
	client = &mocks.Client{}
	type args struct {
		ifsc string
	}
	tests := []struct {
		name         string
		args         args
		IfscResponse *IFSCResponse
		mockedClient func()
		wantErr      bool
		err          error
	}{
		{
			"success",
			args{"KKBK0000261"},
			getIfscResponse(),
			GetSuccessMockResponse,
			false,
			nil,
		},
		{
			"failure, invalid code",
			args{"KKB0000abc1"},
			nil,
			GetInvalidCodeMockResponse,
			true,
			ErrInvalidCode,
		},
		{
			"failure, invalid Response",
			args{"AIRP0000001"},
			nil,
			GetFailureMockResponse,
			true,
			ErrInvalidResponse,
		},
		{
			"timeout error",
			args{"abcd"},
			nil,
			GetUrlError,
			true,
			http.ErrHandlerTimeout,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var err error
			var got *IFSCResponse
			tt.mockedClient()
			got, err = LookUP(tt.args.ifsc)
			if (err != nil) != tt.wantErr {
				t.Errorf("LookUP() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if tt.wantErr {
				if !errors.Is(tt.err, err) {
					t.Errorf("error is not equal. want()=%v, got()=%v", tt.err, err)
				}
			} else {
				assert.Equal(t, tt.IfscResponse.Bank, got.Bank)
				assert.Equal(t, tt.IfscResponse.Branch, got.Branch)
				assert.Equal(t, tt.IfscResponse.Centre, got.Centre)
				assert.Equal(t, tt.IfscResponse.District, got.District)
				assert.Equal(t, tt.IfscResponse.State, got.State)
				assert.Equal(t, tt.IfscResponse.Address, got.Address)
				assert.Equal(t, tt.IfscResponse.Contact, got.Contact)
				assert.Equal(t, tt.IfscResponse.City, got.City)
				assert.Equal(t, tt.IfscResponse.IFSC, got.IFSC)
				assert.Equal(t, tt.IfscResponse.UPI, got.UPI)
				assert.Equal(t, tt.IfscResponse.RTGS, got.RTGS)
				assert.Equal(t, tt.IfscResponse.MICR, got.MICR)
				assert.Equal(t, tt.IfscResponse.NEFT, got.NEFT)
				assert.Equal(t, tt.IfscResponse.SWIFT, got.SWIFT)
				assert.Equal(t, tt.IfscResponse.IMPS, got.IMPS)
				assert.Equal(t, tt.IfscResponse.BankCode, got.BankCode)
			}
		})
	}
}
func GetFailureMockResponse() {
	mocks.GetFuncVar = func(url string) (resp *http.Response, err error) {
		return &http.Response{
			StatusCode: http.StatusInternalServerError,
		}, nil
	}

}
func GetInvalidCodeMockResponse() {
	mocks.GetFuncVar = func(url string) (resp *http.Response, err error) {
		return &http.Response{
			StatusCode: http.StatusNotFound,
		}, nil
	}

}

func GetUrlError() {
	mocks.GetFuncVar = func(url string) (resp *http.Response, err error) {
		return nil, http.ErrHandlerTimeout
	}
}

func GetSuccessMockResponse() {
	mocks.GetFuncVar = func(url string) (resp *http.Response, err error) {
		var successJson = `{
			"BRANCH": "GURGAON",
			"CENTRE": "GURGAON",
			"DISTRICT": "GURGAON",
			"STATE": "HARYANA",
			"ADDRESS": "JMD REGENT SQUARE,MEHRAULI GURGAON ROAD,OPPOSITE BRISTOL HOTEL,",
			"CONTACT": "4131000",
			"UPI": true,
			"RTGS": true,
			"CITY": null,
			"MICR": "110485003",
			"NEFT": null,
			"IMPS": true,
			"SWIFT": "",
			"BANK": "Kotak Mahindra Bank",
			"BANKCODE": "KKBK",
			"IFSC": "KKBK0000261"
		}`
		r := ioutil.NopCloser(bytes.NewReader([]byte(successJson)))
		return &http.Response{
			StatusCode: http.StatusOK,
			Body:       r,
		}, nil
	}

}

func TestIFSCResponse_GetBankName(t *testing.T) {
	type fields struct {
		Bank     string
		Branch   string
		Address  string
		Contact  string
		City     string
		District string
		State    string
		BankCode string
		IFSC     string
	}
	tests := []struct {
		name   string
		fields fields
		want   string
	}{
		{
			"success",
			fields{
				IFSC: "HDFC0CADARS",
			},
			"HDFC Bank",
		},
		{
			"failure",
			fields{
				IFSC: "12 B",
			},
			"",
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			expected := &IFSCResponse{
				Bank:     &tt.fields.Bank,
				Branch:   &tt.fields.Branch,
				Address:  &tt.fields.Address,
				Contact:  &tt.fields.Contact,
				City:     &tt.fields.City,
				District: &tt.fields.District,
				State:    &tt.fields.State,
				BankCode: &tt.fields.BankCode,
				IFSC:     &tt.fields.IFSC,
			}
			if got := expected.GetBankName(); got != tt.want {
				t.Errorf("IFSCResponse.GetBankName() = %v, want %v", got, tt.want)
			}
		})
	}
}
