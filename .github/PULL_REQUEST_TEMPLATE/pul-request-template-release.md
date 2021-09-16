---
name: Release
about: Use this template for submitting a release pull request.
---
#### Diff
Example: [0.48.0...main](https://github.com/apollographql/apollo-ios/compare/0.48.0...main).

#### Relevant changes:
* _List the highlight changes_

#### Pre-release Checklist
- [ ] Update the version in [`Configuration/Shared/Project-Version.xcconfig`](https://github.com/apollographql/apollo-ios/blob/main/Configuration/Shared/Project-Version.xcconfig)
- [ ] Update [`CHANGELOG.md`](https://github.com/apollographql/apollo-ios/blob/main/CHANGELOG.md) with all relevant changes since the prior version. Please include PR numbers and mention contributors for external PR submissions.
- [ ] Run the Documentation Generator as noted in [`api-reference.md`](https://github.com/apollographql/apollo-ios/blob/main/docs/source/api-reference.md) to re-generate documentation from source for all included libraries
- [ ] Validate that main builds with a test Swift Package Manager project
- [ ] Validate that main builds with a test CocoaPods project
- [ ] Validate that main builds with a test Carthage project
