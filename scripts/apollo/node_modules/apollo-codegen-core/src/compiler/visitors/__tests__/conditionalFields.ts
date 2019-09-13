import { SelectionSet, Field, BooleanCondition } from "../..";
import { collectAndMergeFields } from "../collectAndMergeFields";
import { typeCaseForSelectionSet } from "../typeCase";

import { compile } from "./test-utils/helpers";

describe("@skip/@include directives", () => {
  it("should not mark a field as conditional when it has a no directives", () => {
    const context = compile(`
      query Hero {
        hero {
          name
        }
      }
    `);

    const selectionSet = (context.operations["Hero"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;

    expect(selectionSet).toMatchSelectionSet(["Human", "Droid"], ["name"]);
    expect(collectAndMergeFields(selectionSet)[0].isConditional).toBeFalsy();
  });

  it("should mark a field as conditional when it has a @skip directive", () => {
    const context = compile(`
      query Hero($skipName: Boolean!) {
        hero {
          name @skip(if: $skipName)
        }
      }
    `);

    const selectionSet = (context.operations["Hero"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;

    expect(selectionSet).toMatchSelectionSet(["Human", "Droid"], ["name"]);
    expect(collectAndMergeFields(selectionSet)[0].isConditional).toBeTruthy();

    expect(selectionSet.selections[0]).toMatchObject({
      variableName: "skipName"
    });
  });

  it("should not mark a field as conditional when it has a @skip directive that is always false", () => {
    const context = compile(`
      query Hero {
        hero {
          name @skip(if: false)
        }
      }
    `);

    const selectionSet = (context.operations["Hero"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;

    expect(selectionSet).toMatchSelectionSet(["Human", "Droid"], ["name"]);
    expect(collectAndMergeFields(selectionSet)[0].isConditional).toBeFalsy();
  });

  it("should not include a field when it has a @skip directive that is always true", () => {
    const context = compile(`
      query Hero {
        hero {
          name @skip(if: true)
        }
      }
    `);

    const selectionSet = (context.operations["Hero"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;

    expect(selectionSet).toMatchSelectionSet(["Human", "Droid"], []);
  });

  it("should mark a field as conditional when it has a @include directive", () => {
    const context = compile(`
      query Hero($includeName: Boolean!) {
        hero {
          name @include(if: $includeName)
        }
      }
    `);

    const selectionSet = (context.operations["Hero"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;

    expect(selectionSet).toMatchSelectionSet(["Human", "Droid"], ["name"]);
    expect(collectAndMergeFields(selectionSet)[0].isConditional).toBeTruthy();

    expect(selectionSet.selections[0]).toMatchObject({
      variableName: "includeName"
    });
  });

  it("should not mark a field as conditional when it has a @include directive that is always true", () => {
    const context = compile(`
      query Hero {
        hero {
          name @include(if: true)
        }
      }
    `);

    const selectionSet = (context.operations["Hero"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;

    expect(selectionSet).toMatchSelectionSet(["Human", "Droid"], ["name"]);
    expect(collectAndMergeFields(selectionSet)[0].isConditional).toBeFalsy();
  });

  it("should not include a field when it has a @include directive that is always false", () => {
    const context = compile(`
      query Hero {
        hero {
          name @include(if: false)
        }
      }
    `);

    const selectionSet = (context.operations["Hero"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;

    expect(selectionSet).toMatchSelectionSet(["Human", "Droid"], []);
  });

  it("should mark a field as conditional when it has both a @skip and an @include directive", () => {
    const context = compile(`
      query Hero($skipName: Boolean!, $includeName: Boolean!) {
        hero {
          name @skip(if: $skipName) @include(if: $includeName)
        }
      }
    `);

    const selectionSet = (context.operations["Hero"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;

    expect(selectionSet).toMatchSelectionSet(["Human", "Droid"], ["name"]);
    expect(collectAndMergeFields(selectionSet)[0].isConditional).toBeTruthy();

    expect(selectionSet.selections[0]).toMatchObject({
      variableName: "includeName"
    });
    expect(
      (selectionSet.selections[0] as BooleanCondition).selectionSet
        .selections[0]
    ).toMatchObject({
      variableName: "skipName"
    });
  });

  it("should mark a field as conditional when it is included twice, once with a @skip and once with an @include directive", () => {
    const context = compile(`
      query Hero($skipName: Boolean!, $includeName: Boolean!) {
        hero {
          name @skip(if: $skipName)
          name @include(if: $includeName)
        }
      }
    `);

    const selectionSet = (context.operations["Hero"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;

    expect(selectionSet).toMatchSelectionSet(["Human", "Droid"], ["name"]);
    expect(collectAndMergeFields(selectionSet)[0].isConditional).toBeTruthy();

    expect(selectionSet.selections[0]).toMatchObject({
      variableName: "skipName"
    });
    expect(selectionSet.selections[1]).toMatchObject({
      variableName: "includeName"
    });
  });

  it("should not include a field when when it has both a @skip directive and an @include directive that is always false", () => {
    const context = compile(`
      query Hero($skipName: Boolean!) {
        hero {
          name @skip(if: $skipName) @include(if: false)
        }
      }
    `);

    const selectionSet = (context.operations["Hero"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;

    expect(selectionSet).toMatchSelectionSet(["Human", "Droid"], []);
  });

  it("should not mark a field as conditional when it is included twice, once with and once without an @include directive", () => {
    const context = compile(`
      query Hero($includeName: Boolean!) {
        hero {
          name
          name @include(if: $includeName)
        }
      }
    `);

    const selectionSet = (context.operations["Hero"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;

    expect(selectionSet).toMatchSelectionSet(["Human", "Droid"], ["name"]);
    expect(collectAndMergeFields(selectionSet)[0].isConditional).toBeFalsy();
  });

  it("should not mark a field as conditional when it is included twice, once with an @include directive that is always false and once without", () => {
    const context = compile(`
      query Hero {
        hero {
          name
          name @include(if: false)
        }
      }
    `);

    const selectionSet = (context.operations["Hero"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;

    expect(selectionSet).toMatchSelectionSet(["Human", "Droid"], ["name"]);
    expect(collectAndMergeFields(selectionSet)[0].isConditional).toBeFalsy();
  });

  it("should not mark a field as conditional in a variant when it is included without a directive in an inline fragment", () => {
    const context = compile(`
      query Hero($skipName: Boolean!) {
        hero {
          name @skip(if: $skipName)
          ... on Droid {
            name
          }
        }
      }
    `);

    const selectionSet = (context.operations["Hero"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;
    const typeCase = typeCaseForSelectionSet(selectionSet);

    expect(typeCase.default).toMatchSelectionSet(["Human", "Droid"], ["name"]);
    expect(
      collectAndMergeFields(typeCase.default)[0].isConditional
    ).toBeTruthy();

    expect(typeCase.variants).toHaveLength(1);
    expect(typeCase.variants).toContainSelectionSetMatching(
      ["Droid"],
      ["name"]
    );
    expect(
      collectAndMergeFields(typeCase.variants[0])[0].isConditional
    ).toBeFalsy();
  });

  it("should not mark a field as conditional in a variant when it is included without a directive in the default case", () => {
    const context = compile(`
      query Hero($skipName: Boolean!) {
        hero {
          name
          ... on Droid {
            name @skip(if: $skipName)
          }
        }
      }
    `);

    const selectionSet = (context.operations["Hero"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;
    const typeCase = typeCaseForSelectionSet(selectionSet);

    expect(typeCase.default).toMatchSelectionSet(["Human", "Droid"], ["name"]);
    expect(
      collectAndMergeFields(typeCase.default)[0].isConditional
    ).toBeFalsy();

    expect(typeCase.variants).toHaveLength(1);
    expect(typeCase.variants).toContainSelectionSetMatching(
      ["Droid"],
      ["name"]
    );
    expect(
      collectAndMergeFields(typeCase.variants[0])[0].isConditional
    ).toBeFalsy();
  });

  it("should not mark a field as conditional when the parent selection set is included conditionally", () => {
    const context = compile(`
      query Hero($includeFriends: Boolean!) {
        hero {
          friends @include(if: $includeFriends) {
            name
          }
        }
      }
    `);

    const heroField = context.operations["Hero"].selectionSet.selections[0];
    const friendsField = collectAndMergeFields(
      heroField.selectionSet as SelectionSet
    )[0];

    expect(friendsField.isConditional).toBeTruthy();
    expect(friendsField.selectionSet as SelectionSet).toMatchSelectionSet(
      ["Human", "Droid"],
      ["name"]
    );
    expect(
      collectAndMergeFields(friendsField.selectionSet as SelectionSet)[0]
        .isConditional
    ).toBeFalsy();
  });

  it("should mark a field as conditional when the parent selection set is first included conditionally and then the parent field is also included unconditionally", () => {
    const context = compile(`
      query Hero($includeFriends: Boolean!) {
        hero {
          friends @include(if: $includeFriends) {
            name
          }
          friends {
            id
          }
        }
      }
    `);

    const heroField = context.operations["Hero"].selectionSet.selections[0];
    const friendsField = collectAndMergeFields(
      heroField.selectionSet as SelectionSet
    )[0];

    expect(friendsField.isConditional).toBeFalsy();
    expect(friendsField.selectionSet).toMatchSelectionSet(
      ["Human", "Droid"],
      ["name", "id"]
    );
    expect(
      collectAndMergeFields(friendsField.selectionSet as SelectionSet)[0]
        .isConditional
    ).toBeTruthy();
    expect(
      collectAndMergeFields(friendsField.selectionSet as SelectionSet)[1]
        .isConditional
    ).toBeFalsy();
  });

  it("should mark a field as conditional when the parent selection set is first included unconditionally and then the parent field is also included conditionally", () => {
    const context = compile(`
      query Hero($includeFriends: Boolean!) {
        hero {
          friends {
            id
          }
          friends @include(if: $includeFriends) {
            name
          }
        }
      }
    `);

    const heroField = context.operations["Hero"].selectionSet.selections[0];
    const friendsField = collectAndMergeFields(
      heroField.selectionSet as SelectionSet
    )[0];

    expect(friendsField.isConditional).toBeFalsy();
    expect(friendsField.selectionSet).toMatchSelectionSet(
      ["Human", "Droid"],
      ["id", "name"]
    );
    expect(
      collectAndMergeFields(friendsField.selectionSet as SelectionSet)[0]
        .isConditional
    ).toBeFalsy();
    expect(
      collectAndMergeFields(friendsField.selectionSet as SelectionSet)[1]
        .isConditional
    ).toBeTruthy();
  });
});
