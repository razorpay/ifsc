package ifsc

import (
	"fmt"
	"log"
)

type Bank struct {
	Name      string `json:"name"`
	BankCode  string `json:"bank_code"`
	Code      string `json:"code"`
	Type      string `json:"type"`
	IFSC      string `json:"ifsc"`
	MICR      string `json:"micr"`
	IIN       string `json:"iin"`
	APBS      bool   `json:"apbs"`
	AchCredit bool   `json:"ach_credit"`
	AchDebit  bool   `json:"ach_debit"`
	NachDebit bool   `json:"nach_debit"`
	Upi       bool   `json:"upi",omitempty`
}

var bankData map[string]Bank

func LoadBankData() {
	if bankData == nil {
		if err := LoadFile("banks.json", &bankData, ""); err != nil {
			log.Panic(fmt.Sprintf("there is some error in banknames.json file: %v", err))
		}
	}
}

func GetBankDetails(bankCode string) *Bank {
	data, ok := bankData[bankCode]
	if !ok {
		return nil
	}
	var err error
	data.Name, err = GetBankName(bankCode)
	if err != nil {
		return nil
	}
	if data.MICR != "" {
		data.BankCode = data.MICR[3:6]
	}
	return &data
}
