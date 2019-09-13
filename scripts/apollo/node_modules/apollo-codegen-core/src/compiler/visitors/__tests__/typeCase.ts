import { buildSchema } from "graphql";
import { compile } from "./test-utils/helpers";

import { SelectionSet, Field } from "../..";
import { typeCaseForSelectionSet } from "../typeCase";
import { collectAndMergeFields } from "../collectAndMergeFields";

export const animalSchema = buildSchema(`
  type Query {
    animal: Animal
    catOrBird: CatOrBird
  }

  union Animal = Cat | Bird | Crocodile | Fish
  union CatOrBird = Cat | Bird

  interface Pet {
    name: String!
  }

  interface WarmBlooded {
    bodyTemperature: Int!
  }

  type Cat implements Pet & WarmBlooded {
    name: String!
    bodyTemperature: Int!
  }

  type Bird implements Pet & WarmBlooded {
    name: String!
    bodyTemperature: Int!
  }

  type Fish implements Pet {
    name: String!
  }

  type Crocodile {
    age: Int!
  }
`);

describe("TypeCase", () => {
  it("should recursively include inline fragments with type conditions that match the parent type", () => {
    const context = compile(`
      query Hero {
        hero {
          id
          ... on Character {
            name
            ... on Character {
              id
              appearsIn
            }
            id
          }
        }
      }
    `);

    const selectionSet = (context.operations["Hero"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;
    const typeCase = typeCaseForSelectionSet(selectionSet);

    expect(typeCase.default).toMatchSelectionSet(
      ["Human", "Droid"],
      ["id", "name", "appearsIn"]
    );

    expect(typeCase.variants).toHaveLength(0);

    expect(typeCase.exhaustiveVariants).toHaveLength(1);
    expect(typeCase.exhaustiveVariants).toContainSelectionSetMatching(
      ["Human", "Droid"],
      ["id", "name", "appearsIn"]
    );
  });

  it("should recursively include fragment spreads with type conditions that match the parent type", () => {
    const context = compile(`
      query Hero {
        hero {
          id
          ...HeroDetails
        }
      }

      fragment HeroDetails on Character {
        name
        ...MoreHeroDetails
        id
      }

      fragment MoreHeroDetails on Character {
        appearsIn
      }
    `);

    const selectionSet = (context.operations["Hero"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;
    const typeCase = typeCaseForSelectionSet(selectionSet);

    expect(typeCase.default).toMatchSelectionSet(
      ["Human", "Droid"],
      ["id", "name", "appearsIn"]
    );
    expect(
      typeCase.default.fragmentSpreads.map(
        fragmentSpread => fragmentSpread.fragmentName
      )
    ).toEqual(["HeroDetails", "MoreHeroDetails"]);

    expect(typeCase.variants).toHaveLength(0);

    expect(typeCase.exhaustiveVariants).toHaveLength(1);
    expect(typeCase.exhaustiveVariants).toContainSelectionSetMatching(
      ["Human", "Droid"],
      ["id", "name", "appearsIn"]
    );
  });

  it("should include fragment spreads when nested within inline fragments", () => {
    const context = compile(`
      query Hero {
        hero {
          ... on Character {
            ...CharacterName
          }
        }
      }

      fragment CharacterName on Character {
        name
      }
    `);

    const selectionSet = (context.operations["Hero"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;
    const typeCase = typeCaseForSelectionSet(selectionSet);

    expect(typeCase.default).toMatchSelectionSet(["Human", "Droid"], ["name"]);
    expect(
      typeCase.default.fragmentSpreads.map(
        fragmentSpread => fragmentSpread.fragmentName
      )
    ).toEqual(["CharacterName"]);

    expect(typeCase.variants).toHaveLength(0);
  });

  it("should only include fragment spreads once even if included twice in different subselections", () => {
    const context = compile(`
      query Hero {
        hero {
          friends {
            ...CharacterName
          }
          ... on Droid {
            friends {
              ...CharacterName
            }
          }
        }
      }

      fragment CharacterName on Character {
        name
      }
    `);

    const selectionSet = (context.operations["Hero"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;
    const typeCase = typeCaseForSelectionSet(collectAndMergeFields(
      typeCaseForSelectionSet(selectionSet).variants[0]
    )[0].selectionSet as SelectionSet);

    expect(typeCase.default).toMatchSelectionSet(["Human", "Droid"], ["name"]);
    expect(
      typeCase.default.fragmentSpreads.map(
        fragmentSpread => fragmentSpread.fragmentName
      )
    ).toEqual(["CharacterName"]);
  });

  it("should ignore type modifiers when matching the parent type", () => {
    const schema = buildSchema(`
      type Query {
        heroes: [Character]
      }

      interface Character {
        name: String!
      }

      type Human implements Character {
        name: String!
      }

      type Droid implements Character {
        name: String!
      }
    `);

    const context = compile(
      `
      query Hero {
        heroes {
          ... on Character {
            name
          }
        }
      }
    `,
      schema
    );

    const selectionSet = (context.operations["Hero"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;
    const typeCase = typeCaseForSelectionSet(selectionSet);

    expect(typeCase.default).toMatchSelectionSet(["Human", "Droid"], ["name"]);

    expect(typeCase.variants).toHaveLength(0);

    expect(typeCase.exhaustiveVariants).toHaveLength(1);
    expect(typeCase.exhaustiveVariants).toContainSelectionSetMatching(
      ["Human", "Droid"],
      ["name"]
    );
  });

  it("should merge fields from the default case into type conditions", () => {
    const context = compile(`
      query Hero {
        hero {
          name
          ... on Droid {
            primaryFunction
          }
          appearsIn
          ... on Human {
            height
          }
        }
      }
    `);

    const selectionSet = (context.operations["Hero"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;
    const typeCase = typeCaseForSelectionSet(selectionSet);

    expect(typeCase.default).toMatchSelectionSet(
      ["Human", "Droid"],
      ["name", "appearsIn"]
    );

    expect(typeCase.variants).toHaveLength(2);
    expect(typeCase.variants).toContainSelectionSetMatching(
      ["Droid"],
      ["name", "primaryFunction", "appearsIn"]
    );
    expect(typeCase.variants).toContainSelectionSetMatching(
      ["Human"],
      ["name", "appearsIn", "height"]
    );

    expect(typeCase.exhaustiveVariants).toHaveLength(2);
    expect(typeCase.exhaustiveVariants).toContainSelectionSetMatching(
      ["Droid"],
      ["name", "primaryFunction", "appearsIn"]
    );
    expect(typeCase.exhaustiveVariants).toContainSelectionSetMatching(
      ["Human"],
      ["name", "appearsIn", "height"]
    );
  });

  it(`should merge fields from type conditions with the same type`, () => {
    const context = compile(`
      query Hero {
        hero {
          name
          ... on Droid {
            primaryFunction
          }
          ... on Droid {
            appearsIn
          }
        }
      }
    `);

    const selectionSet = (context.operations["Hero"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;
    const typeCase = typeCaseForSelectionSet(selectionSet);

    expect(typeCase.default).toMatchSelectionSet(["Human", "Droid"], ["name"]);

    expect(typeCase.variants).toHaveLength(1);
    expect(typeCase.variants).toContainSelectionSetMatching(
      ["Droid"],
      ["name", "primaryFunction", "appearsIn"]
    );

    expect(typeCase.exhaustiveVariants).toHaveLength(2);
    expect(typeCase.exhaustiveVariants).toContainSelectionSetMatching(
      ["Droid"],
      ["name", "primaryFunction", "appearsIn"]
    );
    expect(typeCase.exhaustiveVariants).toContainSelectionSetMatching(
      ["Human"],
      ["name"]
    );
  });

  it("should inherit type condition when nesting an inline fragment in an inline fragment with a more specific type condition", () => {
    const context = compile(`
      query Hero {
        hero {
          ... on Droid {
            ... on Character {
              name
            }
          }
        }
      }
    `);

    const selectionSet = (context.operations["Hero"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;
    const typeCase = typeCaseForSelectionSet(selectionSet);

    expect(typeCase.default).toMatchSelectionSet(["Human", "Droid"], []);

    expect(typeCase.variants).toHaveLength(1);
    expect(typeCase.variants).toContainSelectionSetMatching(
      ["Droid"],
      ["name"]
    );

    expect(typeCase.exhaustiveVariants).toHaveLength(2);
    expect(typeCase.exhaustiveVariants).toContainSelectionSetMatching(
      ["Droid"],
      ["name"]
    );
    expect(typeCase.exhaustiveVariants).toContainSelectionSetMatching(
      ["Human"],
      []
    );
  });

  it("should not inherit type condition when nesting an inline fragment in an inline fragment with a less specific type condition", () => {
    const context = compile(`
      query Hero {
        hero {
          ... on Character {
            ... on Droid {
              name
            }
          }
        }
      }
    `);

    const selectionSet = (context.operations["Hero"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;
    const typeCase = typeCaseForSelectionSet(selectionSet);

    expect(typeCase.default).toMatchSelectionSet(["Human", "Droid"], []);

    expect(typeCase.variants).toHaveLength(1);
    expect(typeCase.variants).toContainSelectionSetMatching(
      ["Droid"],
      ["name"]
    );

    expect(typeCase.exhaustiveVariants).toHaveLength(2);
    expect(typeCase.exhaustiveVariants).toContainSelectionSetMatching(
      ["Droid"],
      ["name"]
    );
    expect(typeCase.exhaustiveVariants).toContainSelectionSetMatching(
      ["Human"],
      []
    );
  });

  it("should merge fields from the parent case into nested type conditions", () => {
    const context = compile(
      `
      query Animal {
        animal {
          ... on Pet {
            name
            ... on WarmBlooded {
              bodyTemperature
            }
          }
        }
      }
    `,
      animalSchema
    );

    const selectionSet = (context.operations["Animal"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;
    const typeCase = typeCaseForSelectionSet(selectionSet);

    expect(typeCase.default).toMatchSelectionSet(
      ["Cat", "Bird", "Fish", "Crocodile"],
      []
    );

    expect(typeCase.variants).toHaveLength(2);
    expect(typeCase.variants).toContainSelectionSetMatching(
      ["Cat", "Bird"],
      ["name", "bodyTemperature"]
    );
    expect(typeCase.variants).toContainSelectionSetMatching(["Fish"], ["name"]);

    expect(typeCase.exhaustiveVariants).toHaveLength(3);
    expect(typeCase.exhaustiveVariants).toContainSelectionSetMatching(
      ["Cat", "Bird"],
      ["name", "bodyTemperature"]
    );
    expect(typeCase.exhaustiveVariants).toContainSelectionSetMatching(
      ["Fish"],
      ["name"]
    );
    expect(typeCase.exhaustiveVariants).toContainSelectionSetMatching(
      ["Crocodile"],
      []
    );
  });

  it("should merge fields from the parent case into nested type conditions", () => {
    const context = compile(
      `
      query Animal {
        animal {
          ... on Pet {
            name
            ... on WarmBlooded {
              bodyTemperature
            }
          }
          ... on WarmBlooded {
            bodyTemperature
            ... on Pet {
              name
            }
          }
        }
      }
    `,
      animalSchema
    );

    const selectionSet = (context.operations["Animal"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;
    const typeCase = typeCaseForSelectionSet(selectionSet);

    expect(typeCase.default).toMatchSelectionSet(
      ["Cat", "Bird", "Fish", "Crocodile"],
      []
    );

    expect(typeCase.variants).toHaveLength(2);
    expect(typeCase.variants).toContainSelectionSetMatching(
      ["Cat", "Bird"],
      ["name", "bodyTemperature"]
    );
    expect(typeCase.variants).toContainSelectionSetMatching(["Fish"], ["name"]);

    expect(typeCase.exhaustiveVariants).toHaveLength(3);
    expect(typeCase.exhaustiveVariants).toContainSelectionSetMatching(
      ["Cat", "Bird"],
      ["name", "bodyTemperature"]
    );
    expect(typeCase.exhaustiveVariants).toContainSelectionSetMatching(
      ["Fish"],
      ["name"]
    );
    expect(typeCase.exhaustiveVariants).toContainSelectionSetMatching(
      ["Crocodile"],
      []
    );
  });

  it("should not keep type conditions when all possible objects match", () => {
    const context = compile(
      `
      query Animal {
        catOrBird {
          ... on Pet {
            name
            ... on WarmBlooded {
              bodyTemperature
            }
          }
        }
      }
    `,
      animalSchema
    );

    const selectionSet = (context.operations["Animal"].selectionSet
      .selections[0] as Field).selectionSet as SelectionSet;
    const typeCase = typeCaseForSelectionSet(selectionSet);

    expect(typeCase.default).toMatchSelectionSet(
      ["Cat", "Bird"],
      ["name", "bodyTemperature"]
    );
    expect(typeCase.variants).toHaveLength(0);

    expect(typeCase.exhaustiveVariants).toHaveLength(1);
    expect(typeCase.exhaustiveVariants).toContainSelectionSetMatching(
      ["Cat", "Bird"],
      ["name", "bodyTemperature"]
    );
  });
});
