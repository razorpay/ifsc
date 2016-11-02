var fs = require('fs');
var data = require('./../php/codes.json');

var _validate = function(code) {
	if (code.length !== 11) {
		return false;
	}

	if (code[4] !== '0') {
		return false;
	}

	var bankCode   = code.slice(0,4).toUpperCase();
    var branchCode = code.slice(5).toUpperCase();

    if (!data.hasOwnProperty(bankCode)) {
    	return false;
    }

    var list = data[bankCode];

    if (isInteger(branchCode)) {
    	return lookupNumeric(list, branchCode);
    }
    else {
    	return lookupString(list, branchCode);
    }
};

var isInteger = function(code) {
	if (isNaN(parseInt(code, 10))) {
		return false;
	}

	return true;
};

var lookupNumeric = function(list, code) {
	code = parseInt(code, 10);

	if (list.indexOf(code) > -1) {
		return true;
	}

	return lookupRanges(list, code);
};

var lookupRanges = function(list, code) {
	for(var i in list) {
		if (!Array.isArray(list[i])) {
			continue;
		}

		var start = list[i][0];
		var end = list[i][1];

		if (code >= start && code <= end) {
			return true;
		}
	}

	return false;
};

var lookupString = function(list, code) {
	return (list.indexOf(code) !== -1);
};

module.exports = {
	validate: _validate
};