import Foundation

extension Process {
  static func HandleErrorTermination(_ process: Process) {
    if process.terminationStatus != 0 {
      print("""
      Hint: You may need to use the --disable-sandbox or --allow-writing-to-package-directory flag
      to allow Apollo code generation to write to the package directory. This is needed when
      initializing a configuration file or generating the Swift code for your GraphQL schema and
      operations.
      """)
    }
  }
}
