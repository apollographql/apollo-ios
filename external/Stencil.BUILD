
licenses(["notice"])

load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

package(
    default_visibility = ["//visibility:public"],
)

exports_files([
    "LICENSE",
])

swift_library(
    name = "Stencil",
    module_name = "Stencil",
    srcs = glob(["Sources/*.swift"]),
    deps = [
        "@PathKit//:PathKit",
    ]
)
