'use strict';

var git = require('../');
var otherDir = '';

console.log('git.short() => ' + git.short());
console.log('git.long() => ' + git.long());
console.log('git.branch() => ' + git.branch());
console.log('git.message() => ' + git.message());
console.log('git.tag() => ' + git.tag());
console.log('git.tag(true) => ' + git.tag(true));
console.log('git.count() => ' + git.count());

if (otherDir) {
  console.log('git.short(' + otherDir + ') => ' + git.short(otherDir));
  console.log('git.long(' + otherDir + ') => ' + git.long(otherDir));
  console.log('git.branch(' + otherDir + ') => ' + git.branch(otherDir));
}
