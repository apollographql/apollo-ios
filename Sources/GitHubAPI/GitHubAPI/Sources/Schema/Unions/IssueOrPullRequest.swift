// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Used for return value of Repository.issueOrPullRequest.
public let IssueOrPullRequest = Union(
  name: "IssueOrPullRequest",
  possibleTypes: [
   GitHubAPI.Issue.self,
   GitHubAPI.PullRequest.self
 ]
)