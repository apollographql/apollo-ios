// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import MySwiftPackage

extension MyGraphQLSchema.Height: Mockable {
  public static let __mockFields = MockFields()

  public typealias MockValueCollectionType = Array<Mock<MyGraphQLSchema.Height>>

  public struct MockFields {
    @Field<Double>("centimeters") public var centimeters
    @Field<Int>("feet") public var feet
    @Field<Int>("inches") public var inches
    @Field<Int>("meters") public var meters
    @Field<GraphQLEnum<MyGraphQLSchema.RelativeSize>>("relativeSize") public var relativeSize
  }
}

public extension Mock where O == MyGraphQLSchema.Height {
  convenience init(
    centimeters: Double? = nil,
    feet: Int? = nil,
    inches: Int? = nil,
    meters: Int? = nil,
    relativeSize: GraphQLEnum<MyGraphQLSchema.RelativeSize>? = nil
  ) {
    self.init()
    self.centimeters = centimeters
    self.feet = feet
    self.inches = inches
    self.meters = meters
    self.relativeSize = relativeSize
  }
}
