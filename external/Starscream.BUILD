
licenses(["notice"])

load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

package(
    default_visibility = ["//visibility:public"],
)

exports_files([
    "LICENSE",
])

swift_library(
    name = "Starscream",
    module_name = "Starscream",
    srcs = glob(["Sources/Starscream/**/*.swift"]),
    deps = [],
)
