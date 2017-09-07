import PackageDescription

let package = Package(
    name: "Apollo",
    targets: [
        Target(name: "Apollo"),
    ],
    exclude: ["Tests", "Sources/ApolloSQLite"]
)
