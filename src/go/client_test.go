package ifsc

import (
	"reflect"
	"testing"
)

func getTestDataFixture() IFSCResponse {
	return IFSCResponse{
		Bank:     "Kotak Mahindra Bank",
		Branch:   "GURGAON",
		Address:  "JMD REGENT SQUARE,MEHRAULI GURGAON ROAD,OPPOSITE BRISTOL HOTEL,",
		Contact:  "4131000",
		City:     "GURGAON",
		District: "GURGAON",
		State:    "HARYANA",
		IFSC:     "KKBK0000261",
		BankCode: "KKBK",
	}
}

func TestLookUP(t *testing.T) {
	type args struct {
		ifsc string
	}
	ifscResp := getTestDataFixture()
	tests := []struct {
		name    string
		args    args
		want    *IFSCResponse
		wantErr bool
	}{
		{
			"success",
			args{"KKBK0000261"},
			&ifscResp,
			false,
		},
		{
			"failure",
			args{"KKB0000201"},
			nil,
			true,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := LookUP(tt.args.ifsc)
			if (err != nil) != tt.wantErr {
				t.Errorf("LookUP() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !reflect.DeepEqual(got, tt.want) {
				t.Errorf("LookUP() = %v, want %v", got, tt.want)
			}
		})
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
			ifsc := &IFSCResponse{
				Bank:     tt.fields.Bank,
				Branch:   tt.fields.Branch,
				Address:  tt.fields.Address,
				Contact:  tt.fields.Contact,
				City:     tt.fields.City,
				District: tt.fields.District,
				State:    tt.fields.State,
				BankCode: tt.fields.BankCode,
				IFSC:     tt.fields.IFSC,
			}
			if got := ifsc.GetBankName(); got != tt.want {
				t.Errorf("IFSCResponse.GetBankName() = %v, want %v", got, tt.want)
			}
		})
	}
}
