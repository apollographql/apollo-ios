// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Objects {
  /// Audit log entry for a repo.remove_topic event.
  static let RepoRemoveTopicAuditEntry = Object(
    typename: "RepoRemoveTopicAuditEntry",
    implementedInterfaces: [
      Interfaces.AuditEntry.self,
      Interfaces.Node.self,
      Interfaces.OrganizationAuditEntryData.self,
      Interfaces.RepositoryAuditEntryData.self,
      Interfaces.TopicAuditEntryData.self
    ]
  )
}