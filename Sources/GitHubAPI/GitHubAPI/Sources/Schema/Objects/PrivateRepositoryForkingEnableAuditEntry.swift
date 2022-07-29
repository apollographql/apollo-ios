// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Audit log entry for a private_repository_forking.enable event.
public final class PrivateRepositoryForkingEnableAuditEntry: Object {
  override public class var __typename: StaticString { "PrivateRepositoryForkingEnableAuditEntry" }

  public class var __implementedInterfaces: [Interface.Type]? { _implementedInterfaces }
  private static let _implementedInterfaces: [Interface.Type]? = [
    AuditEntry.self,
    EnterpriseAuditEntryData.self,
    Node.self,
    OrganizationAuditEntryData.self,
    RepositoryAuditEntryData.self
  ]
}
