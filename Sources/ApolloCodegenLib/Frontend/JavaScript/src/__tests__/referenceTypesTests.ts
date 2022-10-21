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
import {
  readFileSync
} from "fs"
import {
  join
} from 'path';
import { emptyValidationOptions } from "../__testUtils__/validationHelpers";

describe("mutation defined using ReportCarProblemInput", () => {
  const documentString: string = `
  mutation Test($input: ReportCarProblemInput!) {
    mutateCar(input: $input) {
      name
    }
  }
  `;

  const document: DocumentNode = parseOperationDocument(
    new Source(documentString, "Test Mutation", { line: 1, column: 1 }),
    false
  );

  describe("given schema from introspection JSON with mutation using input type with enum field", () => {
    const schemaJSON: string = readFileSync(join(__dirname, "./input-object-enum-test-schema.json"), 'utf-8')
    const schema: GraphQLSchema = loadSchemaFromSources([new Source(schemaJSON, "TestSchema.json", { line: 1, column: 1 })]);

    it("should compile with referencedTypes including ReportCarProblemInput and CarProblem enum", () => {
      const compilationResult: CompilationResult = compileDocument(schema, document, false, emptyValidationOptions);
      const reportCarProblemInput: GraphQLInputObjectType = compilationResult.referencedTypes.find(function(element) {
        return element.name == 'ReportCarProblemInput'
      }) as GraphQLInputObjectType
      const carProblemEnum: GraphQLEnumType = compilationResult.referencedTypes.find(function(element) {
        return element.name == 'CarProblem'
      }) as GraphQLEnumType

      expect(reportCarProblemInput).not.toBeUndefined()
      expect(carProblemEnum).not.toBeUndefined()
    });
  });

  describe("given schema from SDL with mutation using input type with enum field", () => {
    const schemaSDL: string = `
    type Query {
      cars: [Car!]
    }

    type Mutation {
      mutateCar(input: ReportCarProblemInput!): Car!
    }

    input ReportCarProblemInput {
      problem: CarProblem!
    }

    enum CarProblem {
      RADIATOR
    }

    interface Car {
      name: String!
    }
    `;

    const schema: GraphQLSchema = loadSchemaFromSources([new Source(schemaSDL, "Test Schema", { line: 1, column: 1 })]);

    it("should compile with referencedTypes inlcuding InputObject and enum", () => {
      const compilationResult: CompilationResult = compileDocument(schema, document, false, emptyValidationOptions);
      const reportCarProblemInput: GraphQLInputObjectType = compilationResult.referencedTypes.find(function(element) {
        return element.name == 'ReportCarProblemInput'
      }) as GraphQLInputObjectType
      const carProblemEnum: GraphQLEnumType = compilationResult.referencedTypes.find(function(element) {
        return element.name == 'CarProblem'
      }) as GraphQLEnumType

      expect(reportCarProblemInput).not.toBeUndefined()
      expect(carProblemEnum).not.toBeUndefined()
    });
  });
});
