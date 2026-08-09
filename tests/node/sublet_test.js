const ifsc = require('../../src/node');
const assert = require('assert');

// 1. Basic bank name lookup by 4-letter bank code
assert.equal(ifsc.getBankName('PUNB'), 'Punjab National Bank');
assert.equal(ifsc.getBankName(ifsc.bank.PUNB), 'Punjab National Bank');

// 2. Bank name lookup by regular IFSC code
assert.equal(ifsc.getBankName('KKBK0000261'), 'Kotak Mahindra Bank');

// 3. Sublet lookup by IFSC code
assert.equal(ifsc.getBankName('WBSC0DJCB01'), 'Darjeeling District Central Co-operative Bank');
assert.equal(ifsc.getBankName('XNSE0000001'), 'NSE Clearing Limited');

// 4. Custom sublets lookup by prefix
assert.equal(ifsc.getBankName('KSCB0006001'), 'Tumkur District Central Bank');
assert.equal(ifsc.getBankName('WBSC0KPCB01'), 'Kolkata Police Co-operative Bank');
assert.equal(ifsc.getBankName('YESB0ADB002'), 'Amravati District Central Co-operative Bank');

// 5. Invalid bank code / IFSC handling
assert.equal(ifsc.getBankName('ABCD'), null);
assert.equal(ifsc.getBankName('BOTM0XEEMRA'), null);
assert.equal(ifsc.getBankName(''), null);
assert.equal(ifsc.getBankName(null), null);

// 6. Bank code validation
assert.equal(ifsc.validateBankCode('PUNB'), true);
assert.equal(ifsc.validateBankCode('ABCD'), false);
assert.equal(ifsc.validateBankCode(''), false);
assert.equal(ifsc.validateBankCode(null), false);

console.log('All Node.js sublet tests passed successfully!');
