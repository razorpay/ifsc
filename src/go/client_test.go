package ifsc

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestLookUP_Success(t *testing.T) {

}
func TestLookUP_Failure(t *testing.T) {
	assert := assert.New(t)
	response, err := LookUP("KKBK0000261")
	assert.Nil(err)
	assert.Equal(getTestDataFixture(), *response)

}
func getTestDataFixture() IFSCResponse {
	return IFSCResponse{
		Bank:     "Kotak Mahindra Bank",
		Branch:   "GURGAON",
		Address:  "JMD REGENT SQUARE,MEHRAULI GURGAON ROAD,OPPOSITE BRISTOL HOTEL,",
		Contact:  "4131000",
		City:     "GURGAON",
		District: "GURGAON",
		State:    "HARYANA",
		BankCode: "KKBK",
	}
}
