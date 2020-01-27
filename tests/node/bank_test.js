const BANK = require('./../../src/node/bank');
const IFSC = require('./../../src/node/index');
const assert = require('assert');

const fs = require('fs');

assert.equal(BANK.PUNB, 'PUNB');

// Validates that all constants defined in PHP are also defined in Node
let file = fs
	.readFileSync('src/php/Bank.php')
	.toString()
	.split('\n')
	.filter(l => {
		return l.indexOf('const') > -1;
	})
	.map(l => {
		return l.match(/\s+const (\w{4})/)[1];
	})
	.forEach(code => {
		assert.equal(BANK[code], code);
		assert.equal(IFSC.bank[code], code);
	});
