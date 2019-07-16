---
title: API Reference
description: ''
---

## [Apollo.framework](api/Apollo/README.md)
## [ApolloSQLite.framework](api/ApolloSQLite/README.md)
## [ApolloWebSocket.framework](api/ApolloWebSocket/README.md)

Our API reference is automatically generated directly from the inline comments in our code, so if you're adding something new, all you have to do is actually add doc comments and they'll show up here. 

See something missing documentation? Add docu-comments to the code, and open a pull request!

To run the document generator, make sure you have [SourceDocs](https://github.com/eneko/SourceDocs) installed locally. The easiest way is via HomeBrew: 

```
brew install sourcedocs
```

To generate docs for the main `Apollo` project, `cd` into the source root and run: 

```
sourcedocs generate --output-folder "docs/source/api/Apollo" -- -scheme Apollo -workspace Apollo.xcworkspace
```

To generate docs for the `ApolloSQLite` project, `cd` into the source root and run: 

```
sourcedocs generate --output-folder "docs/source/api/ApolloSQLite" -- -scheme ApolloSQLite -workspace Apollo.xcworkspace
```

To generate for docs the `ApolloWebSocket` project, `cd` into the source root and run: 

```
sourcedocs generate --output-folder "docs/source/api/ApolloWebSocket" -- -scheme ApolloWebSocket -workspace Apollo.xcworkspace
```
