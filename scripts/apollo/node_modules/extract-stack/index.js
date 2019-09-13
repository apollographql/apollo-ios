'use strict';
const reStack = /(?:\n {4}at .*)+/;

module.exports = err => {
	const stack = err instanceof Error ? err.stack : err;

	if (!stack) {
		return '';
	}

	const match = stack.match(reStack);

	if (!match) {
		return '';
	}

	return match[0].slice(1);
};

module.exports.lines = stack => module.exports(stack).replace(/^ {4}at /gm, '').split('\n');
