---
title: API Reference
description: ''
---

## [Apollo.framework](../api/Apollo/README/)
## [ApolloSQLite.framework](../api/ApolloSQLite/README/)
## [ApolloWebSocket.framework](../api/ApolloWebSocket/README/)

Our API reference is automatically generated directly from the inline comments in our code, so if you're adding something new, all you have to do is actually add doc comments and they'll show up here. 

See something missing documentation? Add docu-comments to the code, and open a pull request!

To run the document generator, make sure you have [SourceDocs](https://github.com/eneko/SourceDocs) installed locally. The easiest way is via HomeBrew: 

```
brew install sourcedocs
```

>**NOTE**: We are currently depending on functionality added in [this PR](https://github.com/eneko/SourceDocs/pull/20), so if that's not merged, and pushed as a new version to Homebrew, you'll need to check out from source. 

## Homebrew Instructions

To generate docs for the main `Apollo` project, `cd` into the source root and run: 

```
sourcedocs generate \
    --output-folder "docs/source/api/Apollo" \
    --link-beginning "../" \
    --link-ending "/" \
    -- \
    -scheme Apollo \
    -workspace Apollo.xcworkspace
```

To generate docs for the `ApolloSQLite` project, `cd` into the source root and run: 

```
sourcedocs generate \
    --output-folder "docs/source/api/ApolloSQLite" \
    --link-beginning "../" \
    --link-ending "/" \
    -- \
    -scheme ApolloSQLite \
    -workspace Apollo.xcworkspace
```

To generate for docs the `ApolloWebSocket` project, `cd` into the source root and run: 

```
sourcedocs generate \
    --output-folder "docs/source/api/ApolloWebSocket" \
    --link-beginning "../" \
    --link-ending "/" \
    -- \
    -scheme ApolloWebSocket \
    -workspace Apollo.xcworkspace
```

## From Source Instructions

Commands are essentially the same except for the following differences: 

- All commands should start with `swift run sourcedocs` instead of just `sourcedocs`
- Add an `--input-folder` parameter with the full path to the Apollo `SRCROOT` as its value
- Make the value of `--output-folder`'s parameter use a full path rather than a relative one.

For example, this will run the generator for `ApolloWebSocket`:

``` 
swift run sourcedocs generate \
    --input-folder "/Users/[you]/apollo-ios" \
    --output-folder "/Users/[you]/apollo-ios/docs/source/api/ApolloWebSocket" \
    --link-beginning "../" \
    --link-ending "/" \
    -- \
    -scheme "ApolloWebSocket" \
    -workspace "Apollo.xcworkspace"
```