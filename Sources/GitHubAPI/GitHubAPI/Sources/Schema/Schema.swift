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
    case "Query": return GitHubAPI.Query
    case "Repository": return GitHubAPI.Repository
    case "AddedToProjectEvent": return GitHubAPI.AddedToProjectEvent
    case "App": return GitHubAPI.App
    case "AssignedEvent": return GitHubAPI.AssignedEvent
    case "AutomaticBaseChangeFailedEvent": return GitHubAPI.AutomaticBaseChangeFailedEvent
    case "AutomaticBaseChangeSucceededEvent": return GitHubAPI.AutomaticBaseChangeSucceededEvent
    case "BaseRefChangedEvent": return GitHubAPI.BaseRefChangedEvent
    case "BaseRefForcePushedEvent": return GitHubAPI.BaseRefForcePushedEvent
    case "Blob": return GitHubAPI.Blob
    case "Commit": return GitHubAPI.Commit
    case "Issue": return GitHubAPI.Issue
    case "PullRequest": return GitHubAPI.PullRequest
    case "Milestone": return GitHubAPI.Milestone
    case "Bot": return GitHubAPI.Bot
    case "EnterpriseUserAccount": return GitHubAPI.EnterpriseUserAccount
    case "Mannequin": return GitHubAPI.Mannequin
    case "Organization": return GitHubAPI.Organization
    case "Team": return GitHubAPI.Team
    case "User": return GitHubAPI.User
    case "CheckRun": return GitHubAPI.CheckRun
    case "ClosedEvent": return GitHubAPI.ClosedEvent
    case "ConvertToDraftEvent": return GitHubAPI.ConvertToDraftEvent
    case "CrossReferencedEvent": return GitHubAPI.CrossReferencedEvent
    case "Gist": return GitHubAPI.Gist
    case "Topic": return GitHubAPI.Topic
    case "MergedEvent": return GitHubAPI.MergedEvent
    case "PullRequestCommit": return GitHubAPI.PullRequestCommit
    case "ReadyForReviewEvent": return GitHubAPI.ReadyForReviewEvent
    case "Release": return GitHubAPI.Release
    case "RepositoryTopic": return GitHubAPI.RepositoryTopic
    case "ReviewDismissedEvent": return GitHubAPI.ReviewDismissedEvent
    case "TeamDiscussion": return GitHubAPI.TeamDiscussion
    case "CommitComment": return GitHubAPI.CommitComment
    case "GistComment": return GitHubAPI.GistComment
    case "IssueComment": return GitHubAPI.IssueComment
    case "PullRequestReview": return GitHubAPI.PullRequestReview
    case "CommitCommentThread": return GitHubAPI.CommitCommentThread
    case "PullRequestCommitCommentThread": return GitHubAPI.PullRequestCommitCommentThread
    case "PullRequestReviewComment": return GitHubAPI.PullRequestReviewComment
    case "Project": return GitHubAPI.Project
    case "TeamDiscussionComment": return GitHubAPI.TeamDiscussionComment
    case "RepositoryVulnerabilityAlert": return GitHubAPI.RepositoryVulnerabilityAlert
    case "Tag": return GitHubAPI.Tag
    case "Tree": return GitHubAPI.Tree
    case "BranchProtectionRule": return GitHubAPI.BranchProtectionRule
    case "CheckSuite": return GitHubAPI.CheckSuite
    case "CodeOfConduct": return GitHubAPI.CodeOfConduct
    case "CommentDeletedEvent": return GitHubAPI.CommentDeletedEvent
    case "ConnectedEvent": return GitHubAPI.ConnectedEvent
    case "ConvertedNoteToIssueEvent": return GitHubAPI.ConvertedNoteToIssueEvent
    case "DemilestonedEvent": return GitHubAPI.DemilestonedEvent
    case "DependencyGraphManifest": return GitHubAPI.DependencyGraphManifest
    case "DeployKey": return GitHubAPI.DeployKey
    case "DeployedEvent": return GitHubAPI.DeployedEvent
    case "Deployment": return GitHubAPI.Deployment
    case "DeploymentEnvironmentChangedEvent": return GitHubAPI.DeploymentEnvironmentChangedEvent
    case "DeploymentStatus": return GitHubAPI.DeploymentStatus
    case "DisconnectedEvent": return GitHubAPI.DisconnectedEvent
    case "Enterprise": return GitHubAPI.Enterprise
    case "EnterpriseAdministratorInvitation": return GitHubAPI.EnterpriseAdministratorInvitation
    case "EnterpriseIdentityProvider": return GitHubAPI.EnterpriseIdentityProvider
    case "EnterpriseRepositoryInfo": return GitHubAPI.EnterpriseRepositoryInfo
    case "EnterpriseServerInstallation": return GitHubAPI.EnterpriseServerInstallation
    case "EnterpriseServerUserAccount": return GitHubAPI.EnterpriseServerUserAccount
    case "EnterpriseServerUserAccountEmail": return GitHubAPI.EnterpriseServerUserAccountEmail
    case "EnterpriseServerUserAccountsUpload": return GitHubAPI.EnterpriseServerUserAccountsUpload
    case "ExternalIdentity": return GitHubAPI.ExternalIdentity
    case "HeadRefDeletedEvent": return GitHubAPI.HeadRefDeletedEvent
    case "HeadRefForcePushedEvent": return GitHubAPI.HeadRefForcePushedEvent
    case "HeadRefRestoredEvent": return GitHubAPI.HeadRefRestoredEvent
    case "IpAllowListEntry": return GitHubAPI.IpAllowListEntry
    case "Label": return GitHubAPI.Label
    case "LabeledEvent": return GitHubAPI.LabeledEvent
    case "Language": return GitHubAPI.Language
    case "License": return GitHubAPI.License
    case "LockedEvent": return GitHubAPI.LockedEvent
    case "MarkedAsDuplicateEvent": return GitHubAPI.MarkedAsDuplicateEvent
    case "MarketplaceCategory": return GitHubAPI.MarketplaceCategory
    case "MarketplaceListing": return GitHubAPI.MarketplaceListing
    case "MembersCanDeleteReposClearAuditEntry": return GitHubAPI.MembersCanDeleteReposClearAuditEntry
    case "MembersCanDeleteReposDisableAuditEntry": return GitHubAPI.MembersCanDeleteReposDisableAuditEntry
    case "MembersCanDeleteReposEnableAuditEntry": return GitHubAPI.MembersCanDeleteReposEnableAuditEntry
    case "OauthApplicationCreateAuditEntry": return GitHubAPI.OauthApplicationCreateAuditEntry
    case "OrgOauthAppAccessApprovedAuditEntry": return GitHubAPI.OrgOauthAppAccessApprovedAuditEntry
    case "OrgOauthAppAccessDeniedAuditEntry": return GitHubAPI.OrgOauthAppAccessDeniedAuditEntry
    case "OrgOauthAppAccessRequestedAuditEntry": return GitHubAPI.OrgOauthAppAccessRequestedAuditEntry
    case "OrgAddBillingManagerAuditEntry": return GitHubAPI.OrgAddBillingManagerAuditEntry
    case "OrgAddMemberAuditEntry": return GitHubAPI.OrgAddMemberAuditEntry
    case "OrgBlockUserAuditEntry": return GitHubAPI.OrgBlockUserAuditEntry
    case "OrgConfigDisableCollaboratorsOnlyAuditEntry": return GitHubAPI.OrgConfigDisableCollaboratorsOnlyAuditEntry
    case "OrgConfigEnableCollaboratorsOnlyAuditEntry": return GitHubAPI.OrgConfigEnableCollaboratorsOnlyAuditEntry
    case "OrgCreateAuditEntry": return GitHubAPI.OrgCreateAuditEntry
    case "OrgDisableOauthAppRestrictionsAuditEntry": return GitHubAPI.OrgDisableOauthAppRestrictionsAuditEntry
    case "OrgDisableSamlAuditEntry": return GitHubAPI.OrgDisableSamlAuditEntry
    case "OrgDisableTwoFactorRequirementAuditEntry": return GitHubAPI.OrgDisableTwoFactorRequirementAuditEntry
    case "OrgEnableOauthAppRestrictionsAuditEntry": return GitHubAPI.OrgEnableOauthAppRestrictionsAuditEntry
    case "OrgEnableSamlAuditEntry": return GitHubAPI.OrgEnableSamlAuditEntry
    case "OrgEnableTwoFactorRequirementAuditEntry": return GitHubAPI.OrgEnableTwoFactorRequirementAuditEntry
    case "OrgInviteMemberAuditEntry": return GitHubAPI.OrgInviteMemberAuditEntry
    case "OrgInviteToBusinessAuditEntry": return GitHubAPI.OrgInviteToBusinessAuditEntry
    case "OrgRemoveBillingManagerAuditEntry": return GitHubAPI.OrgRemoveBillingManagerAuditEntry
    case "OrgRemoveMemberAuditEntry": return GitHubAPI.OrgRemoveMemberAuditEntry
    case "OrgRemoveOutsideCollaboratorAuditEntry": return GitHubAPI.OrgRemoveOutsideCollaboratorAuditEntry
    case "OrgRestoreMemberAuditEntry": return GitHubAPI.OrgRestoreMemberAuditEntry
    case "OrgRestoreMemberMembershipOrganizationAuditEntryData": return GitHubAPI.OrgRestoreMemberMembershipOrganizationAuditEntryData
    case "OrgUnblockUserAuditEntry": return GitHubAPI.OrgUnblockUserAuditEntry
    case "OrgUpdateDefaultRepositoryPermissionAuditEntry": return GitHubAPI.OrgUpdateDefaultRepositoryPermissionAuditEntry
    case "OrgUpdateMemberAuditEntry": return GitHubAPI.OrgUpdateMemberAuditEntry
    case "OrgUpdateMemberRepositoryCreationPermissionAuditEntry": return GitHubAPI.OrgUpdateMemberRepositoryCreationPermissionAuditEntry
    case "OrgUpdateMemberRepositoryInvitationPermissionAuditEntry": return GitHubAPI.OrgUpdateMemberRepositoryInvitationPermissionAuditEntry
    case "PrivateRepositoryForkingDisableAuditEntry": return GitHubAPI.PrivateRepositoryForkingDisableAuditEntry
    case "OrgRestoreMemberMembershipRepositoryAuditEntryData": return GitHubAPI.OrgRestoreMemberMembershipRepositoryAuditEntryData
    case "PrivateRepositoryForkingEnableAuditEntry": return GitHubAPI.PrivateRepositoryForkingEnableAuditEntry
    case "RepoAccessAuditEntry": return GitHubAPI.RepoAccessAuditEntry
    case "RepoAddMemberAuditEntry": return GitHubAPI.RepoAddMemberAuditEntry
    case "RepoAddTopicAuditEntry": return GitHubAPI.RepoAddTopicAuditEntry
    case "RepoRemoveTopicAuditEntry": return GitHubAPI.RepoRemoveTopicAuditEntry
    case "RepoArchivedAuditEntry": return GitHubAPI.RepoArchivedAuditEntry
    case "RepoChangeMergeSettingAuditEntry": return GitHubAPI.RepoChangeMergeSettingAuditEntry
    case "RepoConfigDisableAnonymousGitAccessAuditEntry": return GitHubAPI.RepoConfigDisableAnonymousGitAccessAuditEntry
    case "RepoConfigDisableCollaboratorsOnlyAuditEntry": return GitHubAPI.RepoConfigDisableCollaboratorsOnlyAuditEntry
    case "RepoConfigDisableContributorsOnlyAuditEntry": return GitHubAPI.RepoConfigDisableContributorsOnlyAuditEntry
    case "RepoConfigDisableSockpuppetDisallowedAuditEntry": return GitHubAPI.RepoConfigDisableSockpuppetDisallowedAuditEntry
    case "RepoConfigEnableAnonymousGitAccessAuditEntry": return GitHubAPI.RepoConfigEnableAnonymousGitAccessAuditEntry
    case "RepoConfigEnableCollaboratorsOnlyAuditEntry": return GitHubAPI.RepoConfigEnableCollaboratorsOnlyAuditEntry
    case "RepoConfigEnableContributorsOnlyAuditEntry": return GitHubAPI.RepoConfigEnableContributorsOnlyAuditEntry
    case "RepoConfigEnableSockpuppetDisallowedAuditEntry": return GitHubAPI.RepoConfigEnableSockpuppetDisallowedAuditEntry
    case "RepoConfigLockAnonymousGitAccessAuditEntry": return GitHubAPI.RepoConfigLockAnonymousGitAccessAuditEntry
    case "RepoConfigUnlockAnonymousGitAccessAuditEntry": return GitHubAPI.RepoConfigUnlockAnonymousGitAccessAuditEntry
    case "RepoCreateAuditEntry": return GitHubAPI.RepoCreateAuditEntry
    case "RepoDestroyAuditEntry": return GitHubAPI.RepoDestroyAuditEntry
    case "RepoRemoveMemberAuditEntry": return GitHubAPI.RepoRemoveMemberAuditEntry
    case "TeamAddRepositoryAuditEntry": return GitHubAPI.TeamAddRepositoryAuditEntry
    case "OrgRestoreMemberMembershipTeamAuditEntryData": return GitHubAPI.OrgRestoreMemberMembershipTeamAuditEntryData
    case "TeamAddMemberAuditEntry": return GitHubAPI.TeamAddMemberAuditEntry
    case "TeamChangeParentTeamAuditEntry": return GitHubAPI.TeamChangeParentTeamAuditEntry
    case "TeamRemoveMemberAuditEntry": return GitHubAPI.TeamRemoveMemberAuditEntry
    case "TeamRemoveRepositoryAuditEntry": return GitHubAPI.TeamRemoveRepositoryAuditEntry
    case "RepositoryVisibilityChangeDisableAuditEntry": return GitHubAPI.RepositoryVisibilityChangeDisableAuditEntry
    case "RepositoryVisibilityChangeEnableAuditEntry": return GitHubAPI.RepositoryVisibilityChangeEnableAuditEntry
    case "MentionedEvent": return GitHubAPI.MentionedEvent
    case "MilestonedEvent": return GitHubAPI.MilestonedEvent
    case "MovedColumnsInProjectEvent": return GitHubAPI.MovedColumnsInProjectEvent
    case "OrganizationIdentityProvider": return GitHubAPI.OrganizationIdentityProvider
    case "OrganizationInvitation": return GitHubAPI.OrganizationInvitation
    case "Package": return GitHubAPI.Package
    case "PackageFile": return GitHubAPI.PackageFile
    case "PackageTag": return GitHubAPI.PackageTag
    case "PackageVersion": return GitHubAPI.PackageVersion
    case "PinnedEvent": return GitHubAPI.PinnedEvent
    case "PinnedIssue": return GitHubAPI.PinnedIssue
    case "ProjectCard": return GitHubAPI.ProjectCard
    case "ProjectColumn": return GitHubAPI.ProjectColumn
    case "PublicKey": return GitHubAPI.PublicKey
    case "PullRequestReviewThread": return GitHubAPI.PullRequestReviewThread
    case "Push": return GitHubAPI.Push
    case "PushAllowance": return GitHubAPI.PushAllowance
    case "Reaction": return GitHubAPI.Reaction
    case "Ref": return GitHubAPI.Ref
    case "ReferencedEvent": return GitHubAPI.ReferencedEvent
    case "ReleaseAsset": return GitHubAPI.ReleaseAsset
    case "RemovedFromProjectEvent": return GitHubAPI.RemovedFromProjectEvent
    case "RenamedTitleEvent": return GitHubAPI.RenamedTitleEvent
    case "ReopenedEvent": return GitHubAPI.ReopenedEvent
    case "RepositoryInvitation": return GitHubAPI.RepositoryInvitation
    case "ReviewDismissalAllowance": return GitHubAPI.ReviewDismissalAllowance
    case "ReviewRequest": return GitHubAPI.ReviewRequest
    case "ReviewRequestRemovedEvent": return GitHubAPI.ReviewRequestRemovedEvent
    case "ReviewRequestedEvent": return GitHubAPI.ReviewRequestedEvent
    case "SavedReply": return GitHubAPI.SavedReply
    case "SecurityAdvisory": return GitHubAPI.SecurityAdvisory
    case "SponsorsListing": return GitHubAPI.SponsorsListing
    case "SponsorsTier": return GitHubAPI.SponsorsTier
    case "Sponsorship": return GitHubAPI.Sponsorship
    case "Status": return GitHubAPI.Status
    case "StatusCheckRollup": return GitHubAPI.StatusCheckRollup
    case "StatusContext": return GitHubAPI.StatusContext
    case "SubscribedEvent": return GitHubAPI.SubscribedEvent
    case "TransferredEvent": return GitHubAPI.TransferredEvent
    case "UnassignedEvent": return GitHubAPI.UnassignedEvent
    case "UnlabeledEvent": return GitHubAPI.UnlabeledEvent
    case "UnlockedEvent": return GitHubAPI.UnlockedEvent
    case "UnmarkedAsDuplicateEvent": return GitHubAPI.UnmarkedAsDuplicateEvent
    case "UnpinnedEvent": return GitHubAPI.UnpinnedEvent
    case "UnsubscribedEvent": return GitHubAPI.UnsubscribedEvent
    case "UserBlockedEvent": return GitHubAPI.UserBlockedEvent
    case "UserContentEdit": return GitHubAPI.UserContentEdit
    case "UserStatus": return GitHubAPI.UserStatus
    case "IssueConnection": return GitHubAPI.IssueConnection
    case "IssueCommentConnection": return GitHubAPI.IssueCommentConnection
    default: return nil
    }
  }
}
