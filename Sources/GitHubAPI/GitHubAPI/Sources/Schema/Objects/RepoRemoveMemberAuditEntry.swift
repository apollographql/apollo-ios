// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Audit log entry for a repo.remove_member event.
public final class RepoRemoveMemberAuditEntry: Object {
  override public class var __typename: StaticString { "RepoRemoveMemberAuditEntry" }

  public class var __implementedInterfaces: [Interface.Type]? { _implementedInterfaces }
  private static let _implementedInterfaces: [Interface.Type]? = [
    AuditEntry.self,
    Node.self,
    OrganizationAuditEntryData.self,
    RepositoryAuditEntryData.self
  ]
}
