// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Audit log entry for a repository_visibility_change.enable event.
public final class RepositoryVisibilityChangeEnableAuditEntry: Object {
  override public class var __typename: StaticString { "RepositoryVisibilityChangeEnableAuditEntry" }

  public class var __implementedInterfaces: [Interface.Type]? { _implementedInterfaces }
  private static let _implementedInterfaces: [Interface.Type]? = [
    AuditEntry.self,
    EnterpriseAuditEntryData.self,
    Node.self,
    OrganizationAuditEntryData.self
  ]
}
