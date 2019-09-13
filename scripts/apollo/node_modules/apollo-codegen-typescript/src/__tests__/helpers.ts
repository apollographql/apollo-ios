import {
  GraphQLString,
  GraphQLInt,
  GraphQLFloat,
  GraphQLBoolean,
  GraphQLID,
  GraphQLNonNull,
  GraphQLList,
  GraphQLScalarType
} from "graphql";

import * as t from "@babel/types";

import { createTypeFromGraphQLTypeFunction } from "../helpers";

const typeFromGraphQLType = createTypeFromGraphQLTypeFunction({
  passthroughCustomScalars: false,
  useReadOnlyTypes: false
});

function nullableType(type: t.TSType) {
  return t.TSUnionType([type, t.TSNullKeyword()]);
}

describe("Typescript typeAnnotationFromGraphQLType", () => {
  test("String", () => {
    expect(typeFromGraphQLType(GraphQLString)).toMatchObject(
      nullableType(t.TSStringKeyword())
    );
  });

  test("Int", () => {
    expect(typeFromGraphQLType(GraphQLInt)).toMatchObject(
      nullableType(t.TSNumberKeyword())
    );
  });

  test("Float", () => {
    expect(typeFromGraphQLType(GraphQLFloat)).toMatchObject(
      nullableType(t.TSNumberKeyword())
    );
  });

  test("Boolean", () => {
    expect(typeFromGraphQLType(GraphQLBoolean)).toMatchObject(
      nullableType(t.TSBooleanKeyword())
    );
  });

  test("ID", () => {
    expect(typeFromGraphQLType(GraphQLID)).toMatchObject(
      nullableType(t.TSStringKeyword())
    );
  });

  test("String!", () => {
    expect(
      typeFromGraphQLType(new GraphQLNonNull(GraphQLString))
    ).toMatchObject(t.TSStringKeyword());
  });

  test("Int!", () => {
    expect(typeFromGraphQLType(new GraphQLNonNull(GraphQLInt))).toMatchObject(
      t.TSNumberKeyword()
    );
  });

  test("Float!", () => {
    expect(typeFromGraphQLType(new GraphQLNonNull(GraphQLFloat))).toMatchObject(
      t.TSNumberKeyword()
    );
  });

  test("Boolean!", () => {
    expect(
      typeFromGraphQLType(new GraphQLNonNull(GraphQLBoolean))
    ).toMatchObject(t.TSBooleanKeyword());
  });

  test("ID!", () => {
    expect(typeFromGraphQLType(new GraphQLNonNull(GraphQLID))).toMatchObject(
      t.TSStringKeyword()
    );
  });

  // TODO: Test GenericTypeAnnotation

  test("[String]", () => {
    expect(typeFromGraphQLType(new GraphQLList(GraphQLString))).toMatchObject(
      nullableType(
        t.TSArrayType(t.TSParenthesizedType(nullableType(t.TSStringKeyword())))
      )
    );
  });

  test("[Int]", () => {
    expect(typeFromGraphQLType(new GraphQLList(GraphQLInt))).toMatchObject(
      nullableType(
        t.TSArrayType(t.TSParenthesizedType(nullableType(t.TSNumberKeyword())))
      )
    );
  });

  test("[Float]", () => {
    expect(typeFromGraphQLType(new GraphQLList(GraphQLFloat))).toMatchObject(
      nullableType(
        t.TSArrayType(t.TSParenthesizedType(nullableType(t.TSNumberKeyword())))
      )
    );
  });

  test("[Boolean]", () => {
    expect(typeFromGraphQLType(new GraphQLList(GraphQLBoolean))).toMatchObject(
      nullableType(
        t.TSArrayType(t.TSParenthesizedType(nullableType(t.TSBooleanKeyword())))
      )
    );
  });

  test("[ID]", () => {
    expect(typeFromGraphQLType(new GraphQLList(GraphQLID))).toMatchObject(
      nullableType(
        t.TSArrayType(t.TSParenthesizedType(nullableType(t.TSStringKeyword())))
      )
    );
  });

  test("[String]!", () => {
    expect(
      typeFromGraphQLType(new GraphQLNonNull(new GraphQLList(GraphQLString)))
    ).toMatchObject(
      t.TSArrayType(t.TSParenthesizedType(nullableType(t.TSStringKeyword())))
    );
  });

  test("[Int]!", () => {
    expect(
      typeFromGraphQLType(new GraphQLNonNull(new GraphQLList(GraphQLInt)))
    ).toMatchObject(
      t.TSArrayType(t.TSParenthesizedType(nullableType(t.TSNumberKeyword())))
    );
  });
  test("[Float]!", () => {
    expect(
      typeFromGraphQLType(new GraphQLNonNull(new GraphQLList(GraphQLFloat)))
    ).toMatchObject(
      t.TSArrayType(t.TSParenthesizedType(nullableType(t.TSNumberKeyword())))
    );
  });

  test("[Boolean]!", () => {
    expect(
      typeFromGraphQLType(new GraphQLNonNull(new GraphQLList(GraphQLBoolean)))
    ).toMatchObject(
      t.TSArrayType(t.TSParenthesizedType(nullableType(t.TSBooleanKeyword())))
    );
  });

  test("[ID]!", () => {
    expect(
      typeFromGraphQLType(new GraphQLNonNull(new GraphQLList(GraphQLID)))
    ).toMatchObject(
      t.TSArrayType(t.TSParenthesizedType(nullableType(t.TSStringKeyword())))
    );
  });

  test("[String!]", () => {
    expect(
      typeFromGraphQLType(new GraphQLList(new GraphQLNonNull(GraphQLString)))
    ).toMatchObject(nullableType(t.TSArrayType(t.TSStringKeyword())));
  });

  test("[Int!]", () => {
    expect(
      typeFromGraphQLType(new GraphQLList(new GraphQLNonNull(GraphQLInt)))
    ).toMatchObject(nullableType(t.TSArrayType(t.TSNumberKeyword())));
  });

  test("[Float!]", () => {
    expect(
      typeFromGraphQLType(new GraphQLList(new GraphQLNonNull(GraphQLFloat)))
    ).toMatchObject(nullableType(t.TSArrayType(t.TSNumberKeyword())));
  });

  test("[Boolean!]", () => {
    expect(
      typeFromGraphQLType(new GraphQLList(new GraphQLNonNull(GraphQLBoolean)))
    ).toMatchObject(nullableType(t.TSArrayType(t.TSBooleanKeyword())));
  });

  test("[ID!]", () => {
    expect(
      typeFromGraphQLType(new GraphQLList(new GraphQLNonNull(GraphQLID)))
    ).toMatchObject(nullableType(t.TSArrayType(t.TSStringKeyword())));
  });

  test("[String!]!", () => {
    expect(
      typeFromGraphQLType(
        new GraphQLNonNull(new GraphQLList(new GraphQLNonNull(GraphQLString)))
      )
    ).toMatchObject(t.TSArrayType(t.TSStringKeyword()));
  });

  test("[Int!]!", () => {
    expect(
      typeFromGraphQLType(
        new GraphQLNonNull(new GraphQLList(new GraphQLNonNull(GraphQLInt)))
      )
    ).toMatchObject(t.TSArrayType(t.TSNumberKeyword()));
  });

  test("[Float!]!", () => {
    expect(
      typeFromGraphQLType(
        new GraphQLNonNull(new GraphQLList(new GraphQLNonNull(GraphQLFloat)))
      )
    ).toMatchObject(t.TSArrayType(t.TSNumberKeyword()));
  });

  test("[Boolean!]!", () => {
    expect(
      typeFromGraphQLType(
        new GraphQLNonNull(new GraphQLList(new GraphQLNonNull(GraphQLBoolean)))
      )
    ).toMatchObject(t.TSArrayType(t.TSBooleanKeyword()));
  });

  test("[ID!]!", () => {
    expect(
      typeFromGraphQLType(
        new GraphQLNonNull(new GraphQLList(new GraphQLNonNull(GraphQLID)))
      )
    ).toMatchObject(t.TSArrayType(t.TSStringKeyword()));
  });

  test("[[String]]", () => {
    expect(
      typeFromGraphQLType(new GraphQLList(new GraphQLList(GraphQLString)))
    ).toMatchObject(
      nullableType(
        t.TSArrayType(
          t.TSParenthesizedType(
            nullableType(
              t.TSArrayType(
                t.TSParenthesizedType(nullableType(t.TSStringKeyword()))
              )
            )
          )
        )
      )
    );
  });

  test("[[String]]!", () => {
    expect(
      typeFromGraphQLType(
        new GraphQLNonNull(new GraphQLList(new GraphQLList(GraphQLString)))
      )
    ).toMatchObject(
      t.TSArrayType(
        t.TSParenthesizedType(
          nullableType(
            t.TSArrayType(
              t.TSParenthesizedType(nullableType(t.TSStringKeyword()))
            )
          )
        )
      )
    );
  });

  test("Custom Scalar", () => {
    const OddType = new GraphQLScalarType({
      name: "Odd",
      serialize(value) {
        return value % 2 === 1 ? value : null;
      }
    });

    expect(typeFromGraphQLType(OddType)).toMatchObject(
      nullableType(t.TSAnyKeyword())
    );
  });
});

