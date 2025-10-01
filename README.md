<header>
  <div align="center">
    <a href="https://www.apollographql.com?utm_medium=github&utm_source=apollographql_apollo-client&utm_campaign=readme"><img src="https://raw.githubusercontent.com/apollographql/apollo-client-devtools/main/assets/apollo-wordmark.svg" height="100" alt="Apollo Logo"></a>
  </div>
  <h1 align="center">Apollo iOS</h1>
 
**The industry-leading GraphQL client in Swift for iOS, macOS, watchOS, tvOS, and more.** Apollo iOS delivers powerful caching, robust code generation, and intuitive APIs to accelerate your app development.

➡️ [**Get Started with Apollo iOS →**](https://www.apollographql.com/docs/ios/get-started?utm_source=github&utm_medium=apollographql_apollo-client&utm_campaign=readme)

  <div align="center">
  <br><br>

  <a href="https://github.com/apollographql/apollo-ios-dev/actions/workflows/ci-tests.yml">
    <img src="https://github.com/apollographql/apollo-ios-dev/actions/workflows/ci-tests.yml/badge.svg?branch=main" alt="GitHub Action Status">
  </a>
  <a href="https://raw.githubusercontent.com/apollographql/apollo-ios/main/LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-lightgrey.svg?maxAge=2592000" alt="MIT license">
  </a>
  <a href="Platforms">
    <img src="https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-333333.svg" alt="Supported Platforms: iOS, macOS, tvOS, watchOS" />
  </a><br><br>

  <a href="https://github.com/apple/swift">
    <img src="https://img.shields.io/badge/Swift-5.7-orange.svg" alt="Swift 5.7 supported">
  </a>
  <a href="https://swift.org/package-manager/">
    <img src="https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square" alt="Swift Package Manager compatible">
  </a>  
</p>

  </div>
</header>

## ❓ Why Choose Apollo iOS?

✅ Intuitive caching - Intelligent in-memory or SQLite out of the box<br>
✅ Highly configurable code generation - The days of hand-writing models for network responses are over!<br>
✅ Opinionated - Leads users down the "pit of success" and encourages good practices by default<br>
✅ Production-tested - Powers countless apps worldwide that serve millions of end users<br>

## 🚀 Quick Start
 
### Add Apollo iOS to your dependencies list

```swift title="Package.swift"
dependencies: [
    .package(
        url: "https://github.com/apollographql/apollo-ios.git",
        .upToNextMajor(from: "1.0.0")
    ),
],
```

### Link the Apollo product to your package target

Any targets in your application that will use `ApolloClient` need to have a dependency on the `Apollo` product.

```swift title="Package.swift"
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "Apollo", package: "apollo-ios"),
    ]
)
```

> **Note:** Targets that only use Apollo's generated models don't need to be linked to the `Apollo` product.

## 💡 Resources

| Resource | Description | Link |
| ----- | ----- | ----- |
| **Getting Started Guide** | Complete setup and first query | [Start Here →](https://www.apollographql.com/docs/ios/get-started?utm_source=github&utm_medium=apollographql_apollo-client&utm_campaign=readme) |
| **Full Documentation** | Comprehensive guides and examples | [Read Docs →](https://www.apollographql.com/docs/ios?utm_source=github&utm_medium=apollographql_apollo-client&utm_campaign=readme) |
| **API Reference** | Complete API documentation | [Browse API →](https://www.apollographql.com/docs/react/api/apollo-client?utm_source=github&utm_medium=apollographql_apollo-client&utm_campaign=readme) |
| **VS Code Extension** | Enhanced development experience | [Install Extension →](https://marketplace.visualstudio.com/items?itemName=apollographql.vscode-apollo) |
| **DevTools** | Debug your GraphQL apps | [Chrome](https://chrome.google.com/webstore/detail/apollo-client-devtools/jdkknkkbebbapilgoeccciglkfbmbnfm) \| [Firefox](https://addons.mozilla.org/en-US/firefox/addon/apollo-developer-tools/) |
| **Free Course** | Apollo iOS and Swift: Codegen and Queries | [Take Course →](https://www.apollographql.com/tutorials/apollo-ios-swift-part1?utm_source=github&utm_medium=apollographql_apollo-client&utm_campaign=readme) |

## 💬 Get Support

**Need help?** We're here for you:

* [**Community Forum**](https://community.apollographql.com?utm_source=github&utm_medium=apollographql_apollo-client&utm_campaign=readme) \- Q\&A and discussions  
* [**GraphQL Discord**](https://discord.graphql.org) \- Real-time chat with the community

## 🧑‍🚀 About Apollo 

Deliver tomorrow's roadmap today with our comprehensive suite of API orchestration tools:

* [**Apollo Client**](https://www.apollographql.com/docs/react?utm_source=github&utm_medium=apollographql_apollo-client&utm_campaign=readme) \- Type-safe apps with GraphQL-powered on-device caching ([React](https://www.apollographql.com/docs/react?utm_medium=github&utm_source=apollographql_apollo-client&utm_campaign=readme), [iOS](https://www.apollographql.com/docs/ios?utm_medium=github&utm_source=apollographql_apollo-client&utm_campaign=readme), [Kotlin](https://www.apollographql.com/docs/kotlin?utm_medium=github&utm_source=apollographql_apollo-client&utm_campaign=readme))  
* [**Apollo Connectors**](https://www.apollographql.com/graphos/apollo-connectors?utm_source=github&utm_medium=apollographql_apollo-client&utm_campaign=readme) \- Compose all your GraphQL and REST APIs into one GraphQL endpoint  
* [**Apollo MCP Server**](https://www.apollographql.com/apollo-mcp-server?utm_source=github&utm_medium=apollographql_apollo-client&utm_campaign=readme) \- AI needs APIs. The fastest way to ship reliable AI experiences  
* [**Apollo Router**](https://www.apollographql.com/docs/router?utm_source=github&utm_medium=apollographql_apollo-client&utm_campaign=readme) \- Scale your APIs seamlessly with GraphQL Federation, Security, Auth, and more  
* [**GraphOS**](https://www.apollographql.com/graphos?utm_source=github&utm_medium=apollographql_apollo-client&utm_campaign=readme) \- Deploy, manage, govern, and explore your APIs ([start for free, no credit card needed](https://www.apollographql.com/pricing?utm_medium=github&utm_source=apollographql_apollo-client&utm_campaign=readme))

[**Explore the Complete Apollo Platform →**](https://www.apollographql.com/?utm_source=github&utm_medium=apollographql-_apollo-client&utm_campaign=readme)

## 🛠️ Maintained by

|Name|Username|
|---|---|
|Anthony Miller|[@anthonymdev](https://github.com/anthonymdev)|
|Calvin Cestari|[@calvincestari](https://github.com/calvincestari)|
|Jeff Auriemma|[@bignimbus](https://github.com/bignimbus)|
|Zach FettersMoore|[@bobafetters](https://github.com/bobafetters)|

## 🗺️ Roadmap

We regularly update our [public roadmap](https://github.com/apollographql/apollo-ios/blob/main/ROADMAP.md) with the status of our work-in-progress and upcoming features.

## 📣 Tell us what you think

| ☑️  Apollo iOS User Survey |
| :----- |
| What do you like best about Apollo iOS? What needs to be improved? Please tell us by taking a [one-minute survey](https://docs.google.com/forms/d/e/1FAIpQLSczNDXfJne3ZUOXjk9Ursm9JYvhTh1_nFTDfdq3XBAFWCzplQ/viewform?usp=pp_url&entry.1170701325=Apollo+iOS&entry.204965213=Readme). Your responses will help us understand Apollo iOS usage and allow us to serve you better. |

## 🗓️ Events

Join these live events to meet other GraphQL users and learn more: 

🎪 [**GraphQL Summit 2025**](https://summit.graphql.com?utm_source=github&utm_medium=apollographql_apollo-client&utm_campaign=readme)  
 Oct 6-8, 2025 • San Francisco  
 *1000+ engineers, talks, workshops, and office hours*

🌟 [**GraphQLConf 2025**](https://graphql.org/conf/2025)
 Sep 8-10, 2025 • Amsterdam  
 *Celebrating 10 Years of GraphQL*

[**View All Events →**](https://www.apollographql.com/events?utm_source=github&utm_medium=apollographql_apollo-client&utm_campaign=readme)

## 🏆 Contributing

Thank you for your interest in submitting a Pull Request to Apollo iOS!  Read our [guidelines](https://github.com/apollographql/apollo-ios-dev/blob/main/CONTRIBUTING.md) first, and don't hesitate to get in touch.

**New to open source?** Check out our [**Good First Issues**](https://github.com/apollographql/apollo-ios/labels/good%20first%20issue) to get started.

## 🤝 Code of Conduct

Please read our [Code of Conduct](https://community.apollographql.com/faq). This applies to any space run by Apollo, including our GitHub repositories and the Community Forum. The Code of Conduct reflects our commitment to making the Apollo Community a welcoming and safe space in which individuals can interact.

## 🪪 License

Source code in this repository is available under the terms of the MIT License.  Read the full text [here](https://github.com/apollographql/apollo-ios/blob/main/LICENSE).
