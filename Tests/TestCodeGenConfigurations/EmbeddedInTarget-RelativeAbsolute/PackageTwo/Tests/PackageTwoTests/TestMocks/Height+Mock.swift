// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PackageTwo

extension MySchemaModule.Height: Mockable {
  public static let __mockFields = MockFields()

  public typealias MockValueCollectionType = Array<Mock<MySchemaModule.Height>>

  public struct MockFields {
    @Field<Double>("centimeters") public var centimeters
    @Field<Int>("feet") public var feet
    @Field<Int>("inches") public var inches
    @Field<Int>("meters") public var meters
    @Field<GraphQLEnum<MySchemaModule.RelativeSize>>("relativeSize") public var relativeSize
  }
}

public extension Mock where O == MySchemaModule.Height {
  convenience init(
    centimeters: Double? = nil,
    feet: Int? = nil,
    inches: Int? = nil,
    meters: Int? = nil,
    relativeSize: GraphQLEnum<MySchemaModule.RelativeSize>? = nil
  ) {
    self.init()
    self.centimeters = centimeters
    self.feet = feet
    self.inches = inches
    self.meters = meters
    self.relativeSize = relativeSize
  }
}
