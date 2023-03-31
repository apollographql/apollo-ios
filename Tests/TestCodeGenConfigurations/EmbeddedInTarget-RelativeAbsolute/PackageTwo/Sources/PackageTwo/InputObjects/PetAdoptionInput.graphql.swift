// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension MySchemaModule {
  struct PetAdoptionInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      ownerID: MySchemaModule.ID,
      petID: MySchemaModule.ID,
      humanName: GraphQLNullable<String> = nil,
      favoriteToy: String,
      isSpayedOrNeutered: Bool?,
      measurements: GraphQLNullable<MySchemaModule.MeasurementsInput> = nil
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

    public var ownerID: MySchemaModule.ID {
      get { __data["ownerID"] }
      set { __data["ownerID"] = newValue }
    }

    public var petID: MySchemaModule.ID {
      get { __data["petID"] }
      set { __data["petID"] = newValue }
    }

    /// The given name the pet is called by its human.
    public var humanName: GraphQLNullable<String> {
      get { __data["humanName"] }
      set { __data["humanName"] = newValue }
    }

    public var favoriteToy: String {
      get { __data["favoriteToy"] }
      set { __data["favoriteToy"] = newValue }
    }

    public var isSpayedOrNeutered: Bool? {
      get { __data["isSpayedOrNeutered"] }
      set { __data["isSpayedOrNeutered"] = newValue }
    }

    public var measurements: GraphQLNullable<MySchemaModule.MeasurementsInput> {
      get { __data["measurements"] }
      set { __data["measurements"] = newValue }
    }
  }

}