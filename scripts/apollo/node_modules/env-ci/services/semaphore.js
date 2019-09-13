const {head} = require('../lib/git');

// https://semaphoreci.com/docs/available-environment-variables.html

module.exports = {
	detect({env}) {
		return Boolean(env.SEMAPHORE);
	},
	configuration({env, cwd}) {
		const pr = env.PULL_REQUEST_NUMBER;
		const isPr = Boolean(pr);

		return {
			name: 'Semaphore',
			service: 'semaphore',
			commit: head({env, cwd}),
			build: env.SEMAPHORE_BUILD_NUMBER,
			branch: isPr ? undefined : env.BRANCH_NAME,
			pr,
			isPr,
			prBranch: isPr ? env.BRANCH_NAME : undefined,
			slug: env.SEMAPHORE_REPO_SLUG,
			root: env.SEMAPHORE_PROJECT_DIR,
		};
	},
};
