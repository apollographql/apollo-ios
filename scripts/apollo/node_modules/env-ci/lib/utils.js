function prNumber(pr) {
	return (/\d+(?!.*\d+)/.exec(pr) || [])[0];
}

module.exports = {prNumber};
