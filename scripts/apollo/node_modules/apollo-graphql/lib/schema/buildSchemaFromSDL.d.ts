import { DocumentNode, GraphQLSchema } from "graphql";
import { GraphQLResolverMap } from "./resolverMap";
export interface GraphQLSchemaModule {
    typeDefs: DocumentNode;
    resolvers?: GraphQLResolverMap<any>;
}
export declare function modulesFromSDL(modulesOrSDL: (GraphQLSchemaModule | DocumentNode)[] | DocumentNode): GraphQLSchemaModule[];
export declare function buildSchemaFromSDL(modulesOrSDL: (GraphQLSchemaModule | DocumentNode)[] | DocumentNode, schemaToExtend?: GraphQLSchema): GraphQLSchema;
export declare function addResolversToSchema(schema: GraphQLSchema, resolvers: GraphQLResolverMap<any>): void;
//# sourceMappingURL=buildSchemaFromSDL.d.ts.map