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

import { createTypeAnnotationFromGraphQLTypeFunction } from "../helpers";

const typeAnnotationFromGraphQLType = createTypeAnnotationFromGraphQLTypeFunction(
  {
    passthroughCustomScalars: false,
    useReadOnlyTypes: false
  }
);

describe("Flow typeAnnotationFromGraphQLType", () => {
  test("String", () => {
    expect(typeAnnotationFromGraphQLType(GraphQLString)).toMatchObject(
      t.nullableTypeAnnotation(t.stringTypeAnnotation())
    );
  });

  test("Int", () => {
    expect(typeAnnotationFromGraphQLType(GraphQLInt)).toMatchObject(
      t.nullableTypeAnnotation(t.numberTypeAnnotation())
    );
  });

  test("Float", () => {
    expect(typeAnnotationFromGraphQLType(GraphQLFloat)).toMatchObject(
      t.nullableTypeAnnotation(t.numberTypeAnnotation())
    );
  });

  test("Boolean", () => {
    expect(typeAnnotationFromGraphQLType(GraphQLBoolean)).toMatchObject(
      t.nullableTypeAnnotation(t.booleanTypeAnnotation())
    );
  });

  test("ID", () => {
    expect(typeAnnotationFromGraphQLType(GraphQLID)).toMatchObject(
      t.nullableTypeAnnotation(t.stringTypeAnnotation())
    );
  });

  test("String!", () => {
    expect(
      typeAnnotationFromGraphQLType(new GraphQLNonNull(GraphQLString))
    ).toMatchObject(t.stringTypeAnnotation());
  });

  test("Int!", () => {
    expect(
      typeAnnotationFromGraphQLType(new GraphQLNonNull(GraphQLInt))
    ).toMatchObject(t.numberTypeAnnotation());
  });

  test("Float!", () => {
    expect(
      typeAnnotationFromGraphQLType(new GraphQLNonNull(GraphQLFloat))
    ).toMatchObject(t.numberTypeAnnotation());
  });

  test("Boolean!", () => {
    expect(
      typeAnnotationFromGraphQLType(new GraphQLNonNull(GraphQLBoolean))
    ).toMatchObject(t.booleanTypeAnnotation());
  });

  test("ID!", () => {
    expect(
      typeAnnotationFromGraphQLType(new GraphQLNonNull(GraphQLID))
    ).toMatchObject(t.stringTypeAnnotation());
  });

  // TODO: Test GenericTypeAnnotation

  test("[String]", () => {
    expect(
      typeAnnotationFromGraphQLType(new GraphQLList(GraphQLString))
    ).toMatchObject(
      t.nullableTypeAnnotation(
        t.genericTypeAnnotation(
          t.identifier("Array"),
          t.typeParameterInstantiation([
            t.nullableTypeAnnotation(t.stringTypeAnnotation())
          ])
        )
      )
    );
  });

  test("[Int]", () => {
    expect(
      typeAnnotationFromGraphQLType(new GraphQLList(GraphQLInt))
    ).toMatchObject(
      t.nullableTypeAnnotation(
        t.genericTypeAnnotation(
          t.identifier("Array"),
          t.typeParameterInstantiation([
            t.nullableTypeAnnotation(t.numberTypeAnnotation())
          ])
        )
      )
    );
  });

  test("[Float]", () => {
    expect(
      typeAnnotationFromGraphQLType(new GraphQLList(GraphQLFloat))
    ).toMatchObject(
      t.nullableTypeAnnotation(
        t.genericTypeAnnotation(
          t.identifier("Array"),
          t.typeParameterInstantiation([
            t.nullableTypeAnnotation(t.numberTypeAnnotation())
          ])
        )
      )
    );
  });

  test("[Boolean]", () => {
    expect(
      typeAnnotationFromGraphQLType(new GraphQLList(GraphQLBoolean))
    ).toMatchObject(
      t.nullableTypeAnnotation(
        t.genericTypeAnnotation(
          t.identifier("Array"),
          t.typeParameterInstantiation([
            t.nullableTypeAnnotation(t.booleanTypeAnnotation())
          ])
        )
      )
    );
  });

  test("[ID]", () => {
    expect(
      typeAnnotationFromGraphQLType(new GraphQLList(GraphQLID))
    ).toMatchObject(
      t.nullableTypeAnnotation(
        t.genericTypeAnnotation(
          t.identifier("Array"),
          t.typeParameterInstantiation([
            t.nullableTypeAnnotation(t.stringTypeAnnotation())
          ])
        )
      )
    );
  });

  test("[String]!", () => {
    expect(
      typeAnnotationFromGraphQLType(
        new GraphQLNonNull(new GraphQLList(GraphQLString))
      )
    ).toMatchObject(
      t.genericTypeAnnotation(
        t.identifier("Array"),
        t.typeParameterInstantiation([
          t.nullableTypeAnnotation(t.stringTypeAnnotation())
        ])
      )
    );
  });

  test("[Int]!", () => {
    expect(
      typeAnnotationFromGraphQLType(
        new GraphQLNonNull(new GraphQLList(GraphQLInt))
      )
    ).toMatchObject(
      t.genericTypeAnnotation(
        t.identifier("Array"),
        t.typeParameterInstantiation([
          t.nullableTypeAnnotation(t.numberTypeAnnotation())
        ])
      )
    );
  });
  test("[Float]!", () => {
    expect(
      typeAnnotationFromGraphQLType(
        new GraphQLNonNull(new GraphQLList(GraphQLFloat))
      )
    ).toMatchObject(
      t.genericTypeAnnotation(
        t.identifier("Array"),
        t.typeParameterInstantiation([
          t.nullableTypeAnnotation(t.numberTypeAnnotation())
        ])
      )
    );
  });

  test("[Boolean]!", () => {
    expect(
      typeAnnotationFromGraphQLType(
        new GraphQLNonNull(new GraphQLList(GraphQLBoolean))
      )
    ).toMatchObject(
      t.genericTypeAnnotation(
        t.identifier("Array"),
        t.typeParameterInstantiation([
          t.nullableTypeAnnotation(t.booleanTypeAnnotation())
        ])
      )
    );
  });

  test("[ID]!", () => {
    expect(
      typeAnnotationFromGraphQLType(
        new GraphQLNonNull(new GraphQLList(GraphQLID))
      )
    ).toMatchObject(
      t.genericTypeAnnotation(
        t.identifier("Array"),
        t.typeParameterInstantiation([
          t.nullableTypeAnnotation(t.stringTypeAnnotation())
        ])
      )
    );
  });

  test("[String!]", () => {
    expect(
      typeAnnotationFromGraphQLType(
        new GraphQLList(new GraphQLNonNull(GraphQLString))
      )
    ).toMatchObject(
      t.nullableTypeAnnotation(
        t.genericTypeAnnotation(
          t.identifier("Array"),
          t.typeParameterInstantiation([t.stringTypeAnnotation()])
        )
      )
    );
  });

  test("[Int!]", () => {
    expect(
      typeAnnotationFromGraphQLType(
        new GraphQLList(new GraphQLNonNull(GraphQLInt))
      )
    ).toMatchObject(
      t.nullableTypeAnnotation(
        t.genericTypeAnnotation(
          t.identifier("Array"),
          t.typeParameterInstantiation([t.numberTypeAnnotation()])
        )
      )
    );
  });

  test("[Float!]", () => {
    expect(
      typeAnnotationFromGraphQLType(
        new GraphQLList(new GraphQLNonNull(GraphQLFloat))
      )
    ).toMatchObject(
      t.nullableTypeAnnotation(
        t.genericTypeAnnotation(
          t.identifier("Array"),
          t.typeParameterInstantiation([t.numberTypeAnnotation()])
        )
      )
    );
  });

  test("[Boolean!]", () => {
    expect(
      typeAnnotationFromGraphQLType(
        new GraphQLList(new GraphQLNonNull(GraphQLBoolean))
      )
    ).toMatchObject(
      t.nullableTypeAnnotation(
        t.genericTypeAnnotation(
          t.identifier("Array"),
          t.typeParameterInstantiation([t.booleanTypeAnnotation()])
        )
      )
    );
  });

  test("[ID!]", () => {
    expect(
      typeAnnotationFromGraphQLType(
        new GraphQLList(new GraphQLNonNull(GraphQLID))
      )
    ).toMatchObject(
      t.nullableTypeAnnotation(
        t.genericTypeAnnotation(
          t.identifier("Array"),
          t.typeParameterInstantiation([t.stringTypeAnnotation()])
        )
      )
    );
  });

  test("[String!]!", () => {
    expect(
      typeAnnotationFromGraphQLType(
        new GraphQLNonNull(new GraphQLList(new GraphQLNonNull(GraphQLString)))
      )
    ).toMatchObject(
      t.genericTypeAnnotation(
        t.identifier("Array"),
        t.typeParameterInstantiation([t.stringTypeAnnotation()])
      )
    );
  });

  test("[Int!]!", () => {
    expect(
      typeAnnotationFromGraphQLType(
        new GraphQLNonNull(new GraphQLList(new GraphQLNonNull(GraphQLInt)))
      )
    ).toMatchObject(
      t.genericTypeAnnotation(
        t.identifier("Array"),
        t.typeParameterInstantiation([t.numberTypeAnnotation()])
      )
    );
  });

  test("[Float!]!", () => {
    expect(
      typeAnnotationFromGraphQLType(
        new GraphQLNonNull(new GraphQLList(new GraphQLNonNull(GraphQLFloat)))
      )
    ).toMatchObject(
      t.genericTypeAnnotation(
        t.identifier("Array"),
        t.typeParameterInstantiation([t.numberTypeAnnotation()])
      )
    );
  });

  test("[Boolean!]!", () => {
    expect(
      typeAnnotationFromGraphQLType(
        new GraphQLNonNull(new GraphQLList(new GraphQLNonNull(GraphQLBoolean)))
      )
    ).toMatchObject(
      t.genericTypeAnnotation(
        t.identifier("Array"),
        t.typeParameterInstantiation([t.booleanTypeAnnotation()])
      )
    );
  });

  test("[ID!]!", () => {
    expect(
      typeAnnotationFromGraphQLType(
        new GraphQLNonNull(new GraphQLList(new GraphQLNonNull(GraphQLID)))
      )
    ).toMatchObject(
      t.genericTypeAnnotation(
        t.identifier("Array"),
        t.typeParameterInstantiation([t.stringTypeAnnotation()])
      )
    );
  });

  test("[[String]]", () => {
    expect(
      typeAnnotationFromGraphQLType(
        new GraphQLList(new GraphQLList(GraphQLString))
      )
    ).toMatchObject(
      t.nullableTypeAnnotation(
        t.genericTypeAnnotation(
          t.identifier("Array"),
          t.typeParameterInstantiation([
            t.nullableTypeAnnotation(
              t.genericTypeAnnotation(
                t.identifier("Array"),
                t.typeParameterInstantiation([
                  t.nullableTypeAnnotation(t.stringTypeAnnotation())
                ])
              )
            )
          ])
        )
      )
    );
  });

  test("[[String]]!", () => {
    expect(
      typeAnnotationFromGraphQLType(
        new GraphQLNonNull(new GraphQLList(new GraphQLList(GraphQLString)))
      )
    ).toMatchObject(
      t.genericTypeAnnotation(
        t.identifier("Array"),
        t.typeParameterInstantiation([
          t.nullableTypeAnnotation(
            t.genericTypeAnnotation(
              t.identifier("Array"),
              t.typeParameterInstantiation([
                t.nullableTypeAnnotation(t.stringTypeAnnotation())
              ])
            )
          )
        ])
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

    expect(typeAnnotationFromGraphQLType(OddType)).toMatchObject(
      t.nullableTypeAnnotation(t.anyTypeAnnotation())
    );
  });
});

describe("passthrough custom scalars", () => {
  let getTypeAnnotation: Function;

  beforeAll(() => {
    getTypeAnnotation = createTypeAnnotationFromGraphQLTypeFunction({
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
      t.nullableTypeAnnotation(t.genericTypeAnnotation(t.identifier("Odd")))
    );
  });
});

describe("passthrough custom scalars with custom scalar prefix", () => {
  let getTypeAnnotation: Function;

  beforeAll(() => {
    getTypeAnnotation = createTypeAnnotationFromGraphQLTypeFunction({
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
      t.nullableTypeAnnotation(t.genericTypeAnnotation(t.identifier("Foo$Odd")))
    );
  });
});
