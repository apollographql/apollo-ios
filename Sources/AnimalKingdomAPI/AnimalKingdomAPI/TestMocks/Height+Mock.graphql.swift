// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import AnimalKingdomAPI

public class Height: MockObject {
  public static let objectType: Object = AnimalKingdomAPI.Objects.Height
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Height>>

  public struct MockFields {
    @Field<Double>("centimeters") public var centimeters
    @Field<Int>("feet") public var feet
    @Field<Int>("inches") public var inches
    @Field<Int>("meters") public var meters
    @Field<GraphQLEnum<AnimalKingdomAPI.RelativeSize>>("relativeSize") public var relativeSize
  }
}

public extension Mock where O == Height {
  convenience init(
    centimeters: Double? = nil,
    feet: Int? = nil,
    inches: Int? = nil,
    meters: Int? = nil,
    relativeSize: GraphQLEnum<AnimalKingdomAPI.RelativeSize>? = nil
  ) {
    self.init()
    _setScalar(centimeters, for: \.centimeters)
    _setScalar(feet, for: \.feet)
    _setScalar(inches, for: \.inches)
    _setScalar(meters, for: \.meters)
    _setScalar(relativeSize, for: \.relativeSize)
  }
}
