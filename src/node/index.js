const data = require('../IFSC');
const https = require('https');
const BANK = require('./bank');

const BASE_URL = 'https://ifsc.razorpay.com/';

let _validate = function(code) {
  if (code.length !== 11) {
    return false;
  }

  if (code[4] !== '0') {
    return false;
  }

  let bankCode = code.slice(0, 4).toUpperCase();
  let branchCode = code.slice(5).toUpperCase();

  if (!data.hasOwnProperty(bankCode)) {
    return false;
  }

  let list = data[bankCode];

  if (isInteger(branchCode)) {
    return lookupNumeric(list, branchCode);
  }

  return lookupString(list, branchCode);
};

let isInteger = function(code) {
  return code.match(/^(\d)+$/);
};

let lookupNumeric = function(list, code) {
  code = parseInt(code, 10);

  if (list.indexOf(code) > -1) {
    return true;
  }

  return false;
};

let lookupString = function(list, code) {
  return list.indexOf(code) !== -1;
};

let _createUrl = function(code) {
  return BASE_URL + code;
};

let _fetchDetails = function(code, cb) {
  let url = _createUrl(code);

  return new Promise(function(resolve, reject) {
    if (!_validate(code)) {
      reject('Invalid IFSC Code');
    } else {
      https
        .get(url, function(res) {
          let body = '';
          res.on('data', function(chunk) {
            body += chunk;
          });
          res.on('end', function() {
            try {
              let data = JSON.parse(body);
              resolve(data);
            } catch (err) {
              reject('API Call failed: ' + err.message);
            }
          });
        })
        .on('error', function(err) {
          reject('API Call failed: ' + (err.message || err.msg || err));
        });
    }
  });
};

module.exports = {
  validate: _validate,
  fetchDetails: _fetchDetails,
  bank: BANK,
};
