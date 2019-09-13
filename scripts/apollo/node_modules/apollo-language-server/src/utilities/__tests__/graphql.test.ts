import gql from "graphql-tag";
import { parse, print } from "graphql";
import {
  withTypenameFieldAddedWhereNeeded,
  removeDirectiveAnnotatedFields
} from "../graphql";

describe("withTypenameFieldAddedWhereNeeded", () => {
  it("properly adds __typename to each selectionSet", () => {
    const query = gql`
      query Product {
        product {
          sku
          color {
            id
            value
          }
        }
      }
    `;

    const withTypenames = withTypenameFieldAddedWhereNeeded(query);

    expect(print(withTypenames)).toMatchInlineSnapshot(`
      "query Product {
        product {
          __typename
          sku
          color {
            __typename
            id
            value
          }
        }
      }
      "
    `);
  });

  it("adds __typename to InlineFragment nodes (as ApolloClient does)", () => {
    const query = gql`
      query CartItems {
        product {
          items {
            ... on Table {
              material
            }
            ... on Paint {
              color
            }
          }
        }
      }
    `;

    const withTypenames = withTypenameFieldAddedWhereNeeded(query);

    expect(print(withTypenames)).toMatchInlineSnapshot(`
      "query CartItems {
        product {
          __typename
          items {
            __typename
            ... on Table {
              __typename
              material
            }
            ... on Paint {
              __typename
              color
            }
          }
        }
      }
      "
    `);
  });
});

describe("removeDirectiveAnnotatedFields", () => {
  it("should remove fields with matching directives", () => {
    expect(
      print(
        removeDirectiveAnnotatedFields(
          parse(`query Query { fieldToKeep fieldToRemove @client }`),
          ["client"]
        )
      )
    ).toMatchInlineSnapshot(`
            "query Query {
              fieldToKeep
            }
            "
        `);
  });

  it("trim selections sets that are client only", () => {
    expect(
      print(
        removeDirectiveAnnotatedFields(
          parse(`
            query Query {
              fieldToKeep
              fieldToRemove @client {
                childField
              }
            }
          `),
          ["client"]
        )
      )
    ).toMatchInlineSnapshot(`
      "query Query {
        fieldToKeep
      }
      "
    `);
  });

  it("should remove fragments when a directive is used on a fragment spread", () => {
    expect(
      print(
        removeDirectiveAnnotatedFields(
          parse(`
            {
              me { name }
              ...ClientFields @client
            }
            fragment ClientFields on Query {
              hello
            }
          `),
          ["client"]
        )
      )
    ).toMatchInlineSnapshot(`
        "{
          me {
            name
          }
        }
        "
    `);
  });

  it("should remove fragments when client directive is used inline", () => {
    expect(
      print(
        removeDirectiveAnnotatedFields(
          parse(`
            {
              me { name }
              ... on Query @client {
                hello
              }
            }
          `),
          ["client"]
        )
      )
    ).toMatchInlineSnapshot(`
            "{
              me {
                name
              }
            }
            "
        `);
  });

  it("should remove fragments when the client directive is on the definition", () => {
    expect(
      print(
        removeDirectiveAnnotatedFields(
          parse(`
            fragment ClientObject on Query @client {
              hello
            }
            {
              me { name }
              ... ClientObject
            }
          `),
          ["client"]
        )
      )
    ).toMatchInlineSnapshot(`
      "{
        me {
          name
        }
      }
      "
    `);
  });

  it("should remove fragments that become unused when antecendant directives are removed", () => {
    expect(
      print(
        removeDirectiveAnnotatedFields(
          parse(`
            fragment ClientObjectFragment on ClientObject {
              string
              number
            }

            fragment LaunchTile on Launch {
              __typename
              id
              isBooked
              rocket {
                id
                name
              }
              mission {
                name
                missionPatch
              }
            }

            query LaunchDetails($launchId: ID!) {
              launch(id: $launchId) {
                isInCart @client
                clientObject @client {
                  ...ClientObjectFragment
                }
                site
                rocket {
                  type
                }
                ...LaunchTile
              }
            }
          `),
          ["client"]
        )
      )
    ).toMatchInlineSnapshot(`
      "fragment LaunchTile on Launch {
        __typename
        id
        isBooked
        rocket {
          id
          name
        }
        mission {
          name
          missionPatch
        }
      }

      query LaunchDetails($launchId: ID!) {
        launch(id: $launchId) {
          site
          rocket {
            type
          }
          ...LaunchTile
        }
      }
      "
    `);
  });

  it("should recursively remove fragments that become unused when antecendant directives are removed", () => {
    expect(
      print(
        removeDirectiveAnnotatedFields(
          parse(`
            fragment One on Node {
              ...Two
              user {
                friends {
                  name
                  ...Two @client
                }
              }
            }
            fragment Two on Node {
              id
            }

            query {
              me {
                ...One
              }
            }
          `),
          ["client"]
        )
      )
    ).toMatchInlineSnapshot(`
      "fragment One on Node {
        ...Two
        user {
          friends {
            name
          }
        }
      }

      fragment Two on Node {
        id
      }

      {
        me {
          ...One
        }
      }
      "
    `);
  });

  it("should remove fragment spreads from @client fragment definitions", () => {
    expect(
      print(
        removeDirectiveAnnotatedFields(
          parse(`
            fragment One on Node @client {
              ...Two
            }

            fragment Two on Node {
              id
            }

            query {
              me {
                name
                ...One
              }
            }
          `),
          ["client"]
        )
      )
    ).toMatchInlineSnapshot(`
      "{
        me {
          name
        }
      }
      "
    `);
  });

  it("should remove all operations that have no selection set after fragments are removed", () => {
    expect(
      print(
        removeDirectiveAnnotatedFields(
          parse(`
            fragment One on Node @client {
              ...Two
            }

            fragment Two on Node {
              id
            }

            {
              name
              me {
                ...One
              }
            }
          `),
          ["client"]
        )
      )
    ).toMatchInlineSnapshot(`
      "{
        name
      }
      "
    `);
  });

  it("should not remove fragment definitions that weren't removed by `removeDirectiveAnnotatedFields`", () => {
    expect(
      print(
        removeDirectiveAnnotatedFields(
          parse(`
            fragment One on Node {
              id
            }

            {
              me {
                name
              }
            }
          `),
          ["client"]
        )
      )
    ).toMatchInlineSnapshot(`
      "fragment One on Node {
        id
      }

      {
        me {
          name
        }
      }
      "
    `);
  });
});
