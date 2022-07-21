// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Used for return value of Repository.issueOrPullRequest.
public enum IssueOrPullRequest: Union {
  public static let possibleTypes: [Object.Type] = [
    GitHubAPI.Issue.self,
    GitHubAPI.PullRequest.self
  ]
}
