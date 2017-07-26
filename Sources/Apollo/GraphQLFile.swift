public class GraphQLFile {
  let fieldName: String
  let originalName: String
  let mimeType: String
  let data: Data
  
  public init(fieldName: String, originalName: String, mimeType: String, data: Data) {
    self.fieldName = fieldName
    self.originalName = originalName
    self.mimeType = mimeType
    self.data = data
  }
}
