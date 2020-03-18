import Apollo

/// The input object sent when someone is creating a new review
public struct ReviewInput {
  
  /// 0-5 stars
  public let stars: Int
  /// Comment about the movie, optional
  public let commentary: GraphQLOptional<String>
  /// Favorite color, optional
  public let favoriteColor: GraphQLOptional<ColorInput>
  
  public enum CodingKeys: String, CodingKey {
    case stars
    case commentary
    case favoriteColor
  }
  
  public init(stars: Int,
              commentary: GraphQLOptional<String>,
              favoriteColor: GraphQLOptional<ColorInput>) {
    self.stars = stars
    self.commentary = commentary
    self.favoriteColor = favoriteColor
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: ReviewInput.CodingKeys.self)
    
    try container.encode(self.stars, forKey: .stars)
    try container.encodeGraphQLOptional(self.commentary, forKey: .commentary)
    try container.encodeGraphQLOptional(self.favoriteColor, forKey: .favoriteColor)
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ReviewInput.CodingKeys.self)
    
    self.stars = try container.decode(Int.self, forKey: .stars)
    self.commentary = try container.decodeGraphQLOptional(forKey: .commentary)
    self.favoriteColor = try container.decodeGraphQLOptional(forKey: .favoriteColor)
  }
}
