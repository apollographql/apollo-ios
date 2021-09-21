#### Diff
Example: [0.48.0...main](https://github.com/apollographql/apollo-ios/compare/0.48.0...main).

#### Relevant changes:
* _List the highlight changes_

#### Things to do in this PR
- [ ] Update the version in [`Configuration/Shared/Project-Version.xcconfig`](https://github.com/apollographql/apollo-ios/blob/main/Configuration/Shared/Project-Version.xcconfig).
- [ ] Update [`CHANGELOG.md`](https://github.com/apollographql/apollo-ios/blob/main/CHANGELOG.md) with all relevant changes since the prior version. Please include PR numbers and mention contributors for external PR submissions.
- [ ] Run the Documentation Generator as noted in [`api-reference.md`](https://github.com/apollographql/apollo-ios/blob/main/docs/source/api-reference.md) to re-generate documentation from source for all included libraries.

#### Other things to do before a release - _these need to be automated by CI_
- [ ] Validate that `main` builds with a test Swift Package Manager project.
- [ ] Validate that `main` builds with a test CocoaPods project.
- [ ] Validate that `main` builds with a test Carthage project (make sure to use `--use-xcframeworks`).

#### Things to do as part of releasing
- [ ] Add tag of format `major.minor.patch` to GitHub for SPM/Carthage.
- [ ] Create a release on GitHub with the new tag, using the latest [`CHANGELOG.md`](https://github.com/apollographql/apollo-ios/blob/main/CHANGELOG.md) contents.
- [ ] Run `pod trunk push Apollo.podspec` to publish to CocoaPods. You will need write permissions for this, please contact one of the [maintainers](https://github.com/apollographql/apollo-ios/blob/main/README.md#maintainers) if you need access to do this.
- [ ] Announce the new version (Twitter, etc.)

#### Things to do after release - _these need to be automated by CI_
- [ ] Update to the new version of apollo-ios in the [sample application](https://github.com/apollographql/iOSTutorial).
- [ ] Update to the new version of apollo-ios in the [codegen template](https://github.com/apollographql/iOSCodegenTemplate).
- [ ] Make sure all [playground pages](https://github.com/apollographql/apollo-client-swift-playground) still execute.
