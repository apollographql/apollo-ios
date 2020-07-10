
licenses(["notice"])

load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

package(
    default_visibility = ["//visibility:public"],
)

exports_files([
    "LICENSE",
])

objc_library(
    name = "SQLiteObjc",
    hdrs = [
        "Sources/SQLiteObjc/include/SQLiteObjc.h",
    ],
    includes = ["Sources/SQLiteObjc/include"],
    srcs = [
        "Sources/SQLiteObjc/fts3_tokenizer.h",
        "Sources/SQLiteObjc/SQLiteObjc.m",
    ],
    enable_modules = True,
    module_name = "SQLiteObjc",
    visibility = ["//:__pkg__"]
)

swift_library(
    name = "SQLite",
    module_name = "SQLite",
    swiftc_inputs = ["Sources/SQLite/SQLite.h"],
    copts = ["-import-objc-header", "$(location Sources/SQLite/SQLite.h)"],
    srcs = glob(["Sources/SQLite/**/*.swift"]),
    deps = [
        "SQLiteObjc",
    ],
)
