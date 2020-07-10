licenses(["notice"])

load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

package(
    default_visibility = ["//visibility:public"],
)

exports_files([
    "LICENSE",
])

swift_library(
    name = "ApolloCore",
    module_name = "ApolloCore",
    srcs = ["//Sources:ApolloCoreFiles"],
    deps = []
)

swift_library(
    name = "Apollo",
    module_name = "Apollo",
    srcs = ["//Sources:ApolloFiles"],
    deps = ["ApolloCore"]
)

swift_library(
    name = "ApolloCodegenLib",
    module_name = "ApolloCodegenLib",
    srcs = ["//Sources:ApolloCodegenLibFiles"],
    deps = [
        "ApolloCore",
        "@Stencil//:Stencil",
    ]
)

swift_library(
    name = "ApolloSQLite",
    module_name = "ApolloSQLite",
    srcs = ["//Sources:ApolloSQLiteFiles"],
    deps = [
        "Apollo",
        "@SQLite//:SQLite",
    ]
)

swift_library(
    name = "ApolloWebSocket",
    module_name = "ApolloWebSocket",
    srcs = ["//Sources:ApolloWebSocketFiles"],
    deps = [
        "Apollo",
        "ApolloCore",
        "@Starscream//:Starscream",
    ]
)
