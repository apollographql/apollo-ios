// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct PetAdoptionInput: InputObject {
  public private(set) var data: InputDict

  public init(_ data: InputDict) {
    self.data = data
  }

  public init(
    ownerID: ID,
    petID: ID,
    humanName: GraphQLNullable<String> = nil,
    favoriteToy: String,
    isSpayedOrNeutered: Bool?,
    measurements: GraphQLNullable<MeasurementsInput> = nil
  ) {
    data = InputDict([
      "ownerID": ownerID,
      "petID": petID,
      "humanName": humanName,
      "favoriteToy": favoriteToy,
      "isSpayedOrNeutered": isSpayedOrNeutered,
      "measurements": measurements
    ])
  }

  public var ownerID: ID {
    get { data.ownerID }
    set { data.ownerID = newValue }
  }

  public var petID: ID {
    get { data.petID }
    set { data.petID = newValue }
  }

  public var humanName: GraphQLNullable<String> {
    get { data.humanName }
    set { data.humanName = newValue }
  }

  public var favoriteToy: String {
    get { data.favoriteToy }
    set { data.favoriteToy = newValue }
  }

  public var isSpayedOrNeutered: Bool? {
    get { data.isSpayedOrNeutered }
    set { data.isSpayedOrNeutered = newValue }
  }

  public var measurements: GraphQLNullable<MeasurementsInput> {
    get { data.measurements }
    set { data.measurements = newValue }
  }
}