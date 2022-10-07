import ArgumentParser

/// Shared group of arguments that are sent by various automation tools, such as Xcode, but are
/// ignored from input.
struct IgnoredOptions: ParsableArguments {
  @Option(
    name: .long,
    help: ArgumentHelp(
      "Ignored - used by Xcode only.",
      discussion: """
        Xcode will automatically include this option when calling any plugin command to pass the
        target name of the Swift package. This option is ignored and is not intended to be sent
        by anything other than Xcode.
        """,
      visibility: .hidden
    )
  )
  var target: String?
}
