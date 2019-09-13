// https://buildkite.com/docs/builds/environment-variables

module.exports = {
	detect({env}) {
		return Boolean(env.BUILDKITE);
	},
	configuration({env}) {
		const pr = env.BUILDKITE_PULL_REQUEST === 'false' ? undefined : env.BUILDKITE_PULL_REQUEST;
		const isPr = Boolean(pr);

		return {
			name: 'Buildkite',
			service: 'buildkite',
			build: env.BUILDKITE_BUILD_NUMBER,
			buildUrl: env.BUILDKITE_BUILD_URL,
			commit: env.BUILDKITE_COMMIT,
			tag: env.BUILDKITE_TAG,
			branch: isPr ? env.BUILDKITE_PULL_REQUEST_BASE_BRANCH : env.BUILDKITE_BRANCH,
			slug: `${env.BUILDKITE_ORGANIZATION_SLUG}/${env.BUILDKITE_PROJECT_SLUG}`,
			pr,
			isPr,
			prBranch: isPr ? env.BUILDKITE_BRANCH : undefined,
			root: env.BUILDKITE_BUILD_CHECKOUT_PATH,
		};
	},
};
