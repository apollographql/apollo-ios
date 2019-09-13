import { parse, GraphQLSchema } from "graphql";
import { compileToIR, CompilerOptions } from "../../..";
import { loadSchema } from "../../../../loading";

export const starWarsSchema = loadSchema(
  require.resolve("../../../../../../../__fixtures__/starwars/schema.json")
);

export function compile(
  source: string,
  schema: GraphQLSchema = starWarsSchema,
  options: CompilerOptions = {}
) {
  const document = parse(source);
  return compileToIR(schema, document, options);
}
