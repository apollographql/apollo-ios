import { GraphQLError } from "graphql";

export class GraphQLSchemaValidationError extends Error {
  constructor(public errors: ReadonlyArray<GraphQLError>) {
    super();

    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
    this.message = errors.map(error => error.message).join("\n\n");
  }
}
