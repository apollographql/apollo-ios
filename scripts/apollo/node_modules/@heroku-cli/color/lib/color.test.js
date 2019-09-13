"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
jest.mock('util');
const util = require('util');
util.deprecate.mockImplementation((fn) => (...args) => fn(...args));
const color_1 = require("./color");
beforeEach(() => {
    color_1.default.enabled = true;
});
afterEach(() => {
    color_1.default.enabled = false;
});
test('enabled', () => {
    expect(color_1.default.red('foo')).toEqual('\u001b[31mfoo\u001b[39m');
    expect(color_1.default.attachment('foo')).toEqual('\u001b[36mfoo\u001b[39m');
});
test('disabled', () => {
    color_1.default.enabled = false;
    expect(color_1.default.red('foo')).toEqual('foo');
    expect(color_1.default.attachment('foo')).toEqual('foo');
});
test('app', () => {
    expect(color_1.default.app('foo')).toEqual('\u001b[38;5;104m⬢ foo\u001b[0m');
    color_1.default.enabled = false;
    expect(color_1.default.app('foo')).toEqual('foo');
});
test('cannot set things', () => {
    expect(() => (color_1.default.foo = 'bar')).toThrowError(/cannot set property foo/);
});
test('stripColor', () => {
    expect(color_1.default.stripColor(color_1.default.red('foo'))).toEqual('foo');
    expect(util.deprecate).toBeCalled();
});
