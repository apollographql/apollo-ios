import gql from "graphql-tag";

export const LIST_SERVICES = gql`
  query ListServices($id: ID!, $graphVariant: String!) {
    service(id: $id) {
      implementingServices(graphVariant: $graphVariant) {
        __typename
        ... on FederatedImplementingServices {
          services {
            graphID
            graphVariant
            name
            url
            updatedAt
          }
        }
      }
    }
  }
`;
