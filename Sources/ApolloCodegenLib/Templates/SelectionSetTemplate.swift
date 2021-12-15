struct SelectionSetTemplate {

  let schema: IR.Schema

  func render() -> String {
    TemplateString(
    """

    """
    ).value
  }

}
