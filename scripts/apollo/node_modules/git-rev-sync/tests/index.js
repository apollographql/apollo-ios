var assert = require('assert');
var git = require('../index');

var result;

result = git.short();
assert.equal(result.length > 3, true, 'short() returns string of length 4+');

result = git.short(null, 8);
assert.equal(result.length === 8, true, 'short() returns string of length 4+');

result = git.long();
assert.equal(result.length > 38, true, 'long() returns string of length 39+');

result = git.branch();
assert.equal(!!result.length, true, 'branch() returns a string with non-zero length');

result = git.count();
assert.notEqual(result, 0, 'count() returns a non-zero number');
assert.equal(Math.abs(result), result, 'count() returns a positive number');

result = git.date();
assert.equal(result instanceof Date, true, 'date() returns a date');

result = git.isDirty();
assert.equal(typeof result, 'boolean', 'isDirty() returns a boolean');

result = git.isTagDirty();
assert.equal(typeof result, 'boolean', 'isTagDirty() returns a boolean');

result = git.message();
assert.equal(!!result.length, true, 'message() returns a string with non-zero length');

result = git.tag();
assert.equal(!!result.length, true, 'tag() returns a string with non-zero length');

result = git.tagFirstParent();
assert.equal(result.length !== 0, true, 'tagFirstParent() returns a string with non-zero length');

result = git.remoteUrl();
assert.equal(result.indexOf("https://github.com") === 0 || result.indexOf("git@github.com") === 0, true, "remoteUrl() returns unexpected value: '" + result + "'");

console.log('tests passed');
