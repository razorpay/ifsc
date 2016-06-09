"use strict";

var frak = require('frakjs');
var yaml = require('js-yaml');
var fs   = require('fs');

var listOfFiles = fs.readdirSync('./data/by-bank');

var data = {};

for(var i in listOfFiles) {
  var name = listOfFiles[i];
  var bankData = JSON.parse(fs.readFileSync('./data/by-bank/'+name));
  var listOfIFSCCodes = Object.keys(bankData);
  var bankName = name.substr(0,4);
  console.log(bankName);
  data[bankName] = frak.pattern(listOfIFSCCodes).toString();
}

fs.writeFileSync('./data/regex.json', JSON.stringify(data));