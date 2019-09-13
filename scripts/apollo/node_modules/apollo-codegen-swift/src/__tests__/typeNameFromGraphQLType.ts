import {
  GraphQLString,
  GraphQLInt,
  GraphQLFloat,
  GraphQLBoolean,
  GraphQLID,
  GraphQLList,
  GraphQLNonNull,
  GraphQLScalarType
} from "graphql";

import { Helpers } from "../helpers";

describe("Swift code generation: Types", () => {
  let helpers: Helpers;

  beforeEach(() => {
    helpers = new Helpers({});
  });

  describe("#typeNameFromGraphQLType()", () => {
    it("should return String? for GraphQLString", () => {
      expect(helpers.typeNameFromGraphQLType(GraphQLString)).toBe("String?");
    });

    it("should return String for GraphQLNonNull(GraphQLString)", () => {
      expect(
        helpers.typeNameFromGraphQLType(new GraphQLNonNull(GraphQLString))
      ).toBe("String");
    });

    it("should return [String?]? for GraphQLList(GraphQLString)", () => {
      expect(
        helpers.typeNameFromGraphQLType(new GraphQLList(GraphQLString))
      ).toBe("[String?]?");
    });

    it("should return [String?] for GraphQLNonNull(GraphQLList(GraphQLString))", () => {
      expect(
        helpers.typeNameFromGraphQLType(
          new GraphQLNonNull(new GraphQLList(GraphQLString))
        )
      ).toBe("[String?]");
    });

    it("should return [String]? for GraphQLList(GraphQLNonNull(GraphQLString))", () => {
      expect(
        helpers.typeNameFromGraphQLType(
          new GraphQLList(new GraphQLNonNull(GraphQLString))
        )
      ).toBe("[String]?");
    });

    it("should return [String] for GraphQLNonNull(GraphQLList(GraphQLNonNull(GraphQLString)))", () => {
      expect(
        helpers.typeNameFromGraphQLType(
          new GraphQLNonNull(new GraphQLList(new GraphQLNonNull(GraphQLString)))
        )
      ).toBe("[String]");
    });

    it("should return [[String?]?]? for GraphQLList(GraphQLList(GraphQLString))", () => {
      expect(
        helpers.typeNameFromGraphQLType(
          new GraphQLList(new GraphQLList(GraphQLString))
        )
      ).toBe("[[String?]?]?");
    });

    it("should return [[String?]]? for GraphQLList(GraphQLNonNull(GraphQLList(GraphQLString)))", () => {
      expect(
        helpers.typeNameFromGraphQLType(
          new GraphQLList(new GraphQLNonNull(new GraphQLList(GraphQLString)))
        )
      ).toBe("[[String?]]?");
    });

    it("should return Int? for GraphQLInt", () => {
      expect(helpers.typeNameFromGraphQLType(GraphQLInt)).toBe("Int?");
    });

    it("should return Double? for GraphQLFloat", () => {
      expect(helpers.typeNameFromGraphQLType(GraphQLFloat)).toBe("Double?");
    });

    it("should return Bool? for GraphQLBoolean", () => {
      expect(helpers.typeNameFromGraphQLType(GraphQLBoolean)).toBe("Bool?");
    });

    it("should return GraphQLID? for GraphQLID", () => {
      expect(helpers.typeNameFromGraphQLType(GraphQLID)).toBe("GraphQLID?");
    });

    it("should return String? for a custom scalar type", () => {
      expect(
        helpers.typeNameFromGraphQLType(
          new GraphQLScalarType({ name: "CustomScalarType", serialize: String })
        )
      ).toBe("String?");
    });

    it("should return a passed through custom scalar type with the passthroughCustomScalars option", () => {
      helpers.options.passthroughCustomScalars = true;
      helpers.options.customScalarsPrefix = "";

      expect(
        helpers.typeNameFromGraphQLType(
          new GraphQLScalarType({ name: "CustomScalarType", serialize: String })
        )
      ).toBe("CustomScalarType?");
    });

    it("should return a passed through custom scalar type with a prefix with the customScalarsPrefix option", () => {
      helpers.options.passthroughCustomScalars = true;
      helpers.options.customScalarsPrefix = "My";

      expect(
        helpers.typeNameFromGraphQLType(
          new GraphQLScalarType({ name: "CustomScalarType", serialize: String })
        )
      ).toBe("MyCustomScalarType?");
    });
  });
});
