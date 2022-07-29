// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Audit log entry for a org.oauth_app_access_approved event.
public final class OrgOauthAppAccessApprovedAuditEntry: Object {
  override public class var __typename: StaticString { "OrgOauthAppAccessApprovedAuditEntry" }

  public class var __implementedInterfaces: [Interface.Type]? { _implementedInterfaces }
  private static let _implementedInterfaces: [Interface.Type]? = [
    AuditEntry.self,
    Node.self,
    OauthApplicationAuditEntryData.self,
    OrganizationAuditEntryData.self
  ]
}
