// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Audit log entry for a repo.config.lock_anonymous_git_access event.
public final class RepoConfigLockAnonymousGitAccessAuditEntry: Object {
  override public class var __typename: StaticString { "RepoConfigLockAnonymousGitAccessAuditEntry" }

  override public class var __implementedInterfaces: [Interface.Type]? { _implementedInterfaces }
  private static let _implementedInterfaces: [Interface.Type]? = [
    AuditEntry.self,
    Node.self,
    OrganizationAuditEntryData.self,
    RepositoryAuditEntryData.self
  ]
}
