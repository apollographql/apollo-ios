import { stripIndent } from "common-tags";

import {
  parse,
  isType,
  GraphQLID,
  GraphQLString,
  GraphQLList,
  GraphQLNonNull
} from "graphql";

import { loadSchema } from "../../loading";

import { compileToLegacyIR } from "../legacyIR";
import { serializeAST } from "../../serializeToJSON";

function withStringifiedTypes(ir) {
  return JSON.parse(serializeAST(ir));
}

const schema = loadSchema(
  require.resolve("../../../../../__fixtures__/starwars/schema.json")
);

describe("Compiling query documents to the legacy IR", () => {
  it(`should include variables defined in operations`, () => {
    const document = parse(`
      query HeroName($episode: Episode) {
        hero(episode: $episode) {
          name
        }
      }

      query Search($text: String!) {
        search(text: $text) {
          ... on Character {
            name
          }
        }
      }

      mutation CreateReviewForEpisode($episode: Episode!, $review: ReviewInput!) {
        createReview(episode: $episode, review: $review) {
          stars
          commentary
        }
      }
    `);

    const { operations } = withStringifiedTypes(
      compileToLegacyIR(schema, document)
    );

    expect(operations["HeroName"].variables).toEqual([
      { name: "episode", type: "Episode" }
    ]);

    expect(operations["Search"].variables).toEqual([
      { name: "text", type: "String!" }
    ]);

    expect(operations["CreateReviewForEpisode"].variables).toEqual([
      { name: "episode", type: "Episode!" },
      { name: "review", type: "ReviewInput!" }
    ]);
  });

  it(`should keep track of enums and input object types used in variables`, () => {
    const document = parse(`
      query HeroName($episode: Episode) {
        hero(episode: $episode) {
          name
        }
      }

      query Search($text: String) {
        search(text: $text) {
          ... on Character {
            name
          }
        }
      }

      mutation CreateReviewForEpisode($episode: Episode!, $review: ReviewInput!) {
        createReview(episode: $episode, review: $review) {
          stars
          commentary
        }
      }
    `);

    const { typesUsed } = withStringifiedTypes(
      compileToLegacyIR(schema, document)
    );

    expect(typesUsed).toEqual(["Episode", "ReviewInput", "ColorInput"]);
  });

  it(`should keep track of enums used in fields`, () => {
    const document = parse(`
      query Hero {
        hero {
          name
          appearsIn
        }

        droid(id: "2001") {
          appearsIn
        }
      }
    `);

    const { typesUsed } = withStringifiedTypes(
      compileToLegacyIR(schema, document)
    );

    expect(typesUsed).toEqual(["Episode"]);
  });

  it(`should keep track of types used in fields of input objects`, () => {
    const document = parse(`
      mutation FieldArgumentsWithInputObjects($review: ReviewInput!) {
        createReview(episode: JEDI, review: $review) {
          commentary
        }
      }
      `);

    const { typesUsed } = withStringifiedTypes(
      compileToLegacyIR(schema, document)
    );

    expect(typesUsed).toContain("ReviewInput");
    expect(typesUsed).toContain("ColorInput");
  });

  it(`should include the original field name for an aliased field`, () => {
    const document = parse(`
      query HeroName {
        r2: hero {
          name
        }
        luke: hero(episode: EMPIRE) {
          name
        }
      }
    `);

    const { operations } = compileToLegacyIR(schema, document);

    expect(operations["HeroName"].fields[0].fieldName).toBe("hero");
  });

  it(`should include field arguments`, () => {
    const document = parse(`
      query HeroName {
        hero(episode: EMPIRE) {
          name
        }
      }
    `);

    const { operations } = compileToLegacyIR(schema, document);

    expect(operations["HeroName"].fields[0].args).toEqual([
      { name: "episode", value: "EMPIRE", type: schema.getType("Episode") }
    ]);
  });

  it(`should include isConditional if a field has skip or include directives with variables`, () => {
    const document = parse(`
      query HeroNameConditionalInclusion($includeName: Boolean!) {
        hero {
          name @include(if: $includeName)
        }
      }

      query HeroNameConditionalExclusion($skipName: Boolean!) {
        hero {
          name @skip(if: $skipName)
        }
      }
    `);

    const { operations } = compileToLegacyIR(schema, document);

    expect(
      operations["HeroNameConditionalInclusion"].fields[0].fields[0]
    ).toMatchObject({
      fieldName: "name",
      isConditional: true
    });

    expect(
      operations["HeroNameConditionalExclusion"].fields[0].fields[0]
    ).toMatchObject({
      fieldName: "name",
      isConditional: true
    });
  });

  it(`should not include isConditional if a field has skip or include directives with a boolean literal that always passes`, () => {
    const document = parse(`
      query HeroNameConditionalInclusion {
        hero {
          name @include(if: true)
        }
      }

      query HeroNameConditionalExclusion {
        hero {
          name @skip(if: false)
        }
      }
    `);

    const { operations } = compileToLegacyIR(schema, document);

    expect(
      operations["HeroNameConditionalInclusion"].fields[0].fields[0]
    ).toMatchObject({
      fieldName: "name",
      isConditional: false
    });

    expect(
      operations["HeroNameConditionalExclusion"].fields[0].fields[0]
    ).toMatchObject({
      fieldName: "name",
      isConditional: false
    });
  });

  it(`should not include field if it has skip or include directives with a boolean literal that always fails`, () => {
    const document = parse(`
      query HeroNameConditionalInclusion {
        hero {
          name @include(if: false)
        }
      }

      query HeroNameConditionalExclusion {
        hero {
          name @skip(if: true)
        }
      }
    `);

    const { operations } = compileToLegacyIR(schema, document);

    expect(
      operations["HeroNameConditionalInclusion"].fields[0].fields
    ).toHaveLength(0);
    expect(
      operations["HeroNameConditionalExclusion"].fields[0].fields
    ).toHaveLength(0);
  });

  it(`should include isConditional if a field in inside an inline fragment with skip or include directives with variables`, () => {
    const document = parse(`
      query HeroNameConditionalInclusion($includeName: Boolean!) {
        hero {
          ... @include(if: $includeName) {
            name
          }
        }
      }

      query HeroNameConditionalExclusion($skipName: Boolean!) {
        hero {
          ... @skip(if: $skipName) {
            name
          }
        }
      }
    `);

    const { operations } = compileToLegacyIR(schema, document);

    expect(
      operations["HeroNameConditionalInclusion"].fields[0].fields[0]
    ).toMatchObject({
      fieldName: "name",
      isConditional: true
    });

    expect(
      operations["HeroNameConditionalExclusion"].fields[0].fields[0]
    ).toMatchObject({
      fieldName: "name",
      isConditional: true
    });
  });

  it(`should include isConditional if a field in inside a fragment spread with skip or include directives with variables`, () => {
    const document = parse(`
      query HeroNameConditionalInclusion($includeName: Boolean!) {
        hero {
          ...HeroName @include(if: $includeName)
        }
      }

      query HeroNameConditionalExclusion($skipName: Boolean!) {
        hero {
          ...HeroName @skip(if: $skipName)
        }
      }

      fragment HeroName on Character {
        name
      }
    `);

    const { operations } = compileToLegacyIR(schema, document);

    expect(
      operations["HeroNameConditionalInclusion"].fields[0].fields[0]
    ).toMatchObject({
      fieldName: "name",
      isConditional: true
    });

    expect(
      operations["HeroNameConditionalExclusion"].fields[0].fields[0]
    ).toMatchObject({
      fieldName: "name",
      isConditional: true
    });

    expect(
      operations["HeroNameConditionalInclusion"].fragmentsReferenced
    ).toEqual(["HeroName"]);
    expect(
      operations["HeroNameConditionalInclusion"].fields[0].fragmentSpreads
    ).toEqual(["HeroName"]);

    expect(
      operations["HeroNameConditionalExclusion"].fragmentsReferenced
    ).toEqual(["HeroName"]);
    expect(
      operations["HeroNameConditionalExclusion"].fields[0].fragmentSpreads
    ).toEqual(["HeroName"]);
  });

  it(`should recursively flatten inline fragments with type conditions that match the parent type`, () => {
    const document = parse(`
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

    const { operations } = compileToLegacyIR(schema, document);

    expect(
      operations["Hero"].fields[0].fields.map(field => field.fieldName)
    ).toEqual(["id", "name", "appearsIn"]);
  });

  it(`should recursively include fragment spreads with type conditions that match the parent type`, () => {
    const document = parse(`
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

    const { operations, fragments } = compileToLegacyIR(schema, document);

    expect(
      operations["Hero"].fields[0].fields.map(field => field.fieldName)
    ).toEqual(["id", "name", "appearsIn"]);

    expect(
      fragments["HeroDetails"].fields.map(field => field.fieldName)
    ).toEqual(["name", "appearsIn", "id"]);

    expect(
      fragments["MoreHeroDetails"].fields.map(field => field.fieldName)
    ).toEqual(["appearsIn"]);

    expect(operations["Hero"].fragmentsReferenced).toEqual([
      "HeroDetails",
      "MoreHeroDetails"
    ]);
    expect(operations["Hero"].fields[0].fragmentSpreads).toEqual([
      "HeroDetails"
    ]);
    expect(fragments["HeroDetails"].fragmentSpreads).toEqual([
      "MoreHeroDetails"
    ]);
  });

  it(`should include fragment spreads from subselections`, () => {
    const document = parse(`
      query HeroAndFriends {
        hero {
          ...HeroDetails
          appearsIn
          id
          friends {
            id
            ...HeroDetails
          }
        }
      }

      fragment HeroDetails on Character {
      	name
        id
      }
    `);

    const { operations, fragments } = compileToLegacyIR(schema, document);

    expect(
      operations["HeroAndFriends"].fields[0].fields.map(
        field => field.fieldName
      )
    ).toEqual(["name", "id", "appearsIn", "friends"]);
    expect(
      operations["HeroAndFriends"].fields[0].fields[3].fields.map(
        field => field.fieldName
      )
    ).toEqual(["id", "name"]);

    expect(
      fragments["HeroDetails"].fields.map(field => field.fieldName)
    ).toEqual(["name", "id"]);

    expect(operations["HeroAndFriends"].fragmentsReferenced).toEqual([
      "HeroDetails"
    ]);
    expect(operations["HeroAndFriends"].fields[0].fragmentSpreads).toEqual([
      "HeroDetails"
    ]);
  });

  it(`should include type conditions with merged fields for inline fragments`, () => {
    const document = parse(`
      query Hero {
        hero {
          name
          ... on Droid {
            primaryFunction
          }
          ... on Human {
            height
          }
        }
      }
    `);

    const { operations } = compileToLegacyIR(schema, document);

    expect(
      operations["Hero"].fields[0].fields.map(field => field.fieldName)
    ).toEqual(["name"]);

    return;

    expect(
      operations["Hero"].fields[0].inlineFragments[
        "Droid"
      ].typeCondition.toString()
    ).toEqual("Droid");
    expect(
      operations["Hero"].fields[0].inlineFragments["Droid"].fields.map(
        field => field.fieldName
      )
    ).toEqual(["name", "primaryFunction"]);

    expect(
      operations["Hero"].fields[0].inlineFragments[
        "Human"
      ].typeCondition.toString()
    ).toEqual("Human");
    expect(
      operations["Hero"].fields[0].inlineFragments["Human"].fields.map(
        field => field.fieldName
      )
    ).toEqual(["name", "height"]);
  });

  it(`should include fragment spreads with type conditions`, () => {
    const document = parse(`
      query Hero {
        hero {
          name
          ...DroidDetails
          ...HumanDetails
        }
      }

      fragment DroidDetails on Droid {
        primaryFunction
      }

      fragment HumanDetails on Human {
        height
      }
    `);

    const { operations, fragments } = compileToLegacyIR(schema, document);

    expect(
      operations["Hero"].fields[0].fields.map(field => field.fieldName)
    ).toEqual(["name"]);

    expect(
      operations["Hero"].fields[0].inlineFragments[
        "Droid"
      ].typeCondition.toString()
    ).toEqual("Droid");
    expect(
      operations["Hero"].fields[0].inlineFragments["Droid"].fields.map(
        field => field.fieldName
      )
    ).toEqual(["name", "primaryFunction"]);

    expect(
      operations["Hero"].fields[0].inlineFragments[
        "Human"
      ].typeCondition.toString()
    ).toEqual("Human");
    expect(
      operations["Hero"].fields[0].inlineFragments["Human"].fields.map(
        field => field.fieldName
      )
    ).toEqual(["name", "height"]);

    expect(operations["Hero"].fragmentsReferenced).toEqual([
      "DroidDetails",
      "HumanDetails"
    ]);
    expect(operations["Hero"].fields[0].fragmentSpreads).toEqual([
      "DroidDetails",
      "HumanDetails"
    ]);
  });

  it(`should not include type conditions for fragment spreads with type conditions that match the parent type`, () => {
    const document = parse(`
      query Hero {
        hero {
          name
          ...HeroDetails
        }
      }

      fragment HeroDetails on Character {
        name
      }
    `);

    const { operations } = compileToLegacyIR(schema, document);

    expect(
      operations["Hero"].fields[0].fields.map(field => field.fieldName)
    ).toEqual(["name"]);
    expect(operations["Hero"].fields[0].inlineFragments).toEqual([]);
  });

  it(`should include type conditions for inline fragments in fragments`, () => {
    const document = parse(`
      query Hero {
        hero {
          ...HeroDetails
        }
      }

      fragment HeroDetails on Character {
        name
        ... on Droid {
          primaryFunction
        }
        ... on Human {
          height
        }
      }
    `);

    const { operations, fragments } = compileToLegacyIR(schema, document);

    expect(
      operations["Hero"].fields[0].fields.map(field => field.fieldName)
    ).toEqual(["name"]);

    expect(
      operations["Hero"].fields[0].inlineFragments[
        "Droid"
      ].typeCondition.toString()
    ).toEqual("Droid");
    expect(
      operations["Hero"].fields[0].inlineFragments["Droid"].fields.map(
        field => field.fieldName
      )
    ).toEqual(["name", "primaryFunction"]);

    expect(
      operations["Hero"].fields[0].inlineFragments[
        "Human"
      ].typeCondition.toString()
    ).toEqual("Human");
    expect(
      operations["Hero"].fields[0].inlineFragments["Human"].fields.map(
        field => field.fieldName
      )
    ).toEqual(["name", "height"]);

    expect(operations["Hero"].fragmentsReferenced).toEqual(["HeroDetails"]);
    expect(operations["Hero"].fields[0].fragmentSpreads).toEqual([
      "HeroDetails"
    ]);
  });

  it(`should inherit type condition when nesting an inline fragment in an inline fragment with a more specific type condition`, () => {
    const document = parse(`
      query HeroName {
        hero {
          ... on Droid {
            ... on Character {
              name
            }
          }
        }
      }
    `);

    const { operations } = compileToLegacyIR(schema, document);

    expect(
      operations["HeroName"].fields[0].fields.map(field => field.fieldName)
    ).toEqual([]);
    expect(
      operations["HeroName"].fields[0].inlineFragments[
        "Droid"
      ].typeCondition.toString()
    ).toEqual("Droid");
    expect(
      operations["HeroName"].fields[0].inlineFragments["Droid"].fields.map(
        field => field.fieldName
      )
    ).toEqual(["name"]);
  });

  it(`should not inherit type condition when nesting an inline fragment in an inline fragment with a less specific type condition`, () => {
    const document = parse(`
      query HeroName {
        hero {
          ... on Character {
            ... on Droid {
              name
            }
          }
        }
      }
    `);

    const { operations } = compileToLegacyIR(schema, document);

    expect(
      operations["HeroName"].fields[0].fields.map(field => field.fieldName)
    ).toEqual([]);
    expect(
      operations["HeroName"].fields[0].inlineFragments[
        "Droid"
      ].typeCondition.toString()
    ).toEqual("Droid");
    expect(
      operations["HeroName"].fields[0].inlineFragments["Droid"].fields.map(
        field => field.fieldName
      )
    ).toEqual(["name"]);
  });

  it(`should inherit type condition when nesting a fragment spread in an inline fragment with a more specific type condition`, () => {
    const document = parse(`
      query HeroName {
        hero {
          ... on Droid {
            ...CharacterName
          }
        }
      }

      fragment CharacterName on Character {
        name
      }
    `);

    const { operations } = compileToLegacyIR(schema, document);

    expect(
      operations["HeroName"].fields[0].fields.map(field => field.fieldName)
    ).toEqual([]);
    expect(
      operations["HeroName"].fields[0].inlineFragments[
        "Droid"
      ].typeCondition.toString()
    ).toEqual("Droid");
    expect(
      operations["HeroName"].fields[0].inlineFragments["Droid"].fields.map(
        field => field.fieldName
      )
    ).toEqual(["name"]);
    expect(
      operations["HeroName"].fields[0].inlineFragments["Droid"].fragmentSpreads
    ).toEqual(["CharacterName"]);

    expect(operations["HeroName"].fragmentsReferenced).toEqual([
      "CharacterName"
    ]);
    expect(operations["HeroName"].fields[0].fragmentSpreads).toEqual([]);
  });

  it(`should not inherit type condition when nesting a fragment spread in an inline fragment with a less specific type condition`, () => {
    const document = parse(`
      query HeroName {
        hero {
          ... on Character {
            ...DroidName
          }
        }
      }

      fragment DroidName on Droid {
        name
      }
    `);

    const { operations } = compileToLegacyIR(schema, document);

    expect(
      operations["HeroName"].fields[0].fields.map(field => field.fieldName)
    ).toEqual([]);
    expect(
      operations["HeroName"].fields[0].inlineFragments[
        "Droid"
      ].typeCondition.toString()
    ).toEqual("Droid");
    expect(
      operations["HeroName"].fields[0].inlineFragments["Droid"].fields.map(
        field => field.fieldName
      )
    ).toEqual(["name"]);
    expect(
      operations["HeroName"].fields[0].inlineFragments["Droid"].fragmentSpreads
    ).toEqual(["DroidName"]);
    expect(operations["HeroName"].fragmentsReferenced).toEqual(["DroidName"]);
    expect(operations["HeroName"].fields[0].fragmentSpreads).toEqual([
      "DroidName"
    ]);
  });

  it(`should ignore inline fragment when the type condition does not overlap with the currently effective type`, () => {
    const document = parse(`
      fragment CharacterDetails on Character {
        ... on Droid {
          primaryFunction
        }
        ... on Human {
          height
        }
      }

      query HumanAndDroid {
        human(id: "human") {
          ...CharacterDetails
        }
        droid(id: "droid") {
          ...CharacterDetails
        }
      }
    `);

    const { operations } = compileToLegacyIR(schema, document);

    expect(
      operations["HumanAndDroid"].fields.map(field => field.fieldName)
    ).toEqual(["human", "droid"]);
    expect(
      operations["HumanAndDroid"].fields[0].fields.map(field => field.fieldName)
    ).toEqual(["height"]);
    expect(operations["HumanAndDroid"].fields[0].inlineFragments).toEqual([]);
    expect(
      operations["HumanAndDroid"].fields[1].fields.map(field => field.fieldName)
    ).toEqual(["primaryFunction"]);
    expect(operations["HumanAndDroid"].fields[1].inlineFragments).toEqual([]);
  });

  it(`should ignore fragment spread when the type condition does not overlap with the currently effective type`, () => {
    const document = parse(`
      fragment DroidPrimaryFunction on Droid {
        primaryFunction
      }

      fragment HumanHeight on Human {
        height
      }

      fragment CharacterDetails on Character {
        ...DroidPrimaryFunction
        ...HumanHeight
      }

      query HumanAndDroid {
        human(id: "human") {
          ...CharacterDetails
        }
        droid(id: "droid") {
          ...CharacterDetails
        }
      }
    `);

    const { operations } = compileToLegacyIR(schema, document);

    expect(
      operations["HumanAndDroid"].fields.map(field => field.fieldName)
    ).toEqual(["human", "droid"]);
    expect(
      operations["HumanAndDroid"].fields[0].fields.map(field => field.fieldName)
    ).toEqual(["height"]);
    expect(operations["HumanAndDroid"].fields[0].inlineFragments).toEqual([]);
    expect(
      operations["HumanAndDroid"].fields[1].fields.map(field => field.fieldName)
    ).toEqual(["primaryFunction"]);
    expect(operations["HumanAndDroid"].fields[1].inlineFragments).toEqual([]);
  });

  it(`should include type conditions for inline fragments on a union type`, () => {
    const document = parse(`
      query Search {
        search(text: "an") {
          ... on Character {
            name
          }
          ... on Droid {
            primaryFunction
          }
          ... on Human {
            height
          }
        }
      }
    `);

    const { operations } = compileToLegacyIR(schema, document);

    expect(
      operations["Search"].fields[0].fields.map(field => field.fieldName)
    ).toEqual([]);

    expect(
      operations["Search"].fields[0].inlineFragments[
        "Droid"
      ].typeCondition.toString()
    ).toEqual("Droid");
    expect(
      operations["Search"].fields[0].inlineFragments["Droid"].fields.map(
        field => field.fieldName
      )
    ).toEqual(["name", "primaryFunction"]);

    expect(
      operations["Search"].fields[0].inlineFragments[
        "Human"
      ].typeCondition.toString()
    ).toEqual("Human");
    expect(
      operations["Search"].fields[0].inlineFragments["Human"].fields.map(
        field => field.fieldName
      )
    ).toEqual(["name", "height"]);
  });

  it(`should keep correct field ordering even if fragment is visited multiple times`, () => {
    const document = parse(`
      query Hero {
        hero {
          ...HeroName
          appearsIn
          ...HeroName
        }
      }

      fragment HeroName on Character {
        name
      }
    `);

    const { operations } = compileToLegacyIR(schema, document);

    expect(
      operations["Hero"].fields[0].fields.map(field => field.fieldName)
    ).toEqual(["name", "appearsIn"]);
  });

  it(`should keep correct field ordering even if field has been visited before for other type condition`, () => {
    const document = parse(`
      fragment HeroDetails on Character {
        ... on Human {
          appearsIn
        }

        ... on Droid {
          name
          appearsIn
        }
      }
    `);

    const { fragments } = compileToLegacyIR(schema, document);

    expect(
      fragments["HeroDetails"].inlineFragments["Droid"].typeCondition.toString()
    ).toEqual("Droid");
    expect(
      fragments["HeroDetails"].inlineFragments["Droid"].fields.map(
        field => field.fieldName
      )
    ).toEqual(["name", "appearsIn"]);
  });

  it(`should keep track of fragments referenced in a subselection`, () => {
    const document = parse(`
      query HeroAndFriends {
        hero {
          name
          friends {
            ...HeroDetails
          }
        }
      }

      fragment HeroDetails on Character {
        name
      }
    `);

    const { operations } = compileToLegacyIR(schema, document);

    expect(operations["HeroAndFriends"].fragmentsReferenced).toEqual([
      "HeroDetails"
    ]);
  });

  it(`should keep track of fragments referenced in a fragment within a subselection`, () => {
    const document = parse(`
      query HeroAndFriends {
        hero {
          ...HeroDetails
        }
      }

      fragment HeroDetails on Character {
        friends {
          ...HeroName
        }
      }

      fragment HeroName on Character {
        name
      }
    `);

    const { operations } = compileToLegacyIR(schema, document);

    expect(operations["HeroAndFriends"].fragmentsReferenced).toEqual([
      "HeroDetails",
      "HeroName"
    ]);
  });

  it(`should keep track of fragments referenced in a subselection nested in an inline fragment`, () => {
    const document = parse(`
      query HeroAndFriends {
        hero {
          name
          ... on Droid {
            friends {
              ...HeroDetails
            }
          }
        }
      }

      fragment HeroDetails on Character {
        name
      }
    `);

    const { operations } = compileToLegacyIR(schema, document);

    expect(operations["HeroAndFriends"].fragmentsReferenced).toEqual([
      "HeroDetails"
    ]);
  });

  describe("with mergeInFieldsFromFragmentSpreads set to false", () => {
    it(`should not morge fields from recursively included fragment spreads with type conditions that match the parent type`, () => {
      const document = parse(`
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

      const { operations, fragments } = compileToLegacyIR(schema, document, {
        mergeInFieldsFromFragmentSpreads: false
      });

      expect(
        operations["Hero"].fields[0].fields.map(field => field.fieldName)
      ).toEqual(["id"]);

      expect(
        fragments["HeroDetails"].fields.map(field => field.fieldName)
      ).toEqual(["name", "id"]);

      expect(
        fragments["MoreHeroDetails"].fields.map(field => field.fieldName)
      ).toEqual(["appearsIn"]);

      expect(operations["Hero"].fragmentsReferenced).toEqual([
        "HeroDetails",
        "MoreHeroDetails"
      ]);
      expect(operations["Hero"].fields[0].fragmentSpreads).toEqual([
        "HeroDetails"
      ]);
      expect(fragments["HeroDetails"].fragmentSpreads).toEqual([
        "MoreHeroDetails"
      ]);
    });

    it(`should not merge fields from fragment spreads from subselections`, () => {
      const document = parse(`
        query HeroAndFriends {
          hero {
            ...HeroDetails
            appearsIn
            id
            friends {
              id
              ...HeroDetails
            }
          }
        }

        fragment HeroDetails on Character {
          name
          id
        }
      `);

      const { operations, fragments } = compileToLegacyIR(schema, document, {
        mergeInFieldsFromFragmentSpreads: false
      });

      expect(
        operations["HeroAndFriends"].fields[0].fields.map(
          field => field.fieldName
        )
      ).toEqual(["appearsIn", "id", "friends"]);
      expect(
        operations["HeroAndFriends"].fields[0].fields[2].fields.map(
          field => field.fieldName
        )
      ).toEqual(["id"]);

      expect(
        fragments["HeroDetails"].fields.map(field => field.fieldName)
      ).toEqual(["name", "id"]);

      expect(operations["HeroAndFriends"].fragmentsReferenced).toEqual([
        "HeroDetails"
      ]);
      expect(operations["HeroAndFriends"].fields[0].fragmentSpreads).toEqual([
        "HeroDetails"
      ]);
    });

    it(`should not merge fields from fragment spreads with type conditions`, () => {
      const document = parse(`
        query Hero {
          hero {
            name
            ...DroidDetails
            ...HumanDetails
          }
        }

        fragment DroidDetails on Droid {
          primaryFunction
        }

        fragment HumanDetails on Human {
          height
        }
      `);

      const { operations, fragments } = compileToLegacyIR(schema, document, {
        mergeInFieldsFromFragmentSpreads: false
      });

      expect(
        operations["Hero"].fields[0].fields.map(field => field.fieldName)
      ).toEqual(["name"]);

      expect(operations["Hero"].fields[0].inlineFragment).toBeUndefined();

      expect(operations["Hero"].fragmentsReferenced).toEqual([
        "DroidDetails",
        "HumanDetails"
      ]);
      expect(operations["Hero"].fields[0].fragmentSpreads).toEqual([
        "DroidDetails",
        "HumanDetails"
      ]);
    });
  });

  it(`should include the source of operations`, () => {
    const source = stripIndent`
      query HeroName {
        hero {
          name
        }
      }
    `;
    const document = parse(source);

    const { operations } = compileToLegacyIR(schema, document);

    expect(operations["HeroName"].source).toBe(source);
  });

  it(`should include the source of fragments`, () => {
    const source = stripIndent`
      fragment HeroDetails on Character {
        name
      }
    `;
    const document = parse(source);

    const { fragments } = compileToLegacyIR(schema, document);

    expect(fragments["HeroDetails"].source).toBe(source);
  });

  it(`should include the source of operations with __typename added when addTypename is true`, () => {
    const source = stripIndent`
      query HeroName {
        hero {
          name
        }
      }
    `;
    const document = parse(source);

    const { operations } = compileToLegacyIR(schema, document, {
      addTypename: true
    });

    expect(operations["HeroName"].source).toBe(stripIndent`
      query HeroName {
        hero {
          __typename
          name
        }
      }
    `);
  });

  it(`should include the source of fragments with __typename added when addTypename is true`, () => {
    const source = stripIndent`
      fragment HeroDetails on Character {
        name
      }
    `;
    const document = parse(source);

    const { fragments } = compileToLegacyIR(schema, document, {
      addTypename: true
    });

    expect(fragments["HeroDetails"].source).toBe(stripIndent`
      fragment HeroDetails on Character {
        __typename
        name
      }
    `);
  });

  it(`should include the operationType for a query`, () => {
    const source = stripIndent`
      query HeroName {
        hero {
          name
        }
      }
    `;
    const document = parse(source);

    const { operations } = compileToLegacyIR(schema, document);

    expect(operations["HeroName"].operationType).toBe("query");
  });

  it(`should include the operationType for a mutation`, () => {
    const source = stripIndent`
      mutation CreateReview {
        createReview {
          stars
          commentary
        }
      }
    `;
    const document = parse(source);

    const { operations } = compileToLegacyIR(schema, document);

    expect(operations["CreateReview"].operationType).toBe("mutation");
  });
});
