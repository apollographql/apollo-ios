
licenses(["notice"])

load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

package(
    default_visibility = ["//visibility:public"],
)

exports_files([
    "LICENSE",
])

cc_library(
    name = "TSCclibc",
    hdrs = glob(["Sources/TSCclibc/include/*.h"]),
    includes = ["Sources/TSCclibc/include"],
    srcs = [
        "Sources/TSCclibc/libc.c",
        "Sources/TSCclibc/process.c",
    ],
    visibility = ["//:__pkg__"]
)

swift_library(
    name = "TSCLibc",
    module_name = "TSCLibc",
    srcs = glob(["Sources/TSCLibc/**/*.swift"]),
    deps = [
        "TSCclibc",
    ],
)

swift_library(
    name = "TSCBasic",
    module_name = "TSCBasic",
    srcs = glob(["Sources/TSCBasic/**/*.swift"]),
    deps = [
        "TSCLibc",
    ],
)

swift_library(
    name = "TSCUtility",
    module_name = "TSCUtility",
    srcs = glob(["Sources/TSCUtility/**/*.swift"]),
    deps = [
        "TSCBasic",
    ],
)
