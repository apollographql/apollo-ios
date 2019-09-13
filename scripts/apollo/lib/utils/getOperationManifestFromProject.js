"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const apollo_graphql_1 = require("apollo-graphql");
function getOperationManifestFromProject(project) {
    const manifest = Object.entries(project.mergedOperationsAndFragmentsForService).map(([operationName, operationAST]) => {
        const printed = apollo_graphql_1.defaultOperationRegistrySignature(operationAST, operationName);
        return {
            signature: apollo_graphql_1.operationHash(printed),
            document: printed,
            metadata: {
                engineSignature: ""
            }
        };
    });
    return manifest;
}
exports.getOperationManifestFromProject = getOperationManifestFromProject;
//# sourceMappingURL=getOperationManifestFromProject.js.map