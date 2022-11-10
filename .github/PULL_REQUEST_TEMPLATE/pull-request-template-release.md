#### Diff
[1.0.2...main](https://github.com/apollographql/apollo-ios/compare/1.0.2...main). _Change this to show the diff since the last version._

#### Relevant changes:
* _List the highlight PRs_

#### Things to do in this PR
- [ ] Update the version in [`Configuration/Shared/Project-Version.xcconfig`](https://github.com/apollographql/apollo-ios/blob/main/Configuration/Shared/Project-Version.xcconfig).
- [ ] Update [`CHANGELOG.md`](https://github.com/apollographql/apollo-ios/blob/main/CHANGELOG.md) with all relevant changes since the prior version. _Please include PR numbers and mention contributors for external PR submissions._
- [ ] Run the Documentation Generator as noted in [`api-reference.md`](https://github.com/apollographql/apollo-ios/blob/main/docs/source/api-reference.md) to re-generate documentation from source for all included libraries. _Make sure you are on HEAD of the parent branch otherwise the documentation generator will not catch all changes, rebase this PR if needed._

#### Things to do as part of releasing
- [ ] Add tag of format `major.minor.patch` to GitHub.
- [ ] Create a release on GitHub with the new tag, using the latest [`CHANGELOG.md`](https://github.com/apollographql/apollo-ios/blob/main/CHANGELOG.md) contents.
- [ ] Attach CLI binary to the GitHub release. _Use the `make build-cli` command._
- [ ] Run `pod trunk push Apollo.podspec` to publish to CocoaPods. _You will need write permissions for this, please contact one of the [maintainers](https://github.com/apollographql/apollo-ios/blob/main/README.md#maintainers) if you need access to do this._
