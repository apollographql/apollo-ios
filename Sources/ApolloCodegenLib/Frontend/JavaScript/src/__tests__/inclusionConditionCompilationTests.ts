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
  InclusionConditionVariable,
  InlineFragment
} from "../compiler/ir"
import { 
  Source,
  GraphQLSchema,
  DocumentNode
} from "graphql";

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

  describe("query has inline fragment with @include directive", () => {
    const documentString: string = `
    query Test($a: Boolean!) {
      allAnimals {
        ... @include(if: $a) {
          species
        }
      }
    }
    `;

    const document: DocumentNode = parseOperationDocument(
      new Source(documentString, "Test Query", { line: 1, column: 1 }),
      false
    );

    it("should compile inline fragment with inclusion condition", () => {
      const compilationResult: CompilationResult = compileDocument(schema, document);
      const operation = compilationResult.operations[0];
      const allAnimals = operation.selectionSet.selections[0] as Field;
      const inlineFragment = allAnimals?.selectionSet?.selections?.[0] as InlineFragment;

      const expected: InclusionConditionVariable = {
        variable: "a",
        isInverted: false
      };

      expect(inlineFragment.inclusionConditions?.length).toEqual(1);

      expect(inlineFragment.inclusionConditions?.[0]).toEqual(expected);
    });
  });

});