// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == GitHubAPI.Schema {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == GitHubAPI.Schema {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == GitHubAPI.Schema {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == GitHubAPI.Schema {}

public enum Schema: SchemaConfiguration {
  public static func objectType(forTypename __typename: String) -> Object.Type? {
    switch __typename {
    case "Query": return GitHubAPI.Query.self
    case "Repository": return GitHubAPI.Repository.self
    case "AddedToProjectEvent": return GitHubAPI.AddedToProjectEvent.self
    case "App": return GitHubAPI.App.self
    case "AssignedEvent": return GitHubAPI.AssignedEvent.self
    case "AutomaticBaseChangeFailedEvent": return GitHubAPI.AutomaticBaseChangeFailedEvent.self
    case "AutomaticBaseChangeSucceededEvent": return GitHubAPI.AutomaticBaseChangeSucceededEvent.self
    case "BaseRefChangedEvent": return GitHubAPI.BaseRefChangedEvent.self
    case "BaseRefForcePushedEvent": return GitHubAPI.BaseRefForcePushedEvent.self
    case "Blob": return GitHubAPI.Blob.self
    case "Commit": return GitHubAPI.Commit.self
    case "Issue": return GitHubAPI.Issue.self
    case "PullRequest": return GitHubAPI.PullRequest.self
    case "Milestone": return GitHubAPI.Milestone.self
    case "Bot": return GitHubAPI.Bot.self
    case "EnterpriseUserAccount": return GitHubAPI.EnterpriseUserAccount.self
    case "Mannequin": return GitHubAPI.Mannequin.self
    case "Organization": return GitHubAPI.Organization.self
    case "Team": return GitHubAPI.Team.self
    case "User": return GitHubAPI.User.self
    case "CheckRun": return GitHubAPI.CheckRun.self
    case "ClosedEvent": return GitHubAPI.ClosedEvent.self
    case "ConvertToDraftEvent": return GitHubAPI.ConvertToDraftEvent.self
    case "CrossReferencedEvent": return GitHubAPI.CrossReferencedEvent.self
    case "Gist": return GitHubAPI.Gist.self
    case "Topic": return GitHubAPI.Topic.self
    case "MergedEvent": return GitHubAPI.MergedEvent.self
    case "PullRequestCommit": return GitHubAPI.PullRequestCommit.self
    case "ReadyForReviewEvent": return GitHubAPI.ReadyForReviewEvent.self
    case "Release": return GitHubAPI.Release.self
    case "RepositoryTopic": return GitHubAPI.RepositoryTopic.self
    case "ReviewDismissedEvent": return GitHubAPI.ReviewDismissedEvent.self
    case "TeamDiscussion": return GitHubAPI.TeamDiscussion.self
    case "CommitComment": return GitHubAPI.CommitComment.self
    case "GistComment": return GitHubAPI.GistComment.self
    case "IssueComment": return GitHubAPI.IssueComment.self
    case "PullRequestReview": return GitHubAPI.PullRequestReview.self
    case "CommitCommentThread": return GitHubAPI.CommitCommentThread.self
    case "PullRequestCommitCommentThread": return GitHubAPI.PullRequestCommitCommentThread.self
    case "PullRequestReviewComment": return GitHubAPI.PullRequestReviewComment.self
    case "Project": return GitHubAPI.Project.self
    case "TeamDiscussionComment": return GitHubAPI.TeamDiscussionComment.self
    case "RepositoryVulnerabilityAlert": return GitHubAPI.RepositoryVulnerabilityAlert.self
    case "Tag": return GitHubAPI.Tag.self
    case "Tree": return GitHubAPI.Tree.self
    case "BranchProtectionRule": return GitHubAPI.BranchProtectionRule.self
    case "CheckSuite": return GitHubAPI.CheckSuite.self
    case "CodeOfConduct": return GitHubAPI.CodeOfConduct.self
    case "CommentDeletedEvent": return GitHubAPI.CommentDeletedEvent.self
    case "ConnectedEvent": return GitHubAPI.ConnectedEvent.self
    case "ConvertedNoteToIssueEvent": return GitHubAPI.ConvertedNoteToIssueEvent.self
    case "DemilestonedEvent": return GitHubAPI.DemilestonedEvent.self
    case "DependencyGraphManifest": return GitHubAPI.DependencyGraphManifest.self
    case "DeployKey": return GitHubAPI.DeployKey.self
    case "DeployedEvent": return GitHubAPI.DeployedEvent.self
    case "Deployment": return GitHubAPI.Deployment.self
    case "DeploymentEnvironmentChangedEvent": return GitHubAPI.DeploymentEnvironmentChangedEvent.self
    case "DeploymentStatus": return GitHubAPI.DeploymentStatus.self
    case "DisconnectedEvent": return GitHubAPI.DisconnectedEvent.self
    case "Enterprise": return GitHubAPI.Enterprise.self
    case "EnterpriseAdministratorInvitation": return GitHubAPI.EnterpriseAdministratorInvitation.self
    case "EnterpriseIdentityProvider": return GitHubAPI.EnterpriseIdentityProvider.self
    case "EnterpriseRepositoryInfo": return GitHubAPI.EnterpriseRepositoryInfo.self
    case "EnterpriseServerInstallation": return GitHubAPI.EnterpriseServerInstallation.self
    case "EnterpriseServerUserAccount": return GitHubAPI.EnterpriseServerUserAccount.self
    case "EnterpriseServerUserAccountEmail": return GitHubAPI.EnterpriseServerUserAccountEmail.self
    case "EnterpriseServerUserAccountsUpload": return GitHubAPI.EnterpriseServerUserAccountsUpload.self
    case "ExternalIdentity": return GitHubAPI.ExternalIdentity.self
    case "HeadRefDeletedEvent": return GitHubAPI.HeadRefDeletedEvent.self
    case "HeadRefForcePushedEvent": return GitHubAPI.HeadRefForcePushedEvent.self
    case "HeadRefRestoredEvent": return GitHubAPI.HeadRefRestoredEvent.self
    case "IpAllowListEntry": return GitHubAPI.IpAllowListEntry.self
    case "Label": return GitHubAPI.Label.self
    case "LabeledEvent": return GitHubAPI.LabeledEvent.self
    case "Language": return GitHubAPI.Language.self
    case "License": return GitHubAPI.License.self
    case "LockedEvent": return GitHubAPI.LockedEvent.self
    case "MarkedAsDuplicateEvent": return GitHubAPI.MarkedAsDuplicateEvent.self
    case "MarketplaceCategory": return GitHubAPI.MarketplaceCategory.self
    case "MarketplaceListing": return GitHubAPI.MarketplaceListing.self
    case "MembersCanDeleteReposClearAuditEntry": return GitHubAPI.MembersCanDeleteReposClearAuditEntry.self
    case "MembersCanDeleteReposDisableAuditEntry": return GitHubAPI.MembersCanDeleteReposDisableAuditEntry.self
    case "MembersCanDeleteReposEnableAuditEntry": return GitHubAPI.MembersCanDeleteReposEnableAuditEntry.self
    case "OauthApplicationCreateAuditEntry": return GitHubAPI.OauthApplicationCreateAuditEntry.self
    case "OrgOauthAppAccessApprovedAuditEntry": return GitHubAPI.OrgOauthAppAccessApprovedAuditEntry.self
    case "OrgOauthAppAccessDeniedAuditEntry": return GitHubAPI.OrgOauthAppAccessDeniedAuditEntry.self
    case "OrgOauthAppAccessRequestedAuditEntry": return GitHubAPI.OrgOauthAppAccessRequestedAuditEntry.self
    case "OrgAddBillingManagerAuditEntry": return GitHubAPI.OrgAddBillingManagerAuditEntry.self
    case "OrgAddMemberAuditEntry": return GitHubAPI.OrgAddMemberAuditEntry.self
    case "OrgBlockUserAuditEntry": return GitHubAPI.OrgBlockUserAuditEntry.self
    case "OrgConfigDisableCollaboratorsOnlyAuditEntry": return GitHubAPI.OrgConfigDisableCollaboratorsOnlyAuditEntry.self
    case "OrgConfigEnableCollaboratorsOnlyAuditEntry": return GitHubAPI.OrgConfigEnableCollaboratorsOnlyAuditEntry.self
    case "OrgCreateAuditEntry": return GitHubAPI.OrgCreateAuditEntry.self
    case "OrgDisableOauthAppRestrictionsAuditEntry": return GitHubAPI.OrgDisableOauthAppRestrictionsAuditEntry.self
    case "OrgDisableSamlAuditEntry": return GitHubAPI.OrgDisableSamlAuditEntry.self
    case "OrgDisableTwoFactorRequirementAuditEntry": return GitHubAPI.OrgDisableTwoFactorRequirementAuditEntry.self
    case "OrgEnableOauthAppRestrictionsAuditEntry": return GitHubAPI.OrgEnableOauthAppRestrictionsAuditEntry.self
    case "OrgEnableSamlAuditEntry": return GitHubAPI.OrgEnableSamlAuditEntry.self
    case "OrgEnableTwoFactorRequirementAuditEntry": return GitHubAPI.OrgEnableTwoFactorRequirementAuditEntry.self
    case "OrgInviteMemberAuditEntry": return GitHubAPI.OrgInviteMemberAuditEntry.self
    case "OrgInviteToBusinessAuditEntry": return GitHubAPI.OrgInviteToBusinessAuditEntry.self
    case "OrgRemoveBillingManagerAuditEntry": return GitHubAPI.OrgRemoveBillingManagerAuditEntry.self
    case "OrgRemoveMemberAuditEntry": return GitHubAPI.OrgRemoveMemberAuditEntry.self
    case "OrgRemoveOutsideCollaboratorAuditEntry": return GitHubAPI.OrgRemoveOutsideCollaboratorAuditEntry.self
    case "OrgRestoreMemberAuditEntry": return GitHubAPI.OrgRestoreMemberAuditEntry.self
    case "OrgRestoreMemberMembershipOrganizationAuditEntryData": return GitHubAPI.OrgRestoreMemberMembershipOrganizationAuditEntryData.self
    case "OrgUnblockUserAuditEntry": return GitHubAPI.OrgUnblockUserAuditEntry.self
    case "OrgUpdateDefaultRepositoryPermissionAuditEntry": return GitHubAPI.OrgUpdateDefaultRepositoryPermissionAuditEntry.self
    case "OrgUpdateMemberAuditEntry": return GitHubAPI.OrgUpdateMemberAuditEntry.self
    case "OrgUpdateMemberRepositoryCreationPermissionAuditEntry": return GitHubAPI.OrgUpdateMemberRepositoryCreationPermissionAuditEntry.self
    case "OrgUpdateMemberRepositoryInvitationPermissionAuditEntry": return GitHubAPI.OrgUpdateMemberRepositoryInvitationPermissionAuditEntry.self
    case "PrivateRepositoryForkingDisableAuditEntry": return GitHubAPI.PrivateRepositoryForkingDisableAuditEntry.self
    case "OrgRestoreMemberMembershipRepositoryAuditEntryData": return GitHubAPI.OrgRestoreMemberMembershipRepositoryAuditEntryData.self
    case "PrivateRepositoryForkingEnableAuditEntry": return GitHubAPI.PrivateRepositoryForkingEnableAuditEntry.self
    case "RepoAccessAuditEntry": return GitHubAPI.RepoAccessAuditEntry.self
    case "RepoAddMemberAuditEntry": return GitHubAPI.RepoAddMemberAuditEntry.self
    case "RepoAddTopicAuditEntry": return GitHubAPI.RepoAddTopicAuditEntry.self
    case "RepoRemoveTopicAuditEntry": return GitHubAPI.RepoRemoveTopicAuditEntry.self
    case "RepoArchivedAuditEntry": return GitHubAPI.RepoArchivedAuditEntry.self
    case "RepoChangeMergeSettingAuditEntry": return GitHubAPI.RepoChangeMergeSettingAuditEntry.self
    case "RepoConfigDisableAnonymousGitAccessAuditEntry": return GitHubAPI.RepoConfigDisableAnonymousGitAccessAuditEntry.self
    case "RepoConfigDisableCollaboratorsOnlyAuditEntry": return GitHubAPI.RepoConfigDisableCollaboratorsOnlyAuditEntry.self
    case "RepoConfigDisableContributorsOnlyAuditEntry": return GitHubAPI.RepoConfigDisableContributorsOnlyAuditEntry.self
    case "RepoConfigDisableSockpuppetDisallowedAuditEntry": return GitHubAPI.RepoConfigDisableSockpuppetDisallowedAuditEntry.self
    case "RepoConfigEnableAnonymousGitAccessAuditEntry": return GitHubAPI.RepoConfigEnableAnonymousGitAccessAuditEntry.self
    case "RepoConfigEnableCollaboratorsOnlyAuditEntry": return GitHubAPI.RepoConfigEnableCollaboratorsOnlyAuditEntry.self
    case "RepoConfigEnableContributorsOnlyAuditEntry": return GitHubAPI.RepoConfigEnableContributorsOnlyAuditEntry.self
    case "RepoConfigEnableSockpuppetDisallowedAuditEntry": return GitHubAPI.RepoConfigEnableSockpuppetDisallowedAuditEntry.self
    case "RepoConfigLockAnonymousGitAccessAuditEntry": return GitHubAPI.RepoConfigLockAnonymousGitAccessAuditEntry.self
    case "RepoConfigUnlockAnonymousGitAccessAuditEntry": return GitHubAPI.RepoConfigUnlockAnonymousGitAccessAuditEntry.self
    case "RepoCreateAuditEntry": return GitHubAPI.RepoCreateAuditEntry.self
    case "RepoDestroyAuditEntry": return GitHubAPI.RepoDestroyAuditEntry.self
    case "RepoRemoveMemberAuditEntry": return GitHubAPI.RepoRemoveMemberAuditEntry.self
    case "TeamAddRepositoryAuditEntry": return GitHubAPI.TeamAddRepositoryAuditEntry.self
    case "OrgRestoreMemberMembershipTeamAuditEntryData": return GitHubAPI.OrgRestoreMemberMembershipTeamAuditEntryData.self
    case "TeamAddMemberAuditEntry": return GitHubAPI.TeamAddMemberAuditEntry.self
    case "TeamChangeParentTeamAuditEntry": return GitHubAPI.TeamChangeParentTeamAuditEntry.self
    case "TeamRemoveMemberAuditEntry": return GitHubAPI.TeamRemoveMemberAuditEntry.self
    case "TeamRemoveRepositoryAuditEntry": return GitHubAPI.TeamRemoveRepositoryAuditEntry.self
    case "RepositoryVisibilityChangeDisableAuditEntry": return GitHubAPI.RepositoryVisibilityChangeDisableAuditEntry.self
    case "RepositoryVisibilityChangeEnableAuditEntry": return GitHubAPI.RepositoryVisibilityChangeEnableAuditEntry.self
    case "MentionedEvent": return GitHubAPI.MentionedEvent.self
    case "MilestonedEvent": return GitHubAPI.MilestonedEvent.self
    case "MovedColumnsInProjectEvent": return GitHubAPI.MovedColumnsInProjectEvent.self
    case "OrganizationIdentityProvider": return GitHubAPI.OrganizationIdentityProvider.self
    case "OrganizationInvitation": return GitHubAPI.OrganizationInvitation.self
    case "Package": return GitHubAPI.Package.self
    case "PackageFile": return GitHubAPI.PackageFile.self
    case "PackageTag": return GitHubAPI.PackageTag.self
    case "PackageVersion": return GitHubAPI.PackageVersion.self
    case "PinnedEvent": return GitHubAPI.PinnedEvent.self
    case "PinnedIssue": return GitHubAPI.PinnedIssue.self
    case "ProjectCard": return GitHubAPI.ProjectCard.self
    case "ProjectColumn": return GitHubAPI.ProjectColumn.self
    case "PublicKey": return GitHubAPI.PublicKey.self
    case "PullRequestReviewThread": return GitHubAPI.PullRequestReviewThread.self
    case "Push": return GitHubAPI.Push.self
    case "PushAllowance": return GitHubAPI.PushAllowance.self
    case "Reaction": return GitHubAPI.Reaction.self
    case "Ref": return GitHubAPI.Ref.self
    case "ReferencedEvent": return GitHubAPI.ReferencedEvent.self
    case "ReleaseAsset": return GitHubAPI.ReleaseAsset.self
    case "RemovedFromProjectEvent": return GitHubAPI.RemovedFromProjectEvent.self
    case "RenamedTitleEvent": return GitHubAPI.RenamedTitleEvent.self
    case "ReopenedEvent": return GitHubAPI.ReopenedEvent.self
    case "RepositoryInvitation": return GitHubAPI.RepositoryInvitation.self
    case "ReviewDismissalAllowance": return GitHubAPI.ReviewDismissalAllowance.self
    case "ReviewRequest": return GitHubAPI.ReviewRequest.self
    case "ReviewRequestRemovedEvent": return GitHubAPI.ReviewRequestRemovedEvent.self
    case "ReviewRequestedEvent": return GitHubAPI.ReviewRequestedEvent.self
    case "SavedReply": return GitHubAPI.SavedReply.self
    case "SecurityAdvisory": return GitHubAPI.SecurityAdvisory.self
    case "SponsorsListing": return GitHubAPI.SponsorsListing.self
    case "SponsorsTier": return GitHubAPI.SponsorsTier.self
    case "Sponsorship": return GitHubAPI.Sponsorship.self
    case "Status": return GitHubAPI.Status.self
    case "StatusCheckRollup": return GitHubAPI.StatusCheckRollup.self
    case "StatusContext": return GitHubAPI.StatusContext.self
    case "SubscribedEvent": return GitHubAPI.SubscribedEvent.self
    case "TransferredEvent": return GitHubAPI.TransferredEvent.self
    case "UnassignedEvent": return GitHubAPI.UnassignedEvent.self
    case "UnlabeledEvent": return GitHubAPI.UnlabeledEvent.self
    case "UnlockedEvent": return GitHubAPI.UnlockedEvent.self
    case "UnmarkedAsDuplicateEvent": return GitHubAPI.UnmarkedAsDuplicateEvent.self
    case "UnpinnedEvent": return GitHubAPI.UnpinnedEvent.self
    case "UnsubscribedEvent": return GitHubAPI.UnsubscribedEvent.self
    case "UserBlockedEvent": return GitHubAPI.UserBlockedEvent.self
    case "UserContentEdit": return GitHubAPI.UserContentEdit.self
    case "UserStatus": return GitHubAPI.UserStatus.self
    case "IssueConnection": return GitHubAPI.IssueConnection.self
    case "IssueCommentConnection": return GitHubAPI.IssueCommentConnection.self
    default: return nil
    }
  }
}