describe("passthrough custom scalars", () => {
  let getTypeAnnotation: Function;

  beforeAll(() => {
    getTypeAnnotation = createTypeFromGraphQLTypeFunction({
      passthroughCustomScalars: true,
      useReadOnlyTypes: false
    });
  });

  test("Custom Scalar", () => {
    const OddType = new GraphQLScalarType({
      name: "Odd",
      serialize(value) {
        return value % 2 === 1 ? value : null;
      }
    });

    expect(getTypeAnnotation(OddType)).toMatchObject(
      nullableType(t.TSTypeReference(t.identifier("Odd")))
    );
  });
});

describe("passthrough custom scalars with custom scalar prefix", () => {
  let getTypeAnnotation: Function;

  beforeAll(() => {
    getTypeAnnotation = createTypeFromGraphQLTypeFunction({
      passthroughCustomScalars: true,
      customScalarsPrefix: "Foo$",
      useReadOnlyTypes: false
    });
  });

  test("Custom Scalar", () => {
    const OddType = new GraphQLScalarType({
      name: "Odd",
      serialize(value) {
        return value % 2 === 1 ? value : null;
      }
    });

    expect(getTypeAnnotation(OddType)).toMatchObject(
      nullableType(t.TSTypeReference(t.identifier("Foo$Odd")))
    );
  });
});

describe("readonly arrays", () => {
  let getTypeAnnotation: Function;

  beforeAll(() => {
    getTypeAnnotation = createTypeFromGraphQLTypeFunction({
      useReadOnlyTypes: true
    });
  });

  test("Readonly array", () => {
    const OddType = new GraphQLList(GraphQLString);

    expect(getTypeAnnotation(OddType)).toMatchObject(
      nullableType(
        t.TSTypeReference(
          t.identifier("ReadonlyArray"),
          t.TSTypeParameterInstantiation([
            t.TSParenthesizedType(nullableType(t.TSStringKeyword()))
          ])
        )
      )
    );
  });
});
