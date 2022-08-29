import Foundation

extension Process {
  static func HandleErrorTermination(_ process: Process) {
    if process.terminationStatus != 0 {
      print("""
      Hint: You may need to include the --disable-sandbox or --allow-writing-to-directory flag
      to allow Apollo code generation to write to your source directory. This is needed when
      initializing a configuration file or generating the Swift code for your GraphQL schema and
      operations. This option should be included before the name of the plugin command to execute.

      Example:
      swift package --disable-sandbox apollo-generate

      If you are using --disable-sandbox and code generation still fails, please make a bug report at
      https://github.com/apollographql/apollo-ios
      """)
    }
  }
}
