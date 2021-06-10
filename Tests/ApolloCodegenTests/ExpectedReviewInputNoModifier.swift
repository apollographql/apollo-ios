import ApolloAPI

/// The input object sent when someone is creating a new review
struct ReviewInputNoModifier: Codable, Equatable, Hashable {
  /// 0-5 stars
  var stars: Int
  /// Comment about the movie, optional
  var commentary: GraphQLOptional<String>
  /// Favorite color, optional
  var favoriteColor: GraphQLOptional<ColorInput>
  
  enum CodingKeys: String, CodingKey {
    case stars
    case commentary
    case favoriteColor
  }
  
  /// Designated initializer
  ///
  /// - Parameters:
  ///   - stars: 0-5 stars
  ///   - commentary: Comment about the movie, optional
  ///   - favoriteColor: Favorite color, optional
  init(stars: Int,
       commentary: GraphQLOptional<String>,
       favoriteColor: GraphQLOptional<ColorInput>) {
    self.stars = stars
    self.commentary = commentary
    self.favoriteColor = favoriteColor
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: ReviewInputNoModifier.CodingKeys.self)
    
    try container.encode(self.stars, forKey: .stars)
    try container.encodeGraphQLOptional(self.commentary, forKey: .commentary)
    try container.encodeGraphQLOptional(self.favoriteColor, forKey: .favoriteColor)
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ReviewInputNoModifier.CodingKeys.self)
    
    self.stars = try container.decode(Int.self, forKey: .stars)
    self.commentary = try container.decodeGraphQLOptional(forKey: .commentary)
    self.favoriteColor = try container.decodeGraphQLOptional(forKey: .favoriteColor)
  }
}
