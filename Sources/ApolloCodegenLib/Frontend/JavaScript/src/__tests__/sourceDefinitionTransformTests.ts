
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
  DocumentNode
} from "graphql";

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

  const schema: GraphQLSchema = loadSchemaFromSDL(new Source(schemaSDL, "Test Schema", { line: 1, column: 1 }));

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

    const document: DocumentNode = parseDocument(
      new Source(documentString, "Test Query", { line: 1, column: 1 }),
      false
    );

    it("operation definition should have source including __typename field.", () => {
      const compilationResult: CompilationResult = compileDocument(schema, document);
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

    const document: DocumentNode = parseDocument(
      new Source(documentString, "Test Query", { line: 1, column: 1 }),
      false
    );

    it("operation definition should have source including __typename field with no directives.", () => {
      const compilationResult: CompilationResult = compileDocument(schema, document);
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

    const document: DocumentNode = parseDocument(
      new Source(documentString, "Test Query", { line: 1, column: 1 }),
      false
    );

    it("operation definition should have source not including local cache mutation directive.", () => {
      const compilationResult: CompilationResult = compileDocument(schema, document);
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