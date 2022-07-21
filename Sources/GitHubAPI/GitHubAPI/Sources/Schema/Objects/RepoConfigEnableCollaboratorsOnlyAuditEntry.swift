// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Audit log entry for a repo.config.enable_collaborators_only event.
public final class RepoConfigEnableCollaboratorsOnlyAuditEntry: Object {
  override public class var __typename: StaticString { "RepoConfigEnableCollaboratorsOnlyAuditEntry" }

  override public class var __implementedInterfaces: [Interface.Type]? { _implementedInterfaces }
  private static let _implementedInterfaces: [Interface.Type]? = [
    AuditEntry.self,
    Node.self,
    OrganizationAuditEntryData.self,
    RepositoryAuditEntryData.self
  ]
}
