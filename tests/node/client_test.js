const ifsc = require('./../../src/node/index');
const assert = require('assert');

ifsc
  .fetchDetails('KKBK0000261')
  .then(function(res) {
    assert.deepEqual(
      {
        BRANCH: 'GURGAON',
        ADDRESS:
          'JMD REGENT SQUARE,MEHRAULI GURGAON ROAD,OPPOSITE BRISTOL HOTEL,',
        CONTACT: '4131000',
        CITY: 'GURGAON',
        DISTRICT: 'GURGAON',
        STATE: 'HARYANA',
        RTGS: true,
        BANK: 'Kotak Mahindra Bank',
        BANKCODE: 'KKBK',
        IFSC: 'KKBK0000261',
      },
      res
    );
  })
  .catch(function(err) {
    console.log(err);
  });
