struct ImportStatementTemplate {
  static let template: StaticString =
    """
    import ApolloAPI
    """

  static func render() -> String {
    template.description
  }
}
