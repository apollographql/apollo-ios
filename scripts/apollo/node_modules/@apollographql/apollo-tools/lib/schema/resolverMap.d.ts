import { GraphQLFieldResolver } from "graphql";
export interface GraphQLResolverMap<TContext> {
    [typeName: string]: {
        [fieldName: string]: GraphQLFieldResolver<any, TContext> | {
            requires?: string;
            resolve: GraphQLFieldResolver<any, TContext>;
            subscribe?: undefined;
        } | {
            requires?: string;
            resolve?: undefined;
            subscribe: GraphQLFieldResolver<any, TContext>;
        } | {
            requires?: string;
            resolve: GraphQLFieldResolver<any, TContext>;
            subscribe: GraphQLFieldResolver<any, TContext>;
        };
    };
}
//# sourceMappingURL=resolverMap.d.ts.map