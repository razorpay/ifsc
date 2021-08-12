package ifsc

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestGetBankName_BankName(t *testing.T) {
	assert := assert.New(t)
	actual, ierr := GetBankName("WBSC0DJCB01")
	assert.Nil(ierr)
	assert.Equal("Darjeeling District Central Co-operative Bank", actual)
}

func TestGetBankName_Sublet(t *testing.T) {
	assert := assert.New(t)
	fixtureData := getSubletFixture()
	for input, _ := range fixtureData {
		ownerBankCode := input[0:4]
		actual, err := GetBankName(input)
		assert.Nil(err)
		expected, err := GetBankName(ownerBankCode)
		assert.Nil(err)
		assert.Equal(expected, actual)
	}
}
func TestGetBankName_CustomSublet_Success(t *testing.T) {
	assert := assert.New(t)
	fixtureData := getCustomSubletFixture()
	for input, expected := range fixtureData {
		actual, err := GetBankName(input)
		assert.Nil(err)
		assert.Equal(expected, actual)
	}

}

func getCustomSubletFixture() map[string]string {
	return map[string]string{
		"KSCB0006001": "Tumkur District Central Bank",
		"WBSC0KPCB01": "Kolkata Police Co-operative Bank",
		"YESB0ADB002": "Amravati District Central Co-operative Bank",
	}
}

func getSubletFixture() map[string]string {
	return map[string]string{
		"SKUX": "IBKL0116SBK",
		"SPTX": "IBKL0116SSB",
		"VCOX": "IBKL0116VMC",
		"AURX": "IBKL01192AC",
		"NMCX": "IBKL0123NMC",
		"MSSX": "IBKL01241MB",
		"TNCX": "IBKL01248NC",
		"URDX": "IBKL01263UC",
	}
}

func TestValidateBankCode(t *testing.T) {
	type args struct {
		bankCodeInput string
	}
	tests := []struct {
		name string
		args args
		want bool
	}{
		{
			"success",
			args{"ABCX"},
			true,
		},
		{
			"failure",
			args{"Aaaa"},
			false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := ValidateBankCode(tt.args.bankCodeInput); got != tt.want {
				t.Errorf("ValidateBankCode() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestValidate(t *testing.T) {
	var result interface{}
	err := LoadFile("validator_asserts.json", &result, "../../tests")
	if err != nil {
		t.Fatalf("error: %+v", err)
	}
	type args struct {
		code string
	}
	tests := []struct {
		name string
		args args
		want bool
	}{}
	for key, value := range result.(map[string]interface{}) {
		for inp_key, expected_val := range value.(map[string]interface{}) {
			tests = append(tests, struct {
				name string
				args args
				want bool
			}{key + ":" + inp_key, args{inp_key}, expected_val.(bool)})
		}
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := Validate(tt.args.code); got != tt.want {
				t.Errorf("Validate() = %v, want %v", got, tt.want)
			}
		})
	}
}
