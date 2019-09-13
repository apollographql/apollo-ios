const {head, branch} = require('../lib/git');

module.exports = {
	configuration(options) {
		return {commit: head(options), branch: branch(options)};
	},
};
