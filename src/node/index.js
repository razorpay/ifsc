const fs = require('fs');
const data = require('../IFSC');
const https = require('https');
const request = require('request');

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
  } else {
    return lookupString(list, branchCode);
  }
};

let isInteger = function(code) {
  if (isNaN(parseInt(code, 10))) {
    return false;
  }

  return true;
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
      request.get({ url: url, json: true }, function(err, res, data) {
        if (err) {
          reject('API Call failed: ' + err.msg);
        } else {
          resolve(data);
        }
      });
    }
  });
};

module.exports = {
  validate: _validate,
  fetchDetails: _fetchDetails,
};
