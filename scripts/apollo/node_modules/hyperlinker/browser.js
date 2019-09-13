'use strict';
module.exports = function () {
	throw new Error('Hyperlinker is not supported in the browser. Use the `supports-hyperlinks` module to avoid calling it');
};
