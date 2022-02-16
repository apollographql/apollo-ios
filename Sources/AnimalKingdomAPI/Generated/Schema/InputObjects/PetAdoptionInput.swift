// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

struct PetAdoptionInput: InputObject {
  private(set) public var dict: InputDict

  init(
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

  var ownerID: ID {
    get { dict["ownerID"] }
    set { dict["ownerID"] = newValue }
  }

  var petID: ID {
    get { dict["petID"] }
    set { dict["petID"] = newValue }
  }

  var humanName: GraphQLNullable<String> {
    get { dict["humanName"] }
    set { dict["humanName"] = newValue }
  }

  var favoriteToy: String {
    get { dict["favoriteToy"] }
    set { dict["favoriteToy"] = newValue }
  }

  var isSpayedOrNeutered: Bool? {
    get { dict["isSpayedOrNeutered"] }
    set { dict["isSpayedOrNeutered"] = newValue }
  }

  var measurements: GraphQLNullable<MeasurementsInput> {
    get { dict["measurements"] }
    set { dict["measurements"] = newValue }
  }
}