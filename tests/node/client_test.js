const ifsc = require('../../src/node');
const assert = require('assert');

ifsc
  .fetchDetails('KKBK0000261')
  .then(function(res) {
    assert.equal('JMD REGENT SQUARE,MEHRAULI GURGAON ROAD,OPPOSITE BRISTOL HOTEL,',res['ADDRESS'])
    assert.equal('Kotak Mahindra Bank',res['BANK'])
    assert.equal('KKBK',res['BANKCODE'])
    assert.equal('GURGAON',res['BRANCH'])
    assert.equal('GURGAON',res['CENTRE'])
    assert.equal('GURGAON',res['CITY'])
    assert.equal('GURGAON',res['DISTRICT'])
    assert.equal('KKBK0000261',res['IFSC'])
    assert.equal('110485003',res['MICR'])
    assert.equal('HARYANA',res['STATE'])
  })
  .catch(err => {
    console.error(err);
    process.exit(1);
  })
