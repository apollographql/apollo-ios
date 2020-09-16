# Roadmap

This document is meant to give the community some idea of where we're going with the iOS SDK in the short and longer term. 

This document was last updated on September 16, 2020. 

^ If that's more than three months ago, please file an issue asking [@designatednerd](https://github.com/designatednerd) to update this document. 😃


## Short-Term

These are things we plan to be working on **within the next 3 months**.

- **Updated Networking Architecture**: This is now in beta and will be out hopefully within the next couple weeks. Please see [the beta branch PR](https://github.com/apollographql/apollo-ios/pull/1386) for more details.

- **Swift Codegen Rewrite, Continued**: As outlined in much greater detail in the [RFC issue](https://github.com/apollographql/apollo-ios/issues/939), we're rewriting our code generation. This has taken ~~somewhat~~ a lot longer than expected, but the following phases are still in progress:
    
    - **Start generating code with Swift instead of Typescript**. This will allow much easier community contribution to code generation, and allow us to take on a bunch of improvements like `Hashable`, `Equatable`, and potentially `Identifiable` without having to fight with Typescript to do it.
    - **Add immutable caching to new generated code**. Caching is currently heavily tied into our existing parsing mechanism. We're going to separate that out in two phases: The first will allow caching that *cannot* be changed by the consumer.
    - **Add mutable caching to new generated code**. This is the final stage of updating caching: Allowing caching that *can* be changed by the consumer.
    - **Remove Old Codegen**. Once all this is built, older codegen will be deprecated. 

    You can follow this effort through the [Swift Codegen GitHub project](https://github.com/apollographql/apollo-ios/projects/2).
    

- **New Apple Hardware Support**: We're working to make sure Apple Silicon is fully supported when it comes out.

- **General bug-bashing**: There's still a few outstanding general issues and small feature requests I'd like to address, and we'll be dealing with any new issues as they come up.


## Long-Term

These are things we plan to be working on **beyond the next 3 months**. 

We're very open to any help we can get on these if your goals would be advanced by making these things work better sooner.

- **Dependency Manager test suite**. We've seen a few issues around things that work well for at least one of the three major iOS dependency managers, but causes problems in others. We plan to make a repo that we can use to automatically test for common issues against new versions of the library on CocoaPods, Carthage, and Swift Package Manager *before* they're released.

- **Wrapper libraries**. A very highly voted suggestion in our fall 2019 developer survey was wrapper libraries for concurrency helpers like RxSwift, Combine, and PromiseKit. 

    Note that we are **not** locked into any particular set of other dependencies to support yet, but we anticipate these will be wrappers in a separate repository that have Apollo as a dependency. As individual wrappers move into nearer-term work, we'll outline which specific ones we'll be supporting.
