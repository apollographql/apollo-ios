#### Diff
<!-- _Change this to show the diff since the last version._ -->
[See diff since last version](https://github.com/apollographql/apollo-ios/compare/${PREVIOUS_VERSION_TAG}...{$VERSION_BRANCH}). 

#### Relevant changes:
<!-- _List the highlight PRs_ -->

#### Things to do in this PR
- [ ] Update the version constants using the `set-version.sh` script.
- [ ] Update [`CHANGELOG.md`](https://github.com/apollographql/apollo-ios/blob/main/CHANGELOG.md) with all relevant changes since the prior version. _Please include PR numbers and mention contributors for external PR submissions._
- [ ] Run the Documentation Generator from the internal `SwiftScripts` folder using the command `swift run DocumentationGenerator` to re-generate the API reference documentation from source for all included libraries. _Make sure you are on HEAD of the parent branch otherwise the documentation generator will not catch all changes, rebase this PR if needed._

#### Things to do as part of releasing
- [ ] Add tag of format `major.minor.patch` to GitHub.
- [ ] Create a release on GitHub with the new tag, using the latest [`CHANGELOG.md`](https://github.com/apollographql/apollo-ios/blob/main/CHANGELOG.md) contents.
- [ ] Attach CLI binary to the GitHub release. _Use the `make archive-cli-for-release` command which builds both Intel and ARM architectures, and creates the tar archive for you._
- [ ] Run `pod trunk push Apollo.podspec` to publish to CocoaPods. _You will need write permissions for this, please contact one of the [maintainers](https://github.com/apollographql/apollo-ios/blob/main/README.md#maintainers) if you need access to do this._
