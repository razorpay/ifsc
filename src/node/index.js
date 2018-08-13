var fs = require("fs");
var data = require("../IFSC");
var https=require('https');
var request=require('request');


var _validate = function(code) {
    if (code.length !== 11) {
        return false;
    }

    if (code[4] !== "0") {
        return false;
    }

    var bankCode = code.slice(0, 4).toUpperCase();
    var branchCode = code.slice(5).toUpperCase();

    if (!data.hasOwnProperty(bankCode)) {
        return false;
    }

    var list = data[bankCode];

    if (isInteger(branchCode)) {
        return lookupNumeric(list, branchCode);
    } else {
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

    return false;
};

var lookupString = function(list, code) {
    return list.indexOf(code) !== -1;
};

var _fetchDetails = function(code) {


    var k='https://ifsc.razorpay.com/'+code;
var ret='';
if(code==='')
{
    ret="EMPTY ";
}
else {
    var req = https.get(k, function (res) {
        var data = '';

        res.on('data', function (chunk) {
            data += chunk;
        });

        res.on('end', function () {

            var response = JSON.parse(data);
            console.log(response);
            ret = response;
        });

    });
}
return ret
};

module.exports = {
    validate: _validate,
    fetchDetails: _fetchDetails
};
