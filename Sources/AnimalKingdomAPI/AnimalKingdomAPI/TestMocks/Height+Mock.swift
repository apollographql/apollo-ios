// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import AnimalKingdomAPI

extension Height: Mockable {
  public static let __mockFields = MockFields()

  public typealias MockValueCollectionType = Array<Mock<Height>>

  public struct MockFields {
    @Field<Int>("centimeters") public var centimeters
    @Field<Int>("feet") public var feet
    @Field<Int>("inches") public var inches
    @Field<Int>("meters") public var meters
    @Field<GraphQLEnum<RelativeSize>>("relativeSize") public var relativeSize
  }
}

public extension Mock where O == Height {
  convenience init(
    centimeters: Int? = nil,
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