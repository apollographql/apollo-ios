load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

git_repository(
  name = "build_bazel_rules_apple",
  remote = "https://github.com/bazelbuild/rules_apple.git",
  commit = "12ac0738c56f8a15c714a7e09ec87a1bbdbcada9",
  shallow_since = "1592940289 -0700"
)

git_repository(
  name = "build_bazel_rules_swift",
  remote = "https://github.com/bazelbuild/rules_swift.git",
  commit = "8ecb09641ee0ba5efd971ffff8dd6cbee6ea7dd3",
  shallow_since = "1584545517 -0700"
)

git_repository(
  name = "build_bazel_apple_support",
  remote = "https://github.com/bazelbuild/apple_support.git",
  commit = "501b4afb27745c4813a88ffa28acd901408014e4",
  shallow_since = "1577729628 -0800"
)

git_repository(
  name = "bazel_skylib",
  remote = "https://github.com/bazelbuild/bazel-skylib.git",
  commit = "d35e8d7bc6ad7a3a53e9a1d2ec8d3a904cc54ff7",
  shallow_since = "1593183852 +0200"
)

new_git_repository(
  name = "Stencil",
  remote = "https://github.com/stencilproject/Stencil.git",
  commit = "124df01d3c5defdce07872fe1828c764bb969b38",
  shallow_since = "1590711283 +0200",
  build_file = "Stencil.BUILD",
)

new_git_repository(
  name = "PathKit",
  remote = "https://github.com/kylef/PathKit.git",
  commit = "73f8e9dca9b7a3078cb79128217dc8f2e585a511",
  shallow_since = "1553800707 +0000",
  build_file = "PathKit.BUILD",
)

new_git_repository(
  name = "SQLite",
  remote = "https://github.com/stephencelis/SQLite.swift.git",
  commit = "0a9893ec030501a3956bee572d6b4fdd3ae158a1",
  shallow_since = "1561117027 +0300",
  build_file = "SQLite.BUILD",
)

new_git_repository(
  name = "Starscream",
  remote = "https://github.com/daltoniam/Starscream",
  commit = "e6b65c6d9077ea48b4a7bdda8994a1d3c6969c8d",
  shallow_since = "1571027770 +0300",
  build_file = "Starscream.BUILD",
)

new_git_repository(
  name = "swift-tools-support-core",
  remote = "https://github.com/apple/swift-tools-support-core",
  commit = "25fc6eaec5d9f79b79419c5bdaa04e434cbcd568",
  shallow_since = "1593886283 -0700",
  build_file = "swift-tools-support-core.BUILD",
)

load(
  "@build_bazel_rules_swift//swift:repositories.bzl",
  "swift_rules_dependencies",
)

swift_rules_dependencies()

load(
  "@build_bazel_apple_support//lib:repositories.bzl",
  "apple_support_dependencies",
)

apple_support_dependencies()

load(
  "@com_google_protobuf//:protobuf_deps.bzl",
  "protobuf_deps",
)

protobuf_deps()

http_file(
  name = "xctestrunner",
  executable = 1,
  sha256 = "890faff3f6d5321712ffb7a09ba3614eabca93977221e86d058c7842fdbad6b6",
  urls = ["https://github.com/google/xctestrunner/releases/download/0.2.13/ios_test_runner.par"],
)
