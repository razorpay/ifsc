var ifsc = require("./../../src/node/index");
var assertions = require("../validator_asserts.json");

var assert = require("assert");

for (var testLabel in assertions) {
  var group = assertions[testLabel];
  assertGroup(testLabel, group);
}

function assertGroup(message, group) {
  for (var code in group) {
    assert.equal(group[code], ifsc.validate(code), message);
  }
}
