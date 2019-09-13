import { GraphQLError } from "graphql";
export declare class GraphQLSchemaValidationError extends Error {
    errors: ReadonlyArray<GraphQLError>;
    constructor(errors: ReadonlyArray<GraphQLError>);
}
//# sourceMappingURL=GraphQLSchemaValidationError.d.ts.map