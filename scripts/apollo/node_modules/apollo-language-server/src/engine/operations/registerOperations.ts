import gql from "graphql-tag";

export const REGISTER_OPERATIONS = gql`
  mutation RegisterOperations(
    $id: ID!
    $clientIdentity: RegisteredClientIdentityInput!
    $operations: [RegisteredOperationInput!]!
    $manifestVersion: Int!
    $graphVariant: String
  ) {
    service(id: $id) {
      registerOperationsWithResponse(
        clientIdentity: $clientIdentity
        operations: $operations
        manifestVersion: $manifestVersion
        graphVariant: $graphVariant
      ) {
        invalidOperations {
          errors {
            message
          }
          signature
        }
        newOperations {
          signature
        }
        registrationSuccess
      }
    }
  }
`;
