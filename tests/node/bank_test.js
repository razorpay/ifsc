const BANK = require('./../../src/node/bank');
const IFSC = require('./../../src/node/index');
const assert = require('assert');

const fs = require('fs');

assert.equal(BANK.PUNB, 'PUNB');

// Validates that all constants defined in PHP are also defined in Node
let valid_bank_keys = Object.keys(JSON.parse(fs
  .readFileSync('src/banknames.json')))

valid_bank_keys.forEach(code => {
  assert.equal(BANK[code], code);
  assert.equal(IFSC.bank[code], code);
});
