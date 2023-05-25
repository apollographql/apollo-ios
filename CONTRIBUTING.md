# Apollo iOS Contributor Guide

Excited about Apollo iOS and want to make it better? We’re excited too!

Apollo is a community of developers just like you, striving to create the best tools and libraries around GraphQL. We welcome anyone who wants to contribute or provide constructive feedback, no matter your age or level of experience. If you want to help but don't know where to start, let us know, and we'll find something for you.

Oh, and if you haven't already, stop by our [community forums!](https://community.apollographql.com)!

Here are some ways to contribute to the project:

* [Reporting bugs](#reporting-bugs)
* [Responding to issues](#responding-to-issues)
* [Improving the documentation](#improving-the-documentation)
* [Suggesting features](#suggesting-features)

* [Submitting pull requests](#pull-requests)
* [Code review](#review)

* [Unit tests](#unit-tests)
* [Integration tests](#integration-tests)
* [Code generation test projects](#code-generation-test-projects)

## Issues

### Reporting bugs

If you encounter a bug, please file an issue here on GitHub, and make sure you note which library is causing the problem. If an issue you have is already reported, please add additional information or add a "+1" comment to indicate you're affected by the issue too and this will help us prioritize the issue.

While we will try to be as helpful as we can on any issue reported, please include as many details as requested in the [Bug Report issue template](https://github.com/apollographql/apollo-ios/issues/new?assignees=&labels=bug%2Cneeds+investigation&projects=&template=bug_report.yaml). Having reproducible steps or sample code for the issue will greatly speed up the time in which we can narrow down on the root cause and find a solution.

At Apollo, we consider the security of our projects a top priority. No matter how much effort we put into system security, there can still be vulnerabilities present. To report a security vulnerability please review our [security policy](https://github.com/apollographql/apollo-ios/security/policy) for more details.

### Responding to issues

In addition to reporting issues, a great way to contribute to Apollo iOS is to respond to other peoples' issues and try to identify the problem or help them work around it. If you’re interested in taking a more active role in this process, please go ahead and respond to issues. Don't forget to say "Hi" on our [community forums](https://community.apollographql.com/tag/mobile) and [Discord server](https://discord.com/invite/graphos)!

### Improving the documentation

Improving the documentation, examples, and other open source content can be the easiest way to contribute to the library. If you see a piece of content that can be better, open a PR with an improvement, no matter how small! If you would like to suggest a big change or major rewrite, we’d love to hear your ideas but please open an issue for discussion before writing the PR.

### Suggesting features

Most of the features in Apollo came from suggestions by you, the community! We welcome any ideas about how to make Apollo better for your use case. Unless there is overwhelming demand for a feature, it might not get implemented immediately, but please include as much information as requested in the [Feature Request template](https://github.com/apollographql/apollo-ios/issues/new?assignees=&labels=feature&projects=&template=feature_request.yaml) that will help people have a discussion about your proposal.

Feature requests will be labeled as such, and we encourage using GitHub issues as a place to discuss new features and possible implementation designs. Please refrain from submitting a pull request to implement a proposed feature until there is consensus that it should be included. This way, you can avoid putting in work that can’t be merged in.

## Pull requests

### Submitting

For a small bug fix change (less than 20 lines of code changed), feel free to open a pull request. We’ll try to review and merge it as fast as possible. The only requirement is, make sure you also add a test that verifies the bug you are trying to fix.

For significant changes to a repository, it’s important to settle on a design before starting on the implementation. This way, we can ensure that major improvements get the care and attention they deserve. Since big changes can be risky and might not always get merged, it’s good to reduce the amount of possible wasted effort by agreeing on an implementation design/plan first.

A good way to propose a design or implementation, and have discussion about it, is with a Request for Comments (RFC) pull request. This is a pull request in which you describe the changes to be made with enough technical detail that suggestions, comments and updates can be made. The approved pull request can then be merged as a technical document or closed for posterity and referenced to in the actual code implementation.

### Review

It’s important that every piece of code in Apollo packages is reviewed by at least one core contributor familiar with that codebase. If you want to expedite the code being merged, try to review your own code first! Here are some things we look for:

1. **All GitHub checks pass.** This is a prerequisite for the review, and it is the PR author's responsibility. The PR will not be reviewed until all the author has signed the Apollo CLA and all tests pass.
2. **Simplicity.** Is this the simplest way to achieve the intended goal? If there are too many files, redundant functions, or complex lines of code, suggest a simpler way to do the same thing. In particular, avoid implementing an overly general solution when a simple, small, and pragmatic fix will do. Please also note that large pull requests take additional time to review. If your PR could be broken down into several smaller, more focused changes, please do that instead.
3. **Testing.** Do the tests ensure this code won’t break when other stuff changes around it? When it does break, will the tests added help us identify which part of the library has the problem? Did we cover an appropriate set of edge cases? Look at the test coverage report if there is one. Are all significant code paths in the new code exercised at least once?
4. **No unnecessary or unrelated changes.** PRs shouldn’t come with random formatting changes, especially in unrelated parts of the code. If there is some refactoring that needs to be done, it should be in a separate PR from a bug fix or feature, if possible.
5. **Code has appropriate comments.** Code should be commented for *why* things are happening, not *what* is happening. *What* is happening should be clear from the names of your functions and variables. This is sometimes called "self-documenting code", but you may still need to add comments to explain why a workaround is necessary so other developers can better understand your code.
6. **Idiomatic use of the language.** Make sure to use idiomatic Swift when working with this repository. We don't presently use SwiftLint or any other linter, but please use your common sense and follow the style of the surrounding code.

## Testing

We do not aim for 100% test coverage but we do require that all new code be thoroughly tested. If you find code that is not being tested, or you want to improve the existing tests, please submit a pull request for it.

Apollo iOS makes extensive use of [Xcode test plans](https://developer.apple.com/documentation/xcode/organizing-tests-to-improve-feedback?changes=_8). All targets have a related scheme and schemes execute one or more of the test plans.

### Unit tests

These are the bulk of tests in Apollo iOS and ensure we cover as much of the logic and edge cases as possible. You can find supporting test infrastructure in the `ApolloInternalTestHelpers` and `ApolloCodegenInternalTestHelpers` modules. Please note that these are _not_ intended to be used for testing your own code that utilizes Apollo iOS.

### Integration tests

There are a number of local services in the repo that are used by CI jobs when the test suite requires interaction that cannot be stubbed with mock data. If the test you're adding is an integration test please ask yourself whether it really _needs_ to be. These tests are a more 'expensive' type of test as they can take longer to execute and be difficult to debug.

### Code generation test projects

The folder [`TestCodeGenConfigurations`](https://github.com/apollographql/apollo-ios/tree/main/Tests/TestCodeGenConfigurations) contains test projects that test the many different codegen configurations of the schema module, operation models and test mocks.

## License

By contributing to Apollo iOS you agree that your contributions will be licensed under its [MIT license](https://github.com/apollographql/apollo-ios/blob/main/LICENSE)
