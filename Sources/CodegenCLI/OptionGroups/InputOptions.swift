import ArgumentParser

#warning("TODO - We should be able to pass `--verbose` to set the `CodegenLogger.level = .debug` instead of the default of `.warning`.")

/// Shared group of common arguments used in commands for input parameters.
struct InputOptions: ParsableArguments {
  @Option(
    name: .shortAndLong,
    help: """
      Read the configuration from a file at the path. --string overrides this option if used \
      together.
      """
  )
  var path: String = Constants.defaultFilePath

  @Option(
    name: .shortAndLong,
    help: "Configuration string in JSON format. This option overrides --path."
  )
  var string: String?
}
