import { GraphQLSchema, GraphQLNamedType } from "graphql";
declare type TypeTransformer = (type: GraphQLNamedType) => GraphQLNamedType | null | undefined;
export declare function transformSchema(schema: GraphQLSchema, transformType: TypeTransformer): GraphQLSchema;
export {};
//# sourceMappingURL=transformSchema.d.ts.map