// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Audit log entry for a repo.config.enable_anonymous_git_access event.
public final class RepoConfigEnableAnonymousGitAccessAuditEntry: Object {
  override public class var __typename: StaticString { "RepoConfigEnableAnonymousGitAccessAuditEntry" }

  override public class var __implementedInterfaces: [Interface.Type]? { _implementedInterfaces }
  private static let _implementedInterfaces: [Interface.Type]? = [
    AuditEntry.self,
    Node.self,
    OrganizationAuditEntryData.self,
    RepositoryAuditEntryData.self
  ]
}
