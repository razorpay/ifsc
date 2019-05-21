const ifsc = require("../../src/node");
const assert = require("assert");

ifsc
  .fetchDetails("KKBK0000261")
  .then(function(res) {
    assert.deepEqual(
      {
        ADDRESS:
          "JMD REGENT SQUARE,MEHRAULI GURGAON ROAD,OPPOSITE BRISTOL HOTEL,",
        BANK: "Kotak Mahindra Bank",
        BANKCODE: "KKBK",
        BRANCH: "GURGAON",
        CENTRE: "GURGAON",
        CITY: "GURGAON",
        CONTACT: "4131000",
        DISTRICT: "GURGAON",
        IFSC: "KKBK0000261",
        IMPS: true,
        MICR: "",
        NEFT: true,
        RTGS: true,
        STATE: "HARYANA"
      },

      res
    );
  })
  .catch(function(err) {
    console.log(err);
  });
