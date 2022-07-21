// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Audit log entry for a repo.destroy event.
public final class RepoDestroyAuditEntry: Object {
  override public class var __typename: StaticString { "RepoDestroyAuditEntry" }

  override public class var __implementedInterfaces: [Interface.Type]? { _implementedInterfaces }
  private static let _implementedInterfaces: [Interface.Type]? = [
    AuditEntry.self,
    Node.self,
    OrganizationAuditEntryData.self,
    RepositoryAuditEntryData.self
  ]
}
