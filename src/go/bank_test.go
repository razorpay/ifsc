package ifsc

import (
	"testing"
	// TODO: change
	"github.com/stretchr/testify/assert"
)

func Test_BankGetDetails(t *testing.T) {
	assert := assert.New(t)
	result := GetBankDetails("FINO")
	assert.Equal(getFINOfixture(), *result)
	result = GetBankDetails("PUNB")
	assert.Equal(getPUNBFixture(), *result)
}
func getPUNBFixture() Bank {
	return Bank{
		Name:      "Punjab National Bank",
		BankCode:  "024",
		Code:      "PUNB",
		Type:      "PSB",
		IFSC:      "PUNB0244200",
		MICR:      "110024001",
		IIN:       "508568",
		APBS:      true,
		AchCredit: true,
		AchDebit:  true,
		NachDebit: true,
		Upi:       true,
	}
}
func getFINOfixture() Bank {
	return Bank{
		Name:      "Fino Payments Bank",
		BankCode:  "099",
		Code:      "FINO",
		Type:      "PB",
		IFSC:      "FINO0000001",
		MICR:      "990099909",
		IIN:       "608001",
		APBS:      true,
		AchCredit: true,
		AchDebit:  false,
		NachDebit: false,
		Upi:       true,
	}
}
