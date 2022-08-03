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
  public static func graphQLType(forTypename typename: String) -> Object? {
    switch typename {
    case "Query": return GitHubAPI.Objects.Query
    case "Repository": return GitHubAPI.Objects.Repository
    case "AddedToProjectEvent": return GitHubAPI.Objects.AddedToProjectEvent
    case "App": return GitHubAPI.Objects.App
    case "AssignedEvent": return GitHubAPI.Objects.AssignedEvent
    case "AutomaticBaseChangeFailedEvent": return GitHubAPI.Objects.AutomaticBaseChangeFailedEvent
    case "AutomaticBaseChangeSucceededEvent": return GitHubAPI.Objects.AutomaticBaseChangeSucceededEvent
    case "BaseRefChangedEvent": return GitHubAPI.Objects.BaseRefChangedEvent
    case "BaseRefForcePushedEvent": return GitHubAPI.Objects.BaseRefForcePushedEvent
    case "Blob": return GitHubAPI.Objects.Blob
    case "Commit": return GitHubAPI.Objects.Commit
    case "Issue": return GitHubAPI.Objects.Issue
    case "PullRequest": return GitHubAPI.Objects.PullRequest
    case "Milestone": return GitHubAPI.Objects.Milestone
    case "Bot": return GitHubAPI.Objects.Bot
    case "EnterpriseUserAccount": return GitHubAPI.Objects.EnterpriseUserAccount
    case "Mannequin": return GitHubAPI.Objects.Mannequin
    case "Organization": return GitHubAPI.Objects.Organization
    case "Team": return GitHubAPI.Objects.Team
    case "User": return GitHubAPI.Objects.User
    case "CheckRun": return GitHubAPI.Objects.CheckRun
    case "ClosedEvent": return GitHubAPI.Objects.ClosedEvent
    case "ConvertToDraftEvent": return GitHubAPI.Objects.ConvertToDraftEvent
    case "CrossReferencedEvent": return GitHubAPI.Objects.CrossReferencedEvent
    case "Gist": return GitHubAPI.Objects.Gist
    case "Topic": return GitHubAPI.Objects.Topic
    case "MergedEvent": return GitHubAPI.Objects.MergedEvent
    case "PullRequestCommit": return GitHubAPI.Objects.PullRequestCommit
    case "ReadyForReviewEvent": return GitHubAPI.Objects.ReadyForReviewEvent
    case "Release": return GitHubAPI.Objects.Release
    case "RepositoryTopic": return GitHubAPI.Objects.RepositoryTopic
    case "ReviewDismissedEvent": return GitHubAPI.Objects.ReviewDismissedEvent
    case "TeamDiscussion": return GitHubAPI.Objects.TeamDiscussion
    case "CommitComment": return GitHubAPI.Objects.CommitComment
    case "GistComment": return GitHubAPI.Objects.GistComment
    case "IssueComment": return GitHubAPI.Objects.IssueComment
    case "PullRequestReview": return GitHubAPI.Objects.PullRequestReview
    case "CommitCommentThread": return GitHubAPI.Objects.CommitCommentThread
    case "PullRequestCommitCommentThread": return GitHubAPI.Objects.PullRequestCommitCommentThread
    case "PullRequestReviewComment": return GitHubAPI.Objects.PullRequestReviewComment
    case "Project": return GitHubAPI.Objects.Project
    case "TeamDiscussionComment": return GitHubAPI.Objects.TeamDiscussionComment
    case "RepositoryVulnerabilityAlert": return GitHubAPI.Objects.RepositoryVulnerabilityAlert
    case "Tag": return GitHubAPI.Objects.Tag
    case "Tree": return GitHubAPI.Objects.Tree
    case "BranchProtectionRule": return GitHubAPI.Objects.BranchProtectionRule
    case "CheckSuite": return GitHubAPI.Objects.CheckSuite
    case "CodeOfConduct": return GitHubAPI.Objects.CodeOfConduct
    case "CommentDeletedEvent": return GitHubAPI.Objects.CommentDeletedEvent
    case "ConnectedEvent": return GitHubAPI.Objects.ConnectedEvent
    case "ConvertedNoteToIssueEvent": return GitHubAPI.Objects.ConvertedNoteToIssueEvent
    case "DemilestonedEvent": return GitHubAPI.Objects.DemilestonedEvent
    case "DependencyGraphManifest": return GitHubAPI.Objects.DependencyGraphManifest
    case "DeployKey": return GitHubAPI.Objects.DeployKey
    case "DeployedEvent": return GitHubAPI.Objects.DeployedEvent
    case "Deployment": return GitHubAPI.Objects.Deployment
    case "DeploymentEnvironmentChangedEvent": return GitHubAPI.Objects.DeploymentEnvironmentChangedEvent
    case "DeploymentStatus": return GitHubAPI.Objects.DeploymentStatus
    case "DisconnectedEvent": return GitHubAPI.Objects.DisconnectedEvent
    case "Enterprise": return GitHubAPI.Objects.Enterprise
    case "EnterpriseAdministratorInvitation": return GitHubAPI.Objects.EnterpriseAdministratorInvitation
    case "EnterpriseIdentityProvider": return GitHubAPI.Objects.EnterpriseIdentityProvider
    case "EnterpriseRepositoryInfo": return GitHubAPI.Objects.EnterpriseRepositoryInfo
    case "EnterpriseServerInstallation": return GitHubAPI.Objects.EnterpriseServerInstallation
    case "EnterpriseServerUserAccount": return GitHubAPI.Objects.EnterpriseServerUserAccount
    case "EnterpriseServerUserAccountEmail": return GitHubAPI.Objects.EnterpriseServerUserAccountEmail
    case "EnterpriseServerUserAccountsUpload": return GitHubAPI.Objects.EnterpriseServerUserAccountsUpload
    case "ExternalIdentity": return GitHubAPI.Objects.ExternalIdentity
    case "HeadRefDeletedEvent": return GitHubAPI.Objects.HeadRefDeletedEvent
    case "HeadRefForcePushedEvent": return GitHubAPI.Objects.HeadRefForcePushedEvent
    case "HeadRefRestoredEvent": return GitHubAPI.Objects.HeadRefRestoredEvent
    case "IpAllowListEntry": return GitHubAPI.Objects.IpAllowListEntry
    case "Label": return GitHubAPI.Objects.Label
    case "LabeledEvent": return GitHubAPI.Objects.LabeledEvent
    case "Language": return GitHubAPI.Objects.Language
    case "License": return GitHubAPI.Objects.License
    case "LockedEvent": return GitHubAPI.Objects.LockedEvent
    case "MarkedAsDuplicateEvent": return GitHubAPI.Objects.MarkedAsDuplicateEvent
    case "MarketplaceCategory": return GitHubAPI.Objects.MarketplaceCategory
    case "MarketplaceListing": return GitHubAPI.Objects.MarketplaceListing
    case "MembersCanDeleteReposClearAuditEntry": return GitHubAPI.Objects.MembersCanDeleteReposClearAuditEntry
    case "MembersCanDeleteReposDisableAuditEntry": return GitHubAPI.Objects.MembersCanDeleteReposDisableAuditEntry
    case "MembersCanDeleteReposEnableAuditEntry": return GitHubAPI.Objects.MembersCanDeleteReposEnableAuditEntry
    case "OauthApplicationCreateAuditEntry": return GitHubAPI.Objects.OauthApplicationCreateAuditEntry
    case "OrgOauthAppAccessApprovedAuditEntry": return GitHubAPI.Objects.OrgOauthAppAccessApprovedAuditEntry
    case "OrgOauthAppAccessDeniedAuditEntry": return GitHubAPI.Objects.OrgOauthAppAccessDeniedAuditEntry
    case "OrgOauthAppAccessRequestedAuditEntry": return GitHubAPI.Objects.OrgOauthAppAccessRequestedAuditEntry
    case "OrgAddBillingManagerAuditEntry": return GitHubAPI.Objects.OrgAddBillingManagerAuditEntry
    case "OrgAddMemberAuditEntry": return GitHubAPI.Objects.OrgAddMemberAuditEntry
    case "OrgBlockUserAuditEntry": return GitHubAPI.Objects.OrgBlockUserAuditEntry
    case "OrgConfigDisableCollaboratorsOnlyAuditEntry": return GitHubAPI.Objects.OrgConfigDisableCollaboratorsOnlyAuditEntry
    case "OrgConfigEnableCollaboratorsOnlyAuditEntry": return GitHubAPI.Objects.OrgConfigEnableCollaboratorsOnlyAuditEntry
    case "OrgCreateAuditEntry": return GitHubAPI.Objects.OrgCreateAuditEntry
    case "OrgDisableOauthAppRestrictionsAuditEntry": return GitHubAPI.Objects.OrgDisableOauthAppRestrictionsAuditEntry
    case "OrgDisableSamlAuditEntry": return GitHubAPI.Objects.OrgDisableSamlAuditEntry
    case "OrgDisableTwoFactorRequirementAuditEntry": return GitHubAPI.Objects.OrgDisableTwoFactorRequirementAuditEntry
    case "OrgEnableOauthAppRestrictionsAuditEntry": return GitHubAPI.Objects.OrgEnableOauthAppRestrictionsAuditEntry
    case "OrgEnableSamlAuditEntry": return GitHubAPI.Objects.OrgEnableSamlAuditEntry
    case "OrgEnableTwoFactorRequirementAuditEntry": return GitHubAPI.Objects.OrgEnableTwoFactorRequirementAuditEntry
    case "OrgInviteMemberAuditEntry": return GitHubAPI.Objects.OrgInviteMemberAuditEntry
    case "OrgInviteToBusinessAuditEntry": return GitHubAPI.Objects.OrgInviteToBusinessAuditEntry
    case "OrgRemoveBillingManagerAuditEntry": return GitHubAPI.Objects.OrgRemoveBillingManagerAuditEntry
    case "OrgRemoveMemberAuditEntry": return GitHubAPI.Objects.OrgRemoveMemberAuditEntry
    case "OrgRemoveOutsideCollaboratorAuditEntry": return GitHubAPI.Objects.OrgRemoveOutsideCollaboratorAuditEntry
    case "OrgRestoreMemberAuditEntry": return GitHubAPI.Objects.OrgRestoreMemberAuditEntry
    case "OrgRestoreMemberMembershipOrganizationAuditEntryData": return GitHubAPI.Objects.OrgRestoreMemberMembershipOrganizationAuditEntryData
    case "OrgUnblockUserAuditEntry": return GitHubAPI.Objects.OrgUnblockUserAuditEntry
    case "OrgUpdateDefaultRepositoryPermissionAuditEntry": return GitHubAPI.Objects.OrgUpdateDefaultRepositoryPermissionAuditEntry
    case "OrgUpdateMemberAuditEntry": return GitHubAPI.Objects.OrgUpdateMemberAuditEntry
    case "OrgUpdateMemberRepositoryCreationPermissionAuditEntry": return GitHubAPI.Objects.OrgUpdateMemberRepositoryCreationPermissionAuditEntry
    case "OrgUpdateMemberRepositoryInvitationPermissionAuditEntry": return GitHubAPI.Objects.OrgUpdateMemberRepositoryInvitationPermissionAuditEntry
    case "PrivateRepositoryForkingDisableAuditEntry": return GitHubAPI.Objects.PrivateRepositoryForkingDisableAuditEntry
    case "OrgRestoreMemberMembershipRepositoryAuditEntryData": return GitHubAPI.Objects.OrgRestoreMemberMembershipRepositoryAuditEntryData
    case "PrivateRepositoryForkingEnableAuditEntry": return GitHubAPI.Objects.PrivateRepositoryForkingEnableAuditEntry
    case "RepoAccessAuditEntry": return GitHubAPI.Objects.RepoAccessAuditEntry
    case "RepoAddMemberAuditEntry": return GitHubAPI.Objects.RepoAddMemberAuditEntry
    case "RepoAddTopicAuditEntry": return GitHubAPI.Objects.RepoAddTopicAuditEntry
    case "RepoRemoveTopicAuditEntry": return GitHubAPI.Objects.RepoRemoveTopicAuditEntry
    case "RepoArchivedAuditEntry": return GitHubAPI.Objects.RepoArchivedAuditEntry
    case "RepoChangeMergeSettingAuditEntry": return GitHubAPI.Objects.RepoChangeMergeSettingAuditEntry
    case "RepoConfigDisableAnonymousGitAccessAuditEntry": return GitHubAPI.Objects.RepoConfigDisableAnonymousGitAccessAuditEntry
    case "RepoConfigDisableCollaboratorsOnlyAuditEntry": return GitHubAPI.Objects.RepoConfigDisableCollaboratorsOnlyAuditEntry
    case "RepoConfigDisableContributorsOnlyAuditEntry": return GitHubAPI.Objects.RepoConfigDisableContributorsOnlyAuditEntry
    case "RepoConfigDisableSockpuppetDisallowedAuditEntry": return GitHubAPI.Objects.RepoConfigDisableSockpuppetDisallowedAuditEntry
    case "RepoConfigEnableAnonymousGitAccessAuditEntry": return GitHubAPI.Objects.RepoConfigEnableAnonymousGitAccessAuditEntry
    case "RepoConfigEnableCollaboratorsOnlyAuditEntry": return GitHubAPI.Objects.RepoConfigEnableCollaboratorsOnlyAuditEntry
    case "RepoConfigEnableContributorsOnlyAuditEntry": return GitHubAPI.Objects.RepoConfigEnableContributorsOnlyAuditEntry
    case "RepoConfigEnableSockpuppetDisallowedAuditEntry": return GitHubAPI.Objects.RepoConfigEnableSockpuppetDisallowedAuditEntry
    case "RepoConfigLockAnonymousGitAccessAuditEntry": return GitHubAPI.Objects.RepoConfigLockAnonymousGitAccessAuditEntry
    case "RepoConfigUnlockAnonymousGitAccessAuditEntry": return GitHubAPI.Objects.RepoConfigUnlockAnonymousGitAccessAuditEntry
    case "RepoCreateAuditEntry": return GitHubAPI.Objects.RepoCreateAuditEntry
    case "RepoDestroyAuditEntry": return GitHubAPI.Objects.RepoDestroyAuditEntry
    case "RepoRemoveMemberAuditEntry": return GitHubAPI.Objects.RepoRemoveMemberAuditEntry
    case "TeamAddRepositoryAuditEntry": return GitHubAPI.Objects.TeamAddRepositoryAuditEntry
    case "OrgRestoreMemberMembershipTeamAuditEntryData": return GitHubAPI.Objects.OrgRestoreMemberMembershipTeamAuditEntryData
    case "TeamAddMemberAuditEntry": return GitHubAPI.Objects.TeamAddMemberAuditEntry
    case "TeamChangeParentTeamAuditEntry": return GitHubAPI.Objects.TeamChangeParentTeamAuditEntry
    case "TeamRemoveMemberAuditEntry": return GitHubAPI.Objects.TeamRemoveMemberAuditEntry
    case "TeamRemoveRepositoryAuditEntry": return GitHubAPI.Objects.TeamRemoveRepositoryAuditEntry
    case "RepositoryVisibilityChangeDisableAuditEntry": return GitHubAPI.Objects.RepositoryVisibilityChangeDisableAuditEntry
    case "RepositoryVisibilityChangeEnableAuditEntry": return GitHubAPI.Objects.RepositoryVisibilityChangeEnableAuditEntry
    case "MentionedEvent": return GitHubAPI.Objects.MentionedEvent
    case "MilestonedEvent": return GitHubAPI.Objects.MilestonedEvent
    case "MovedColumnsInProjectEvent": return GitHubAPI.Objects.MovedColumnsInProjectEvent
    case "OrganizationIdentityProvider": return GitHubAPI.Objects.OrganizationIdentityProvider
    case "OrganizationInvitation": return GitHubAPI.Objects.OrganizationInvitation
    case "Package": return GitHubAPI.Objects.Package
    case "PackageFile": return GitHubAPI.Objects.PackageFile
    case "PackageTag": return GitHubAPI.Objects.PackageTag
    case "PackageVersion": return GitHubAPI.Objects.PackageVersion
    case "PinnedEvent": return GitHubAPI.Objects.PinnedEvent
    case "PinnedIssue": return GitHubAPI.Objects.PinnedIssue
    case "ProjectCard": return GitHubAPI.Objects.ProjectCard
    case "ProjectColumn": return GitHubAPI.Objects.ProjectColumn
    case "PublicKey": return GitHubAPI.Objects.PublicKey
    case "PullRequestReviewThread": return GitHubAPI.Objects.PullRequestReviewThread
    case "Push": return GitHubAPI.Objects.Push
    case "PushAllowance": return GitHubAPI.Objects.PushAllowance
    case "Reaction": return GitHubAPI.Objects.Reaction
    case "Ref": return GitHubAPI.Objects.Ref
    case "ReferencedEvent": return GitHubAPI.Objects.ReferencedEvent
    case "ReleaseAsset": return GitHubAPI.Objects.ReleaseAsset
    case "RemovedFromProjectEvent": return GitHubAPI.Objects.RemovedFromProjectEvent
    case "RenamedTitleEvent": return GitHubAPI.Objects.RenamedTitleEvent
    case "ReopenedEvent": return GitHubAPI.Objects.ReopenedEvent
    case "RepositoryInvitation": return GitHubAPI.Objects.RepositoryInvitation
    case "ReviewDismissalAllowance": return GitHubAPI.Objects.ReviewDismissalAllowance
    case "ReviewRequest": return GitHubAPI.Objects.ReviewRequest
    case "ReviewRequestRemovedEvent": return GitHubAPI.Objects.ReviewRequestRemovedEvent
    case "ReviewRequestedEvent": return GitHubAPI.Objects.ReviewRequestedEvent
    case "SavedReply": return GitHubAPI.Objects.SavedReply
    case "SecurityAdvisory": return GitHubAPI.Objects.SecurityAdvisory
    case "SponsorsListing": return GitHubAPI.Objects.SponsorsListing
    case "SponsorsTier": return GitHubAPI.Objects.SponsorsTier
    case "Sponsorship": return GitHubAPI.Objects.Sponsorship
    case "Status": return GitHubAPI.Objects.Status
    case "StatusCheckRollup": return GitHubAPI.Objects.StatusCheckRollup
    case "StatusContext": return GitHubAPI.Objects.StatusContext
    case "SubscribedEvent": return GitHubAPI.Objects.SubscribedEvent
    case "TransferredEvent": return GitHubAPI.Objects.TransferredEvent
    case "UnassignedEvent": return GitHubAPI.Objects.UnassignedEvent
    case "UnlabeledEvent": return GitHubAPI.Objects.UnlabeledEvent
    case "UnlockedEvent": return GitHubAPI.Objects.UnlockedEvent
    case "UnmarkedAsDuplicateEvent": return GitHubAPI.Objects.UnmarkedAsDuplicateEvent
    case "UnpinnedEvent": return GitHubAPI.Objects.UnpinnedEvent
    case "UnsubscribedEvent": return GitHubAPI.Objects.UnsubscribedEvent
    case "UserBlockedEvent": return GitHubAPI.Objects.UserBlockedEvent
    case "UserContentEdit": return GitHubAPI.Objects.UserContentEdit
    case "UserStatus": return GitHubAPI.Objects.UserStatus
    case "IssueConnection": return GitHubAPI.Objects.IssueConnection
    case "IssueCommentConnection": return GitHubAPI.Objects.IssueCommentConnection
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
