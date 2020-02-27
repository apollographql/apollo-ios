# Releasing

This document checklist of things that need to happen before, during, and after a release of this library. This document is included in the repo for a couple reasons: 
 
1. It makes it easier for people who are not the primary maintainer to perform a relase if needed
2. It helps the primary maintainer, who has the memory of a goldfish, remember to actually do all this stuff before releasing

## Pre-flight checklist

Things to do before cutting a release:

-[ ] Update the `CHANGELOG` with all relevant changes since the prior version
-[ ] Update the version in [`Configuration/Shared/Project-Version.xcconfig`](Configuration/Shared/Project-Version.xcconfig)
-[ ] Run the Documentation Generator as noted in [`api-reference.md`](docs/source/api-reference.md) to re-generate documentation from source for all included libraries
-[ ] Validate that `master` builds with a test Swift Package Manager project
-[ ] Validate that `master` builds with a test CocoaPods project
-[ ] Validate that `master` builds with a test Carthage project 

## Flight Plan

Things to do as part of releasing: 

-[ ] Add tag of format `major.minor.patch` to GitHub for SPM/Carthage
-[ ] Run `pod trunk push Apollo.podspec`* to publish to CocoaPods
-[ ] Update release on GitHub to have `CHANGELOG` contents for that version
-[ ] Tweet link to tag for new version

_* - You will need write permissions for this to actually work, please contact [Ellen](https://github.com/designatednerd) or [James](https://github.com/jbaxleyiii) if you need them and don't have them_

## Post-Flight Checklist

Things to do after release has been made

-[ ] Update version of library in sample applications (Currently: [Frontpage](https://github.com/apollographql/frontpage-ios-app) and [RocketReserver](https://github.com/apollographql/iOSTutorial))
-[ ] Close out milestone in GitHub and all related issues
-[ ] Create next expected milestone in GitHub