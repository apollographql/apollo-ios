// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Audit log entry for a team.change_parent_team event.
public final class TeamChangeParentTeamAuditEntry: Object {
  override public class var __typename: StaticString { "TeamChangeParentTeamAuditEntry" }

  public class var __implementedInterfaces: [Interface.Type]? { _implementedInterfaces }
  private static let _implementedInterfaces: [Interface.Type]? = [
    AuditEntry.self,
    Node.self,
    OrganizationAuditEntryData.self,
    TeamAuditEntryData.self
  ]
}
