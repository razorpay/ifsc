var ifsc = require('./../../src/node/index');

var assert = require('assert');

assert.equal(true, ifsc.validate('JAKA0AALLAH'));
assert.equal(true, ifsc.validate('KARB0000214'));
assert.equal(false, ifsc.validate('KARB0000226'));
assert.equal(false, ifsc.validate('NEMO0000226'));
assert.equal(false, ifsc.validate('KARB1000214'));
assert.equal(false, ifsc.validate('KARBX000214'));
assert.equal(true, ifsc.validate('HPSC0000406'));
assert.equal(false, ifsc.validate('HPSC0000300'));
