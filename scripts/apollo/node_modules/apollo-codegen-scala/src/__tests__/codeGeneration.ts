import {
  parse,
  GraphQLString,
  GraphQLList,
  GraphQLNonNull,
  GraphQLEnumType,
  GraphQLCompositeType,
  GraphQLObjectType
} from "graphql";

import {
  generateSource,
  classDeclarationForOperation,
  traitDeclarationForFragment,
  traitDeclarationForSelectionSet,
  typeDeclarationForGraphQLType
} from "../codeGeneration";

import { loadSchema } from "apollo-codegen-core/lib/loading";
const schema = loadSchema(
  require.resolve("../../../../__fixtures__/starwars/schema.json")
);

import CodeGenerator from "apollo-codegen-core/lib/utilities/CodeGenerator";

import {
  compileToLegacyIR,
  LegacyCompilerContext
} from "apollo-codegen-core/lib/compiler/legacyIR";

describe("Scala code generation", function() {
  let generator;
  let resetGenerator;
  let compileFromSource;
  let addFragment;

  beforeEach(function() {
    resetGenerator = () => {
      const context = {
        schema: schema,
        operations: {},
        fragments: {},
        typesUsed: {}
      };
      generator = new CodeGenerator(context);
    };

    compileFromSource = (
      source,
      options = { generateOperationIds: false, namespace: undefined }
    ) => {
      const document = parse(source);
      let context = compileToLegacyIR(schema, document);
      options.generateOperationIds &&
        Object.assign(context.options, {
          generateOperationIds: true,
          operationIdsMap: {}
        });
      options.namespace &&
        Object.assign(context.options, { namespace: options.namespace });
      generator.context = context;
      return context;
    };

    addFragment = fragment => {
      generator.context.fragments[fragment.fragmentName] = fragment;
    };

    resetGenerator();
  });

  describe("#generateSource()", function() {
    test(`should emit a package declaration when the namespace option is specified`, function() {
      const context = compileFromSource(
        `
        query HeroName($episode: Episode) {
          hero(episode: $episode) {
            name
          }
        }
      `,
        { namespace: "hello.world" }
      );

      expect(generateSource(context)).toMatchSnapshot();
    });
  });

  describe("#classDeclarationForOperation()", function() {
    test(`should generate a class declaration for a query with variables`, function() {
      const { operations, fragments } = compileFromSource(`
        query HeroName($episode: Episode) {
          hero(episode: $episode) {
            name
          }
        }
      `);

      classDeclarationForOperation(generator, operations["HeroName"]);
      expect(generator.output).toMatchSnapshot();
    });

    test(`should generate a class declaration for a query with fragment spreads`, function() {
      const { operations, fragments } = compileFromSource(`
        query Hero {
          hero {
            ...HeroDetails
          }
        }

        fragment HeroDetails on Character {
          name
        }
      `);

      classDeclarationForOperation(generator, operations["Hero"]);
      expect(generator.output).toMatchSnapshot();
    });

    test(`should generate a class declaration for a query with conditional fragment spreads`, function() {
      const { operations, fragments } = compileFromSource(`
        query Hero {
          hero {
            ...DroidDetails
          }
        }

        fragment DroidDetails on Droid {
          primaryFunction
        }
      `);

      classDeclarationForOperation(generator, operations["Hero"]);
      expect(generator.output).toMatchSnapshot();
    });

    test(`should generate a class declaration for a query with a fragment spread nested in an inline fragment`, function() {
      const { operations, fragments } = compileFromSource(`
        query Hero {
          hero {
            ... on Droid {
              ...HeroDetails
            }
          }
        }

        fragment HeroDetails on Character {
          name
        }
      `);

      classDeclarationForOperation(generator, operations["Hero"]);

      expect(generator.output).toMatchSnapshot();
    });

    test(`should generate a class declaration for a query with a fragment spread containing deep fields`, function() {
      const { operations, fragments } = compileFromSource(`
        query Hero {
          hero {
            ...HeroDetails
          }
        }

        fragment HeroDetails on Character {
          name
          friends {
            name
          }
        }
      `);

      classDeclarationForOperation(generator, operations["Hero"]);

      traitDeclarationForFragment(generator, fragments["HeroDetails"]);

      expect(generator.output).toMatchSnapshot();
    });

    test(`should generate a class declaration for a mutation with variables`, function() {
      const { operations, fragments } = compileFromSource(`
        mutation CreateReview($episode: Episode) {
          createReview(episode: $episode, review: { stars: 5, commentary: "Wow!" }) {
            stars
            commentary
          }
        }
      `);

      classDeclarationForOperation(generator, operations["CreateReview"]);

      expect(generator.output).toMatchSnapshot();
    });

    describe(`when generateOperationIds is specified`, function() {
      let compileOptions = { generateOperationIds: true };

      test(`should generate a class declaration with an operationId property`, function() {
        const context = compileFromSource(
          `
          query Hero {
            hero {
              ...HeroDetails
            }
          }
          fragment HeroDetails on Character {
            name
          }
        `,
          compileOptions
        );

        classDeclarationForOperation(generator, context.operations["Hero"]);
        expect(generator.output).toMatchSnapshot();
      });

      test(`should generate different operation ids for different operations`, function() {
        const context1 = compileFromSource(
          `
          query Hero {
            hero {
              ...HeroDetails
            }
          }
          fragment HeroDetails on Character {
            name
          }
        `,
          compileOptions
        );

        classDeclarationForOperation(generator, context1.operations["Hero"]);
        const output1 = generator.output;

        resetGenerator();
        const context2 = compileFromSource(
          `
          query Hero {
            hero {
              ...HeroDetails
            }
          }
          fragment HeroDetails on Character {
            appearsIn
          }
        `,
          compileOptions
        );

        classDeclarationForOperation(generator, context2.operations["Hero"]);
        const output2 = generator.output;

        expect(output1).not.toBe(output2);
      });

      test(`should generate the same operation id regardless of operation formatting/commenting`, function() {
        const context1 = compileFromSource(
          `
          query HeroName($episode: Episode) {
            hero(episode: $episode) {
              name
            }
          }
        `,
          compileOptions
        );

        classDeclarationForOperation(
          generator,
          context1.operations["HeroName"]
        );
        const output1 = generator.output;

        resetGenerator();
        const context2 = compileFromSource(
          `
          # Profound comment
          query HeroName($episode:Episode) { hero(episode: $episode) { name } }
          # Deeply meaningful comment
        `,
          compileOptions
        );

        classDeclarationForOperation(
          generator,
          context2.operations["HeroName"]
        );
        const output2 = generator.output;

        expect(output1).toBe(output2);
      });

      test(`should generate the same operation id regardless of fragment order`, function() {
        const context1 = compileFromSource(
          `
          query Hero {
            hero {
              ...HeroName
              ...HeroAppearsIn
            }
          }
          fragment HeroName on Character {
            name
          }
          fragment HeroAppearsIn on Character {
            appearsIn
          }
        `,
          compileOptions
        );

        classDeclarationForOperation(generator, context1.operations["Hero"]);
        const output1 = generator.output;

        resetGenerator();
        const context2 = compileFromSource(
          `
          query Hero {
            hero {
              ...HeroName
              ...HeroAppearsIn
            }
          }
          fragment HeroAppearsIn on Character {
            appearsIn
          }
          fragment HeroName on Character {
            name
          }
        `,
          compileOptions
        );

        classDeclarationForOperation(generator, context2.operations["Hero"]);
        const output2 = generator.output;

        expect(output1).toBe(output2);
      });

      test(`should generate appropriate operation id mapping source when there are nested fragment references`, function() {
        const source = `
          query Hero {
            hero {
              ...HeroDetails
            }
          }
          fragment HeroName on Character {
            name
          }
          fragment HeroDetails on Character {
            ...HeroName
            appearsIn
          }
        `;
        const context = compileFromSource(source, true);
        expect(
          context.operations["Hero"].sourceWithFragments
        ).toMatchSnapshot();
      });
    });
  });

  describe("#traitDeclarationForFragment()", function() {
    test(`should generate a trait declaration for a fragment with an abstract type condition`, function() {
      const { fragments } = compileFromSource(`
        fragment HeroDetails on Character {
          name
          appearsIn
        }
      `);

      traitDeclarationForFragment(generator, fragments["HeroDetails"]);

      expect(generator.output).toMatchSnapshot();
    });

    test(`should generate a trait declaration for a fragment with a concrete type condition`, function() {
      const { fragments } = compileFromSource(`
        fragment DroidDetails on Droid {
          name
          primaryFunction
        }
      `);

      traitDeclarationForFragment(generator, fragments["DroidDetails"]);

      expect(generator.output).toMatchSnapshot();
    });

    test(`should generate a trait declaration for a fragment with a subselection`, function() {
      const { fragments } = compileFromSource(`
        fragment HeroDetails on Character {
          name
          friends {
            name
          }
        }
      `);

      traitDeclarationForFragment(generator, fragments["HeroDetails"]);

      expect(generator.output).toMatchSnapshot();
    });

    test(`should generate a trait declaration for a fragment that includes a fragment spread`, function() {
      const { fragments } = compileFromSource(`
        fragment HeroDetails on Character {
          name
          ...MoreHeroDetails
        }

        fragment MoreHeroDetails on Character {
          appearsIn
        }
      `);

      traitDeclarationForFragment(generator, fragments["HeroDetails"]);

      expect(generator.output).toMatchSnapshot();
    });
  });

  describe("#traitDeclarationForSelectionSet()", function() {
    test(`should generate a trait declaration for a selection set`, function() {
      traitDeclarationForSelectionSet(generator, {
        traitName: "Hero",
        parentType: schema.getType("Character") as GraphQLCompositeType,
        fields: [
          {
            responseName: "name",
            fieldName: "name",
            type: GraphQLString
          }
        ]
      });

      expect(generator.output).toMatchSnapshot();
    });

    test(`should escape reserved keywords in a trait declaration for a selection set`, function() {
      traitDeclarationForSelectionSet(generator, {
        traitName: "Hero",
        parentType: schema.getType("Character") as GraphQLCompositeType,
        fields: [
          {
            responseName: "private",
            fieldName: "name",
            type: GraphQLString
          }
        ]
      });

      expect(generator.output).toMatchSnapshot();
    });

    test(`should handle underscores in a trait declaration for a selection set`, function() {
      traitDeclarationForSelectionSet(generator, {
        traitName: "TypeWithUnderscore",
        parentType: undefined,
        fields: [
          {
            responseName: "_id",
            fieldName: "_id",
            type: GraphQLString
          }
        ]
      });

      expect(generator.output).toMatchSnapshot();
    });

    test(`should handle escaped values in a trait declaration for a selection set`, function() {
      traitDeclarationForSelectionSet(generator, {
        traitName: "TypeWithUnderscore",
        parentType: undefined,
        fields: [
          {
            responseName: "class",
            fieldName: "class",
            type: GraphQLString
          }
        ]
      });

      expect(generator.output).toMatchSnapshot();
    });

    test(`should generate a nested trait declaration for a selection set with subselections`, function() {
      traitDeclarationForSelectionSet(generator, {
        traitName: "Hero",
        parentType: schema.getType("Character") as GraphQLCompositeType,
        fields: [
          {
            responseName: "friends",
            fieldName: "friends",
            type: new GraphQLList(schema.getType("Character")),
            fields: [
              {
                responseName: "name",
                fieldName: "name",
                type: GraphQLString
              }
            ]
          }
        ]
      });

      expect(generator.output).toMatchSnapshot();
    });

    test(`should generate a trait declaration for a selection set with a fragment spread that matches the parent type`, function() {
      addFragment({
        fragmentName: "HeroDetails",
        typeCondition: schema.getType("Character")
      });

      traitDeclarationForSelectionSet(generator, {
        traitName: "Hero",
        parentType: schema.getType("Character") as GraphQLCompositeType,
        fragmentSpreads: ["HeroDetails"],
        fields: [
          {
            responseName: "name",
            fieldName: "name",
            type: GraphQLString
          }
        ]
      });

      expect(generator.output).toMatchSnapshot();
    });

    test(`should generate a trait declaration for a selection set with a fragment spread with a more specific type condition`, function() {
      addFragment({
        fragmentName: "DroidDetails",
        typeCondition: schema.getType("Droid")
      });

      traitDeclarationForSelectionSet(generator, {
        traitName: "Hero",
        parentType: schema.getType("Character") as GraphQLCompositeType,
        fragmentSpreads: ["DroidDetails"],
        fields: [
          {
            responseName: "name",
            fieldName: "name",
            type: GraphQLString
          }
        ]
      });

      expect(generator.output).toMatchSnapshot();
    });

    test(`should generate a trait declaration for a selection set with an inline fragment`, function() {
      traitDeclarationForSelectionSet(generator, {
        traitName: "Hero",
        parentType: schema.getType("Character") as GraphQLCompositeType,
        fields: [
          {
            responseName: "name",
            fieldName: "name",
            type: new GraphQLNonNull(GraphQLString)
          }
        ],
        inlineFragments: [
          {
            typeCondition: schema.getType("Droid") as GraphQLObjectType,
            possibleTypes: [schema.getType("Droid") as GraphQLObjectType],
            fields: [
              {
                responseName: "name",
                fieldName: "name",
                type: new GraphQLNonNull(GraphQLString)
              },
              {
                responseName: "primaryFunction",
                fieldName: "primaryFunction",
                type: GraphQLString
              }
            ],
            fragmentSpreads: []
          }
        ]
      });

      expect(generator.output).toMatchSnapshot();
    });

    test(`should generate a trait declaration for a fragment spread nested in an inline fragment`, function() {
      addFragment({
        fragmentName: "HeroDetails",
        typeCondition: schema.getType("Character")
      });

      traitDeclarationForSelectionSet(generator, {
        traitName: "Hero",
        parentType: schema.getType("Character") as GraphQLCompositeType,
        fields: [],
        inlineFragments: [
          {
            typeCondition: schema.getType("Droid") as GraphQLObjectType,
            possibleTypes: [schema.getType("Droid") as GraphQLObjectType],
            fields: [],
            fragmentSpreads: ["HeroDetails"]
          }
        ]
      });

      expect(generator.output).toMatchSnapshot();
    });
  });

  describe("#typeDeclarationForGraphQLType()", function() {
    test("should generate an enum declaration for a GraphQLEnumType", function() {
      const generator = new CodeGenerator<LegacyCompilerContext, any>({
        options: {},
        schema: undefined,
        operations: undefined,
        fragments: undefined,
        typesUsed: undefined
      });

      typeDeclarationForGraphQLType(generator, schema.getType("Episode"));

      expect(generator.output).toMatchSnapshot();
    });

    test("should escape identifiers in cases of enum declaration for a GraphQLEnumType", function() {
      const generator = new CodeGenerator<LegacyCompilerContext, any>({
        options: {},
        schema: undefined,
        operations: undefined,
        fragments: undefined,
        typesUsed: undefined
      });

      const albumPrivaciesEnum = new GraphQLEnumType({
        name: "AlbumPrivacies",
        values: { PUBLIC: { value: "PUBLIC" }, PRIVATE: { value: "PRIVATE" } }
      });

      typeDeclarationForGraphQLType(generator, albumPrivaciesEnum);

      expect(generator.output).toMatchSnapshot();
    });

    test("should generate a trait declaration for a GraphQLInputObjectType", function() {
      const generator = new CodeGenerator<LegacyCompilerContext, any>({
        options: {},
        schema: undefined,
        operations: undefined,
        fragments: undefined,
        typesUsed: undefined
      });

      typeDeclarationForGraphQLType(generator, schema.getType("ReviewInput"));

      expect(generator.output).toMatchSnapshot();
    });
  });
});
