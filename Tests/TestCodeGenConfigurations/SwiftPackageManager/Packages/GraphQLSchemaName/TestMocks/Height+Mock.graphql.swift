// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphQLSchemaName

public class Height: MockObject {
  public static let objectType: Object = GraphQLSchemaName.Objects.Height
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Height>>

  public struct MockFields {
    @Field<Double>("centimeters") public var centimeters
    @Field<Int>("feet") public var feet
    @Field<Int>("inches") public var inches
    @Field<Int>("meters") public var meters
    @Field<GraphQLEnum<GraphQLSchemaName.RelativeSize>>("relativeSize") public var relativeSize
  }
}

public extension Mock where O == Height {
  convenience init(
    centimeters: Double? = nil,
    feet: Int? = nil,
    inches: Int? = nil,
    meters: Int? = nil,
    relativeSize: GraphQLEnum<GraphQLSchemaName.RelativeSize>? = nil
  ) {
    self.init()
    _set(centimeters, for: \.centimeters)
    _set(feet, for: \.feet)
    _set(inches, for: \.inches)
    _set(meters, for: \.meters)
    _set(relativeSize, for: \.relativeSize)
  }
}
