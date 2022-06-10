import { 
  compileDocument,
  parseDocument,
  loadSchemaFromSDL
} from "../index"
import { 
  CompilationResult
} from "../compiler/index"
import { 
  Source,
  GraphQLSchema,
  DocumentNode,
  GraphQLEnumType,
} from "graphql";

describe("given schema", () => {
  const schemaSDL: string = `
  type Query {
    allAnimals: [Animal!]
  }

  enum Species {
    TasmanianTiger @deprecated(reason: "Extinct")
    Hippopotamus
    Dodo @deprecated(reason: "Extinct")
    PolarBear
  }

  interface Animal {
    species: Species!
    friend: Animal!
  }
  `;

  const schema: GraphQLSchema = loadSchemaFromSDL(new Source(schemaSDL, "Test Schema", { line: 1, column: 1 }));

  describe("query includes enum with deprecated values", () => {
    const documentString: string = `
    query Test($a: Boolean!) {
      allAnimals {
        species
      }
    }
    `;

    const document: DocumentNode = parseDocument(
      new Source(documentString, "Test Query", { line: 1, column: 1 }),
      false
    );

    it("should compile enum values with deprecation reason", () => {
      const compilationResult: CompilationResult = compileDocument(schema, document);
      const speciesEnum: GraphQLEnumType = compilationResult.referencedTypes.find(function(element) {
        return element.name == 'Species'
      }) as GraphQLEnumType

      expect(speciesEnum.getValue("TasmanianTiger")!.deprecationReason).toEqual("Extinct")
      expect(speciesEnum.getValue("Hippopotamus")!.deprecationReason).toBeUndefined()
      expect(speciesEnum.getValue("Dodo")!.deprecationReason).toEqual("Extinct")
      expect(speciesEnum.getValue("PolarBear")!.deprecationReason).toBeUndefined()
    });
  });

});
