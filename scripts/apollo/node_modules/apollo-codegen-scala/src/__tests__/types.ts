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

import { loadSchema } from "apollo-codegen-core/lib/loading";
const schema = loadSchema(
  require.resolve("../../../../__fixtures__/starwars/schema.json")
);

import { typeNameFromGraphQLType } from "../types";

describe("Scala code generation: Types", function() {
  describe("#typeNameFromGraphQLType()", function() {
    test("should return OptionalResult[String] for GraphQLString", function() {
      expect(typeNameFromGraphQLType({ options: {} }, GraphQLString)).toBe(
        "com.apollographql.scalajs.OptionalValue[String]"
      );
    });

    test("should return String for GraphQLNonNull(GraphQLString)", function() {
      expect(
        typeNameFromGraphQLType(
          { options: {} },
          new GraphQLNonNull(GraphQLString)
        )
      ).toBe("String");
    });

    test("should return OptionalResult[Array[OptionalResult[String]]] for GraphQLList(GraphQLString)", function() {
      expect(
        typeNameFromGraphQLType({ options: {} }, new GraphQLList(GraphQLString))
      ).toBe(
        "com.apollographql.scalajs.OptionalValue[scala.scalajs.js.Array[com.apollographql.scalajs.OptionalValue[String]]]"
      );
    });

    test("should return Array[OptionalResult[String]] for GraphQLNonNull(GraphQLList(GraphQLString))", function() {
      expect(
        typeNameFromGraphQLType(
          { options: {} },
          new GraphQLNonNull(new GraphQLList(GraphQLString))
        )
      ).toBe(
        "scala.scalajs.js.Array[com.apollographql.scalajs.OptionalValue[String]]"
      );
    });

    test("should return OptionalResult[Array[String]] for GraphQLList(GraphQLNonNull(GraphQLString))", function() {
      expect(
        typeNameFromGraphQLType(
          { options: {} },
          new GraphQLList(new GraphQLNonNull(GraphQLString))
        )
      ).toBe(
        "com.apollographql.scalajs.OptionalValue[scala.scalajs.js.Array[String]]"
      );
    });

    test("should return Array[String] for GraphQLNonNull(GraphQLList(GraphQLNonNull(GraphQLString)))", function() {
      expect(
        typeNameFromGraphQLType(
          { options: {} },
          new GraphQLNonNull(new GraphQLList(new GraphQLNonNull(GraphQLString)))
        )
      ).toBe("scala.scalajs.js.Array[String]");
    });

    test("should return OptionalResult[Array[OptionalResult[Array[OptionalResult[String]]]]] for GraphQLList(GraphQLList(GraphQLString))", function() {
      expect(
        typeNameFromGraphQLType(
          { options: {} },
          new GraphQLList(new GraphQLList(GraphQLString))
        )
      ).toBe(
        "com.apollographql.scalajs.OptionalValue[scala.scalajs.js.Array[com.apollographql.scalajs.OptionalValue[scala.scalajs.js.Array[com.apollographql.scalajs.OptionalValue[String]]]]]"
      );
    });

    test("should return OptionalResult[Array[Array[OptionalResult[String]]]] for GraphQLList(GraphQLNonNull(GraphQLList(GraphQLString)))", function() {
      expect(
        typeNameFromGraphQLType(
          { options: {} },
          new GraphQLList(new GraphQLNonNull(new GraphQLList(GraphQLString)))
        )
      ).toBe(
        "com.apollographql.scalajs.OptionalValue[scala.scalajs.js.Array[scala.scalajs.js.Array[com.apollographql.scalajs.OptionalValue[String]]]]"
      );
    });

    test("should return OptionalResult[Int] for GraphQLInt", function() {
      expect(typeNameFromGraphQLType({ options: {} }, GraphQLInt)).toBe(
        "com.apollographql.scalajs.OptionalValue[Int]"
      );
    });

    test("should return OptionalResult[Double] for GraphQLFloat", function() {
      expect(typeNameFromGraphQLType({ options: {} }, GraphQLFloat)).toBe(
        "com.apollographql.scalajs.OptionalValue[Double]"
      );
    });

    test("should return OptionalResult[Boolean] for GraphQLBoolean", function() {
      expect(typeNameFromGraphQLType({ options: {} }, GraphQLBoolean)).toBe(
        "com.apollographql.scalajs.OptionalValue[Boolean]"
      );
    });

    test("should return OptionalResult[String] for GraphQLID", function() {
      expect(typeNameFromGraphQLType({ options: {} }, GraphQLID)).toBe(
        "com.apollographql.scalajs.OptionalValue[String]"
      );
    });

    test("should return OptionalResult[String] for a custom scalar type", function() {
      expect(
        typeNameFromGraphQLType(
          { options: {} },
          new GraphQLScalarType({ name: "CustomScalarType", serialize: String })
        )
      ).toBe("com.apollographql.scalajs.OptionalValue[String]");
    });

    test("should return a passed through custom scalar type with the passthroughCustomScalars OptionalResult", function() {
      expect(
        typeNameFromGraphQLType(
          {
            options: { passthroughCustomScalars: true, customScalarsPrefix: "" }
          },
          new GraphQLScalarType({ name: "CustomScalarType", serialize: String })
        )
      ).toBe("com.apollographql.scalajs.OptionalValue[CustomScalarType]");
    });

    test("should return a passed through custom scalar type with a prefix with the customScalarsPrefix OptionalResult", function() {
      expect(
        typeNameFromGraphQLType(
          {
            options: {
              passthroughCustomScalars: true,
              customScalarsPrefix: "My"
            }
          },
          new GraphQLScalarType({ name: "CustomScalarType", serialize: String })
        )
      ).toBe("com.apollographql.scalajs.OptionalValue[MyCustomScalarType]");
    });
  });
});
