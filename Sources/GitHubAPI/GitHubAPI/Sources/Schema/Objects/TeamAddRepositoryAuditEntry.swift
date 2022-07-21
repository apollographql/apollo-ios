// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Audit log entry for a team.add_repository event.
public final class TeamAddRepositoryAuditEntry: Object {
  override public class var __typename: StaticString { "TeamAddRepositoryAuditEntry" }

  override public class var __implementedInterfaces: [Interface.Type]? { _implementedInterfaces }
  private static let _implementedInterfaces: [Interface.Type]? = [
    AuditEntry.self,
    Node.self,
    OrganizationAuditEntryData.self,
    RepositoryAuditEntryData.self,
    TeamAuditEntryData.self
  ]
}
