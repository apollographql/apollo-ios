// https://docs.microsoft.com/en-us/vsts/pipelines/build/variables
// The docs indicate that SYSTEM_PULLREQUEST_SOURCEBRANCH and SYSTEM_PULLREQUEST_TARGETBRANCH are in the long format (e.g `refs/heads/master`) however tests show they are both in the short format (e.g. `master`)

module.exports = {
	detect({env}) {
		return Boolean(env.BUILD_BUILDURI);
	},
	configuration({env}) {
		const pr = env.SYSTEM_PULLREQUEST_PULLREQUESTID;
		const isPr = Boolean(pr);

		return {
			name: 'Visual Studio Team Services',
			service: 'vsts',
			commit: env.BUILD_SOURCEVERSION,
			build: env.BUILD_BUILDNUMBER,
			branch: isPr ? env.SYSTEM_PULLREQUEST_TARGETBRANCH : env.BUILD_SOURCEBRANCHNAME,
			pr,
			isPr,
			prBranch: isPr ? env.SYSTEM_PULLREQUEST_SOURCEBRANCH : undefined,
			root: env.BUILD_REPOSITORY_LOCALPATH,
		};
	},
};
