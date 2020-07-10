load("@build_bazel_rules_swift//swift:swift.bzl", "swift_binary")

swift_binary(
    name = "SchemaDownload",
    srcs = glob(["Sources/SchemaDownload/**/*.swift"]),
    deps = [
        "//:ApolloCodegenLib",
    ],
)

swift_binary(
    name = "Codegen",
    srcs = glob(["Sources/Codegen/**/*.swift"]),
    deps = [
        "//:ApolloCodegenLib",
        "@swift-tools-support-core//:TSCUtility",
    ],
)

swift_binary(
    name = "DocumentGenerator",
    srcs = glob(["Sources/DocumentGenerator/**/*.swift"]),
    deps = [
        "//:ApolloCodegenLib",
        "@swift-tools-support-core//:TSCUtility",
    ],
)
