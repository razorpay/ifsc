const fs = require('fs');
const data = require('../IFSC');
const bankNames = require('../banknames.json');
const sublets = require('../sublet.json');
const customSublets = require('../custom-sublets.json');
const customSubletPrefixes = Object.keys(customSublets);
const https = require('https');
const request = require('request');
const BANK = require('./bank');

const BASE_URL = 'https://ifsc.razorpay.com/';

let _validate = function(code) {
  if (!code || typeof code !== 'string' || code.length !== 11) {
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

let _validateBankCode = function(bankCode) {
  if (!bankCode || typeof bankCode !== 'string') {
    return false;
  }
  bankCode = bankCode.toUpperCase();
  return BANK.hasOwnProperty(bankCode) || bankNames.hasOwnProperty(bankCode);
};

let _getCustomSubletName = function(code) {
  for (let i = 0; i < customSubletPrefixes.length; i++) {
    let prefix = customSubletPrefixes[i];
    if (code.startsWith(prefix)) {
      let value = customSublets[prefix];
      if (value.length === 4) {
        return _getBankName(value);
      } else {
        return value;
      }
    }
  }
  return null;
};

let _getBankName = function(code) {
  if (!code || typeof code !== 'string') {
    return null;
  }
  code = code.toUpperCase();

  if (_validateBankCode(code)) {
    return bankNames[code] || null;
  }

  if (_validate(code)) {
    if (sublets.hasOwnProperty(code)) {
      let bankCode = sublets[code];
      return bankNames[bankCode] || null;
    }

    let customSubletName = _getCustomSubletName(code);
    if (customSubletName) {
      return customSubletName;
    }

    let ownerBankCode = code.slice(0, 4);
    return bankNames[ownerBankCode] || null;
  }

  return null;
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
  validateBankCode: _validateBankCode,
  getBankName: _getBankName,
  fetchDetails: _fetchDetails,
  bank: BANK,
};
