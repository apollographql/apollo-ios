import { generateOperationId } from "../generateOperationId";
import { stripIndent } from "common-tags";

import { compile } from "./test-utils/helpers";

describe(`generateOperationId()`, () => {
  it(`should generate different operation IDs for different operations`, () => {
    const context1 = compile(`
      query Hero {
        hero {
          ...HeroDetails
        }
      }
      fragment HeroDetails on Character {
        name
      }
    `);

    const { operationId: id1 } = generateOperationId(
      context1.operations["Hero"],
      context1.fragments
    );

    const context2 = compile(`
      query Hero {
        hero {
          ...HeroDetails
        }
      }
      fragment HeroDetails on Character {
        appearsIn
      }
    `);

    const { operationId: id2 } = generateOperationId(
      context2.operations["Hero"],
      context2.fragments
    );

    expect(id1).not.toBe(id2);
  });

  it(`should generate the same operation ID regardless of operation formatting/commenting`, () => {
    const context1 = compile(`
      query HeroName($episode: Episode) {
        hero(episode: $episode) {
          name
        }
      }
    `);

    const { operationId: id1 } = generateOperationId(
      context1.operations["HeroName"],
      context1.fragments
    );

    const context2 = compile(`
      # Profound comment
      query HeroName($episode:Episode) { hero(episode: $episode) { name } }
      # Deeply meaningful comment
    `);

    const { operationId: id2 } = generateOperationId(
      context2.operations["HeroName"],
      context2.fragments
    );

    expect(id1).toBe(id2);
  });

  it(`should generate the same operation ID regardless of fragment order`, () => {
    const context1 = compile(`
      query Hero {
        hero {
          ...HeroName
          ...HeroAppearsIn
        }
      }
      fragment HeroName on Character {
        name
      }
      fragment HeroAppearsIn on Character {
        appearsIn
      }
    `);

    const { operationId: id1 } = generateOperationId(
      context1.operations["Hero"],
      context1.fragments
    );

    const context2 = compile(`
      query Hero {
        hero {
          ...HeroName
          ...HeroAppearsIn
        }
      }
      fragment HeroAppearsIn on Character {
        appearsIn
      }
      fragment HeroName on Character {
        name
      }
    `);

    const { operationId: id2 } = generateOperationId(
      context2.operations["Hero"],
      context2.fragments
    );

    expect(id1).toBe(id2);
  });

  it(`should generate appropriate operation ID mapping source when there are nested fragment references`, () => {
    const context = compile(`
      query Hero {
        hero {
          ...HeroDetails
        }
      }
      fragment HeroName on Character {
        name
      }
      fragment HeroDetails on Character {
        ...HeroName
        appearsIn
      }
    `);

    const { sourceWithFragments } = generateOperationId(
      context.operations["Hero"],
      context.fragments
    );

    expect(sourceWithFragments).toBe(stripIndent`
      query Hero {
        hero {
          ...HeroDetails
        }
      }
      fragment HeroDetails on Character {
        ...HeroName
        appearsIn
      }
      fragment HeroName on Character {
        name
      }
    `);
  });
});
