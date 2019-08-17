# Roadmap

This document is meant to give the community some idea of where we're going with the iOS SDK in the short and longer term. 

This document was last updated on August 16, 2019. 

^ If that's more than three months ago, please file an issue asking [@designatednerd](https://github.com/designatednerd) to update this document. 😃


## Short-Term

These are things we plan to be working on **within the next 3 months**.

- **NPM WTF Reduction**: We're looking into ways to package the Apollo CLI as a binary so it can be included with the library and each individual developer will not have to fight with NPM and its attendant joys. 
- **Swift Code, Generated In Swift**: As described in the [call for suggestions](https://github.com/apollographql/apollo-ios/issues/682), we're going to move the "generation" bit of codegen from Typescript into Swift.

  There are several advantages of this, but the biggest one is opening up the ability of our mostly-Swift devs to contribute to Codegen improvements without having to deal with TypeScript and all of its fun edge cases. 

  We're also taking this as an opportunity to make a number of things Swiftier, particularly inlcuding using `Codable` for parsing. 

  You can follow this effort through the [Swift Codegen GitHub project](https://github.com/apollographql/apollo-ios/projects/2).
- **Bug-bashing**: There's still a few outstanding general issues and small feature requests I'd like to address, and we'll be dealing with any new issues as they come up.
- **More up-to-date documentation**: We'll be going through the docs in greater detail to make sure everything is up to snuff. If there's anything in particular you see that definitely needs to be updated, please open an issue!
- **Long-term idea feedback**: We'll be collecting some feedback from the community on some ideas we've got for long term plans. 

## Long-Term

These are things we plan to be working on **beyond the next 3 months**. We're very open to any help we can get on these if your goals would be advanced by making these things work better sooner.

- **Better examples**: Right now most of our iOS sample code is out of date. Particularly once updated codegen ships, we'll be working on some new sample apps to give some better examples of what you can do with the Apollo client.
- **Feedback suggested by community**: As noted in the "Short-Term" section, we're collecting some feedback from the community to flesh this section out. Once we've got some feedback, watch this space for updates. 
