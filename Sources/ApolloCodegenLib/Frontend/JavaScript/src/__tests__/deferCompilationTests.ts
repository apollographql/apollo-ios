import { 
  compileDocument,
  parseOperationDocument,
  loadSchemaFromSources,
} from "../index"
import { 
  CompilationResult
} from "../compiler/index"
import {  
  Field,
  InlineFragment
} from "../compiler/ir"
import { 
  Source,
  GraphQLSchema,
  DocumentNode
} from "graphql";
import { emptyValidationOptions } from "../__testUtils__/validationHelpers";

describe("given schema", () => {
  const schemaSDL: string = `
  type Query {
    allAnimals: [Animal!]
  }

  interface Animal {
    species: String!
    friend: Animal!
  }
  `;

  const schema: GraphQLSchema = loadSchemaFromSources([new Source(schemaSDL, "Test Schema", { line: 1, column: 1 })]);

  describe("query has inline fragment with @defer directive", () => {
    const documentString: string = `
    query Test($a: Boolean!) {
      allAnimals {
        ... @defer {
          species
        }
      }
    }
    `;

    const document: DocumentNode = parseOperationDocument(
      new Source(documentString, "Test Query", { line: 1, column: 1 })
    );

    it("should compile inline fragment with directive", () => {
      const compilationResult: CompilationResult = compileDocument(schema, document, false, emptyValidationOptions);
      const operation = compilationResult.operations[0];
      const allAnimals = operation.selectionSet.selections[0] as Field;
      const inlineFragment = allAnimals?.selectionSet?.selections?.[0] as InlineFragment;

      expect(inlineFragment.directives?.length).toEqual(1);

      expect(inlineFragment.directives?.[0].name).toEqual("defer");
    });
  });

  describe("query has named fragment with @defer directive", () => {
    const documentString: string = `
    query Test($a: Boolean!) {
      allAnimals {
        ... SpeciesFragment @defer
      }
    }

    fragment SpeciesFragment on Animal {
      species
    }
    `;

    const document: DocumentNode = parseOperationDocument(
      new Source(documentString, "Test Query", { line: 1, column: 1 })
    );

    it("should compile named fragment with directive", () => {
      const compilationResult: CompilationResult = compileDocument(schema, document, false, emptyValidationOptions);
      const operation = compilationResult.operations[0];
      const allAnimals = operation.selectionSet.selections[0] as Field;
      const inlineFragment = allAnimals?.selectionSet?.selections?.[0] as InlineFragment;

      expect(inlineFragment.directives?.length).toEqual(1);

      expect(inlineFragment.directives?.[0].name).toEqual("defer");
    });
  });

  describe("query has named fragment with @defer directive with arguments", () => {
    const documentString: string = `
    query Test($a: Boolean!) {
      allAnimals {
        ... SpeciesFragment @defer(if: true, label: "species")
      }
    }

    fragment SpeciesFragment on Animal {
      species
    }
    `;

    const document: DocumentNode = parseOperationDocument(
      new Source(documentString, "Test Query", { line: 1, column: 1 })
    );

    it("should compile named fragment with directive and arguments", () => {
      const compilationResult: CompilationResult = compileDocument(schema, document, false, emptyValidationOptions);
      const operation = compilationResult.operations[0];
      const allAnimals = operation.selectionSet.selections[0] as Field;
      const inlineFragment = allAnimals?.selectionSet?.selections?.[0] as InlineFragment;

      expect(inlineFragment.directives?.length).toEqual(1);
      
      expect(inlineFragment.directives?.[0].name).toEqual("defer");
      
      expect(inlineFragment.directives?.[0].arguments?.length).toEqual(2);
      expect(inlineFragment.directives?.[0].arguments?.[0].name).toEqual("if");
      expect(inlineFragment.directives?.[0].arguments?.[1].name).toEqual("label");
    });
  });

});
