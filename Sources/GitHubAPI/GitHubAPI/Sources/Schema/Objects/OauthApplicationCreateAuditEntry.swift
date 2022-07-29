// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Audit log entry for a oauth_application.create event.
public final class OauthApplicationCreateAuditEntry: Object {
  override public class var __typename: StaticString { "OauthApplicationCreateAuditEntry" }

  public class var __implementedInterfaces: [Interface.Type]? { _implementedInterfaces }
  private static let _implementedInterfaces: [Interface.Type]? = [
    AuditEntry.self,
    Node.self,
    OauthApplicationAuditEntryData.self,
    OrganizationAuditEntryData.self
  ]
}
