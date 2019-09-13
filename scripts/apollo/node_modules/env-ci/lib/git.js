const execa = require('execa');

function head(options) {
	try {
		return execa.sync('git', ['rev-parse', 'HEAD'], options).stdout;
	} catch (error) {
		return undefined;
	}
}

function branch(options) {
	try {
		const headRef = execa.sync('git', ['rev-parse', '--abbrev-ref', 'HEAD'], options).stdout;

		if (headRef === 'HEAD') {
			const branch = execa
				.sync('git', ['show', '-s', '--pretty=%d', 'HEAD'], options)
				.stdout.replace(/^\(|\)$/g, '')
				.split(', ')
				.find(branch => branch.startsWith('origin/'));
			return branch ? branch.match(/^origin\/(.+)/)[1] : undefined;
		}

		return headRef;
	} catch (error) {
		return undefined;
	}
}

module.exports = {head, branch};
