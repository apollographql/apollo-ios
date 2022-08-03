// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Unions {
  /// Used for return value of Repository.issueOrPullRequest.
  static let IssueOrPullRequest = Union(
    name: "IssueOrPullRequest",
    possibleTypes: [
     Objects.Issue.self,
     Objects.PullRequest.self
   ]
  )
}