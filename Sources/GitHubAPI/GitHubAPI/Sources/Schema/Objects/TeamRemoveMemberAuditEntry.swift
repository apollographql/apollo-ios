// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Audit log entry for a team.remove_member event.
public final class TeamRemoveMemberAuditEntry: Object {
  override public class var __typename: StaticString { "TeamRemoveMemberAuditEntry" }

  override public class var __implementedInterfaces: [Interface.Type]? { _implementedInterfaces }
  private static let _implementedInterfaces: [Interface.Type]? = [
    AuditEntry.self,
    Node.self,
    OrganizationAuditEntryData.self,
    TeamAuditEntryData.self
  ]
}
