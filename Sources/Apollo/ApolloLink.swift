public typealias NextLink<Operation: GraphQLOperation> = (Operation, LinkContext) -> Promise<GraphQLResponse<Operation>>
