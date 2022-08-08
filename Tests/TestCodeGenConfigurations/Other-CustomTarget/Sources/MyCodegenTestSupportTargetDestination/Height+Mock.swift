// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import MyCodegenTargetDestination

public class Height: MockObject {
  public static let objectType: Object = MyCodegenTargetDestination.Objects.Height
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Height>>

  public struct MockFields {
    @Field<Double>("centimeters") public var centimeters
    @Field<Int>("feet") public var feet
    @Field<Int>("inches") public var inches
    @Field<Int>("meters") public var meters
    @Field<GraphQLEnum<RelativeSize>>("relativeSize") public var relativeSize
  }
}

public extension Mock where O == Height {
  convenience init(
    centimeters: Double? = nil,
    feet: Int? = nil,
    inches: Int? = nil,
    meters: Int? = nil,
    relativeSize: GraphQLEnum<RelativeSize>? = nil
  ) {
    self.init()
    self.centimeters = centimeters
    self.feet = feet
    self.inches = inches
    self.meters = meters
    self.relativeSize = relativeSize
  }
}
