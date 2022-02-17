// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct PetAdoptionInput: InputObject {
  public private(set) var dict: InputDict

  public init(
    ownerID: ID,
    petID: ID,
    humanName: GraphQLNullable<String> = nil,
    favoriteToy: String,
    isSpayedOrNeutered: Bool?,
    measurements: GraphQLNullable<MeasurementsInput> = nil
  ) {
    dict = InputDict([
      "ownerID": ownerID,
      "petID": petID,
      "humanName": humanName,
      "favoriteToy": favoriteToy,
      "isSpayedOrNeutered": isSpayedOrNeutered,
      "measurements": measurements
    ])
  }

  public var ownerID: ID {
    get { dict["ownerID"] }
    set { dict["ownerID"] = newValue }
  }

  public var petID: ID {
    get { dict["petID"] }
    set { dict["petID"] = newValue }
  }

  public var humanName: GraphQLNullable<String> {
    get { dict["humanName"] }
    set { dict["humanName"] = newValue }
  }

  public var favoriteToy: String {
    get { dict["favoriteToy"] }
    set { dict["favoriteToy"] = newValue }
  }

  public var isSpayedOrNeutered: Bool? {
    get { dict["isSpayedOrNeutered"] }
    set { dict["isSpayedOrNeutered"] = newValue }
  }

  public var measurements: GraphQLNullable<MeasurementsInput> {
    get { dict["measurements"] }
    set { dict["measurements"] = newValue }
  }
}