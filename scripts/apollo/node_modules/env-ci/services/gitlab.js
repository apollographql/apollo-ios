// https://docs.gitlab.com/ce/ci/variables/README.html

module.exports = {
	detect({env}) {
		return Boolean(env.GITLAB_CI);
	},
	configuration({env}) {
		return {
			name: 'GitLab CI/CD',
			service: 'gitlab',
			commit: env.CI_COMMIT_SHA,
			tag: env.CI_COMMIT_TAG,
			build: env.CI_PIPELINE_ID,
			buildUrl: `${env.CI_PROJECT_URL}/pipelines/${env.CI_PIPELINE_ID}`,
			job: env.CI_JOB_ID,
			jobUrl: `${env.CI_PROJECT_URL}/-/jobs/${env.CI_JOB_ID}`,
			branch: env.CI_COMMIT_REF_NAME,
			slug: env.CI_PROJECT_PATH,
			root: env.CI_PROJECT_DIR,
		};
	},
};
