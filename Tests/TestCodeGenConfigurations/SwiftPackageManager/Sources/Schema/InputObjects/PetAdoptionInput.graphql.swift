// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct PetAdoptionInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    ownerID: ID,
    petID: ID,
    humanName: GraphQLNullable<String> = nil,
    favoriteToy: String,
    isSpayedOrNeutered: Bool?,
    measurements: GraphQLNullable<MeasurementsInput> = nil
  ) {
    __data = InputDict([
      "ownerID": ownerID,
      "petID": petID,
      "humanName": humanName,
      "favoriteToy": favoriteToy,
      "isSpayedOrNeutered": isSpayedOrNeutered,
      "measurements": measurements
    ])
  }

  public var ownerID: ID {
    get { __data[dynamicMember: "ownerID"] }
    set { __data[dynamicMember: "ownerID"] = newValue }
  }

  public var petID: ID {
    get { __data[dynamicMember: "petID"] }
    set { __data[dynamicMember: "petID"] = newValue }
  }

  /// The given name the pet is called by its human.
  public var humanName: GraphQLNullable<String> {
    get { __data[dynamicMember: "humanName"] }
    set { __data[dynamicMember: "humanName"] = newValue }
  }

  public var favoriteToy: String {
    get { __data[dynamicMember: "favoriteToy"] }
    set { __data[dynamicMember: "favoriteToy"] = newValue }
  }

  public var isSpayedOrNeutered: Bool? {
    get { __data[dynamicMember: "isSpayedOrNeutered"] }
    set { __data[dynamicMember: "isSpayedOrNeutered"] = newValue }
  }

  public var measurements: GraphQLNullable<MeasurementsInput> {
    get { __data[dynamicMember: "measurements"] }
    set { __data[dynamicMember: "measurements"] = newValue }
  }
}
