var fs = require("fs");
var data = require("../IFSC");

var csv=require('fast-csv');
var main=[];
var stream=fs.createReadStream("IFSC.csv");

csv
    .fromStream(stream, {headers : true})
    .on("data", function(data){
        main[data.IFSC]=data
    })
    .on("end", function(){
        console.log("done");
    });




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
    return(main[code]);
};

module.exports = {
    validate: _validate,
    fetchDetails: _fetchDetails
};