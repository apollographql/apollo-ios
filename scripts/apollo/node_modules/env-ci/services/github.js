// https://developer.github.com/actions/creating-github-actions/accessing-the-runtime-environment/#environment-variables

const parseBranch = branch => (/refs\/heads\/(.*)/i.exec(branch) || [])[1];

const getPrEvent = ({env}) => {
	try {
		const event = env.GITHUB_EVENT_PATH ? require(env.GITHUB_EVENT_PATH) : undefined;

		if (event && event.pull_request) {
			return {
				branch: event.pull_request.base ? parseBranch(event.pull_request.base.ref) : undefined,
				pr: event.pull_request.number,
			};
		}
	} catch (error) {
		// Noop
	}

	return {pr: undefined, branch: undefined};
};

module.exports = {
	detect({env}) {
		return Boolean(env.GITHUB_ACTION);
	},
	configuration({env, cwd}) {
		const isPr = env.GITHUB_EVENT_NAME === 'pull_request';
		const branch = parseBranch(env.GITHUB_REF);

		return Object.assign(
			{
				name: 'GitHub Actions',
				service: 'github',
				commit: env.GITHUB_SHA,
				isPr,
				branch,
				prBranch: isPr ? branch : undefined,
				slug: env.GITHUB_REPOSITORY,
				root: env.GITHUB_WORKSPACE,
			},
			isPr ? getPrEvent({env, cwd}) : undefined
		);
	},
};
