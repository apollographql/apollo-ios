
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
  DocumentNode
} from "graphql";
import { emptyValidationOptions } from "../__testUtils__/validationHelpers";

describe("given schema", () => {
  const schemaSDL: string = 
`type Query {
  allAnimals: [Animal!]
}

interface Animal {
  species: String!
  friend: Animal!
}

interface Pet {
  name: String!
}`;

  const schema: GraphQLSchema = loadSchemaFromSources([new Source(schemaSDL, "Test Schema", { line: 1, column: 1 })]);

  describe("given query not including __typename fields", () => {
    const documentString: string = 
`query Test {
  allAnimals {        
    species
    ... on Pet {
      name
    }
  }
}`;

    const document: DocumentNode = parseOperationDocument(
      new Source(documentString, "Test Query", { line: 1, column: 1 }),
      false
    );

    describe("compile document", () => {
      const compilationResult: CompilationResult = compileDocument(schema, document, false, emptyValidationOptions);

      it("operation definition should have source including __typename field.", () => {
        const operation = compilationResult.operations[0];
  
        const expected: string = 
`query Test {
  allAnimals {
    __typename
    species
    ... on Pet {
      name
    }
  }
}`;
              
        expect(operation.source).toEqual(expected);
      });
    });

    describe("compile document for legacy compatible safelisting", () => {
      const compilationResult: CompilationResult = compileDocument(schema, document, true, emptyValidationOptions);

      it("operation definition should have source including __typename field in each selection set.", () => {
        const operation = compilationResult.operations[0];
  
        const expected: string = 
`query Test {
  allAnimals {
    __typename
    species
    ... on Pet {
      __typename
      name
    }
  }
}`;
              
        expect(operation.source).toEqual(expected);
      });
    });
  });
    

  describe("given query including __typename field with directive", () => {
    const documentString: string = 
`query Test {
  allAnimals {        
    __typename @include(if: true)
    species
    ... on Pet {
      name
    }
  }
}`;

    const document: DocumentNode = parseOperationDocument(
      new Source(documentString, "Test Query", { line: 1, column: 1 }),
      false
    );

    it("operation definition should have source including __typename field with no directives.", () => {
      const compilationResult: CompilationResult = compileDocument(schema, document, false, emptyValidationOptions);
      const operation = compilationResult.operations[0];

      const expected: string = 
`query Test {
  allAnimals {
    __typename
    species
    ... on Pet {
      name
    }
  }
}`;
            
      expect(operation.source).toEqual(expected);
    });
  });

  describe("given query with local cache mutation directive", () => {
    const documentString: string = 
`query Test @apollo_client_ios_localCacheMutation {
  allAnimals {        
    species
    ... on Pet {
      name
    }
  }
}`;

    const document: DocumentNode = parseOperationDocument(
      new Source(documentString, "Test Query", { line: 1, column: 1 }),
      false
    );

    it("operation definition should have source not including local cache mutation directive.", () => {
      const compilationResult: CompilationResult = compileDocument(schema, document, false, emptyValidationOptions);
      const operation = compilationResult.operations[0];

      const expected: string = 
`query Test {
  allAnimals {
    __typename
    species
    ... on Pet {
      name
    }
  }
}`;
            
      expect(operation.source).toEqual(expected);
    });
  });

  describe("given fragment not including __typename field", () => {
    const documentString: string = 
`fragment Test on Animal {  
  species  
}`;

    const document: DocumentNode = parseOperationDocument(
      new Source(documentString, "Test Fragment", { line: 1, column: 1 }),
      false
    );

    it("fragment definition should have source including __typename field.", () => {
      const compilationResult: CompilationResult = compileDocument(schema, document, false, emptyValidationOptions);
      const fragment = compilationResult.fragments[0];

      const expected: string = 
`fragment Test on Animal {
  __typename
  species
}`;
            
      expect(fragment.source).toEqual(expected);
    });
  });
});