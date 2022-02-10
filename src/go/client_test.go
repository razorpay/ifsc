package ifsc

import (
	"bytes"
	"encoding/json"
	"errors"
	"io/ioutil"
	"net/http"
	"testing"

	"github.com/razorpay/ifsc/v2/src/go/mocks"
	"github.com/stretchr/testify/assert"
)

func getIfscResponse() *IFSCResponse {
	bytes := []byte(`{"micr":"560226263",
		"branch":"THE AGS EMPLOYEES COOP BANK LTD",
		"address":"SANGMESH BIRADAR BANGALORE",
		"state":"KARNATAKA",
		"contact":"+91802265658",
		"upi":true,
		"rtgs":true,
		"city":"BANGALORE",
		"centre":"BANGALORE URBAN",
		"district":"BANGALORE URBAN",
		"neft":true,"imps":true,
		"swift":"HDFCINBB",
		"bank":"HDFC Bank",
		"bank_code":"HDFC",
		"ifsc":"HDFC0CAGSBK"}`)
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
			args{"HDFC0CAGSBK"},
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
			"MICR":"560226263",
			"BRANCH":"THE AGS EMPLOYEES COOP BANK LTD",
			"ADDRESS":"SANGMESH BIRADAR BANGALORE",
			"STATE":"KARNATAKA",
			"CONTACT":"+91802265658",
			"UPI":true,
			"RTGS":true,
			"CITY":"BANGALORE",
			"CENTRE":"BANGALORE URBAN",
			"DISTRICT":"BANGALORE URBAN",
			"NEFT":true,"IMPS":true,
			"SWIFT":"HDFCINBB",
			"BANK":"HDFC Bank",
			"BANKCODE":"HDFC",
			"IFSC":"HDFC0CAGSBK"
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
