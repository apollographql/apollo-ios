
licenses(["notice"])

load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

package(
    default_visibility = ["//visibility:public"],
)

exports_files([
    "LICENSE",
])

swift_library(
    name = "PathKit",
    module_name = "PathKit",
    srcs = glob(["Sources/*.swift"]),
)
