import { parse, print } from "graphql";
import {
  withTypenameFieldAddedWhereNeeded,
  removeConnectionDirectives,
  removeClientDirectives
} from "../graphql";

describe("typename additions", () => {
  it("adds typenames to selectionSets", () => {
    const original = parse(`
      query GetUser {
          me {
          firstName
          friends {
            firstName
          }
        }
      }
    `);

    const modified = print(
      parse(`
      query GetUser {
        me {
          __typename
          firstName
          friends {
            __typename
            firstName
          }
        }
      }
    `)
    );

    const newQuery = withTypenameFieldAddedWhereNeeded(original);
    expect(print(newQuery)).toEqual(modified);
  });
});

describe("client removals", () => {
  it("removes the @connection directive", () => {
    const original = parse(`
      query GetUser {
        list @connection(key: "Value")
      }
    `);

    const modified = print(
      parse(`
      query GetUser {
        list
      }
    `)
    );

    const newQuery = removeConnectionDirectives(original);
    expect(print(newQuery)).toEqual(modified);
  });
  it("removes @client id from a mixed query", () => {
    const original = parse(`
      query GetUser {
        list @client
        remote {
          id
          virtual @client
          virtualSelectionSet @client @export(as: "id") {
            name
          }
        }
      }
    `);

    const modified = print(
      parse(`
      query GetUser {
        remote {
          id
        }
      }
    `)
    );

    const newQuery = removeClientDirectives(original);
    expect(print(newQuery)).toEqual(modified);
  });
  it("returns and empty string when removing all fields", () => {
    const original = parse(`
      query GetUser {
        list @client
        local @client {
          id
        }
      }
    `);

    const newQuery = removeClientDirectives(original);
    expect(print(newQuery).trim()).toBeFalsy();
  });
});
