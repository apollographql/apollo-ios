import {
  compileDocument,
  parseOperationDocument,
  loadSchemaFromSources,
} from "../index"
import {
  CompilationResult
} from "../compiler/index"
import {
  Source,
  GraphQLSchema,
  DocumentNode,
  GraphQLEnumType,
  GraphQLInputObjectType,
} from "graphql";

describe("given schema with mutation using input type with enum field", () => {
  const schemaSDL: string = `
  type Query {
    allAnimals: [Animal!]
  }

  type Mutation {
    mutateSpecies(input: SpeciesInput!): Animal!
  }

  input SpeciesInput {
    species: Species!
  }

  enum Species {
    Tiger
  }

  interface Animal {
    name: String!
  }
  `;

  const schema: GraphQLSchema = loadSchemaFromSources([new Source(schemaSDL, "Test Schema", { line: 1, column: 1 })]);

  describe("mutation defined using SpeciesInput", () => {
    const documentString: string = `
    mutation Test($input: SpeciesInput!) {
      mutateSpecies(input: $input) {
        name
      }
    }
    `;

    const document: DocumentNode = parseOperationDocument(
      new Source(documentString, "Test Mutation", { line: 1, column: 1 }),
      false
    );

    it("should compile with referencedTypes inlcuding SpeciesInput and Species enum", () => {
      const compilationResult: CompilationResult = compileDocument(schema, document, false);
      const speciesInput: GraphQLInputObjectType = compilationResult.referencedTypes.find(function(element) {
        return element.name == 'SpeciesInput'
      }) as GraphQLInputObjectType
      const speciesEnum: GraphQLEnumType = compilationResult.referencedTypes.find(function(element) {
        return element.name == 'Species'
      }) as GraphQLEnumType

      expect(speciesInput).not.toBeUndefined()
      expect(speciesEnum).not.toBeUndefined()
    });
  });

});
