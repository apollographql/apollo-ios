import { parse } from "graphql";

import { loadSchema } from "apollo-codegen-core/lib/loading";
const schema = loadSchema(
  require.resolve("../../../../__fixtures__/starwars/schema.json")
);

import { compileToIR, CompilerContext } from "apollo-codegen-core/lib/compiler";

import { generateSource } from "../codeGeneration";
import { FlowCompilerOptions } from "../language";

function compile(
  source: string,
  options: FlowCompilerOptions = {
    mergeInFieldsFromFragmentSpreads: true,
    useFlowExactObjects: false,
    useReadOnlyTypes: false,
    addTypename: true
  }
): CompilerContext {
  const document = parse(source);
  return compileToIR(schema, document, options);
}

describe("Flow codeGeneration", () => {
  test("multiple files", () => {
    const context = compile(`
      query HeroName($episode: Episode) {
        hero(episode: $episode) {
          name
          id
        }
      }

      query SomeOther($episode: Episode) {
        hero(episode: $episode) {
          name
          ...someFragment
        }
      }

      fragment someFragment on Character {
        appearsIn
      }

      mutation ReviewMovie($episode: Episode, $review: ReviewInput) {
        createReview(episode: $episode, review: $review) {
          stars
          commentary
        }
      }
    `);
    context.operations["HeroName"].filePath = "/some/file/ComponentA.js";
    context.operations["SomeOther"].filePath = "/some/file/ComponentB.js";
    context.fragments["someFragment"].filePath = "/some/file/ComponentB.js";
    const output = generateSource(context);
    expect(output).toBeInstanceOf(Object);
    Object.keys(output).forEach(filePath => {
      expect(filePath).toMatchSnapshot();
      expect(output[filePath]).toMatchSnapshot();
    });
  });

  test("simple hero query", () => {
    const context = compile(`
      query HeroName($episode: Episode) {
        hero(episode: $episode) {
          name
          id
        }
      }
    `);

    const output = generateSource(context);
    expect(output).toMatchSnapshot();
  });

  test("simple mutation", () => {
    const context = compile(`
      mutation ReviewMovie($episode: Episode, $review: ReviewInput) {
        createReview(episode: $episode, review: $review) {
          stars
          commentary
        }
      }
    `);

    const output = generateSource(context);
    expect(output).toMatchSnapshot();
  });

  test("simple fragment", () => {
    const context = compile(`
      fragment SimpleFragment on Character{
        name
      }
    `);

    const output = generateSource(context);
    expect(output).toMatchSnapshot();
  });

  test("fragment with fragment spreads", () => {
    const context = compile(`
      fragment simpleFragment on Character {
        name
      }

      fragment anotherFragment on Character {
        id
        ...simpleFragment
      }
    `);

    const output = generateSource(context);
    expect(output).toMatchSnapshot();
  });

  test("fragment with fragment spreads with inline fragment", () => {
    const context = compile(`
      fragment simpleFragment on Character {
        name
      }

      fragment anotherFragment on Character {
        id
        ...simpleFragment

        ... on Human {
          appearsIn
        }
      }
    `);

    const output = generateSource(context);
    expect(output).toMatchSnapshot();
  });

  test("query with fragment spreads", () => {
    const context = compile(`
      fragment simpleFragment on Character {
        name
      }

      query HeroFragment($episode: Episode) {
        hero(episode: $episode) {
          ...simpleFragment
          id
        }
      }
    `);

    const output = generateSource(context);
    expect(output).toMatchSnapshot();
  });

  test("inline fragment", () => {
    const context = compile(`
      query HeroInlineFragment($episode: Episode) {
        hero(episode: $episode) {
          ... on Character {
            name
          }
          id
        }
      }
    `);

    const output = generateSource(context);
    expect(output).toMatchSnapshot();
  });

  test("inline fragment on type conditions", () => {
    const context = compile(`
      query HeroName($episode: Episode) {
        hero(episode: $episode) {
          name
          id

          ... on Human {
            homePlanet
            friends {
              name
            }
          }

          ... on Droid {
            appearsIn
          }
        }
      }
    `);
    const output = generateSource(context);
    expect(output).toMatchSnapshot();
  });

  test("inline fragment on type conditions with differing inner fields", () => {
    const context = compile(`
      query HeroName($episode: Episode) {
        hero(episode: $episode) {
          name
          id

          ... on Human {
            homePlanet
            friends {
              name
            }
          }

          ... on Droid {
            appearsIn
            friends {
              id
            }
          }
        }
      }
    `);

    const output = generateSource(context);
    expect(output).toMatchSnapshot();
  });

  test("fragment spreads with inline fragments", () => {
    const context = compile(`
      query HeroName($episode: Episode) {
        hero(episode: $episode) {
          name
          id
          ...humanFragment
          ...droidFragment
        }
      }

      fragment humanFragment on Human {
        homePlanet
        friends {
          ... on Human {
            name
          }

          ... on Droid {
            id
          }
        }
      }

      fragment droidFragment on Droid {
        appearsIn
      }
    `);
    const output = generateSource(context);
    expect(output).toMatchSnapshot();
  });

  test("covariant properties with $ReadOnlyArray", () => {
    const context = compile(
      `
      query HeroName($episode: Episode) {
        hero(episode: $episode) {
          name
          id
          ...humanFragment
          ...droidFragment
        }
      }

      fragment humanFragment on Human {
        homePlanet
        friends {
          ... on Human {
            name
          }

          ... on Droid {
            id
          }
        }
      }

      fragment droidFragment on Droid {
        appearsIn
      }
    `,
      {
        mergeInFieldsFromFragmentSpreads: true,
        useReadOnlyTypes: true,
        useFlowExactObjects: true,
        addTypename: true
      }
    );
    const output = generateSource(context);
    expect(output).toMatchSnapshot();
  });

  test("handles multiline graphql comments", () => {
    const miscSchema = loadSchema(
      require.resolve("../../../../__fixtures__/misc/schema.json")
    );

    const document = parse(`
      query CustomScalar {
        commentTest {
          multiLine
        }
      }
    `);

    const output = generateSource(
      compileToIR(miscSchema, document, {
        mergeInFieldsFromFragmentSpreads: true,
        addTypename: true
      })
    );

    expect(output).toMatchSnapshot();
  });
});
