---
title: API Reference
---

* [Apollo.framework](./api/Apollo/intest)
* [ApolloAPI.framework](./api/ApolloAPI/index)
* [ApolloCodegenLib.framework](./api/ApolloCodegenLib/index.md)
* [ApolloSQLite.framework](./api/ApolloSQLite/index.md)
* [ApolloWebSocket.framework](./api/ApolloWebSocket/index.md)

Our API reference is automatically generated directly from the inline comments in our code, so if you're adding something new, all you have to do is actually add doc comments and they'll show up here. 

See something missing documentation? Add docu-comments to the code, and open a pull request!

We're using [SourceDocs](https://github.com/eneko/SourceDocs) via our `SwiftScripts` package.  

To run the generator, `cd` into the `SwiftScripts` folder and run

```
swift run DocumentationGenerator
```
