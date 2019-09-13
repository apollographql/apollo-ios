import { collectAndMergeFields } from '../src/compiler/visitors/collectAndMergeFields';

import { SelectionSet } from '../src/compiler';

declare global {
  namespace jest {
    interface Matchers<R> {
      toMatchSelectionSet(possibleTypeNames: string[], expectedResponseKeys: string[]): R;
      toContainSelectionSetMatching(possibleTypeNames: string[], expectedResponseKeys: string[]): R;
    }
    interface MatcherUtils {
      equals(a: any, b: any): boolean;
    }
  }
}

function toMatchSelectionSet(
  this: jest.MatcherUtils,
  received: SelectionSet,
  possibleTypeNames: string[],
  expectedResponseKeys: string[]
): { message(): string; pass: boolean } {
  const actualResponseKeys = collectAndMergeFields(received).map(field => field.responseKey);

  const pass = this.equals(actualResponseKeys, expectedResponseKeys);

  if (pass) {
    return {
      message: () =>
        `Expected selection set for ${this.utils.printExpected(possibleTypeNames)}\n` +
        `To not match:\n` +
        `   ${this.utils.printExpected(expectedResponseKeys)}` +
        'Received:\n' +
        `  ${this.utils.printReceived(actualResponseKeys)}`,
      pass: true
    };
  } else {
    return {
      message: () =>
        `Expected selection set for ${this.utils.printExpected(possibleTypeNames)}\n` +
        `To match:\n` +
        `   ${this.utils.printExpected(expectedResponseKeys)}\n` +
        'Received:\n' +
        `   ${this.utils.printReceived(actualResponseKeys)}`,
      pass: false
    };
  }
}

function toContainSelectionSetMatching(
  this: jest.MatcherUtils,
  received: SelectionSet[],
  possibleTypeNames: string[],
  expectedResponseKeys: string[]
): { message(): string; pass: boolean } {
  const variant = received.find(variant => {
    return this.equals(Array.from(variant.possibleTypes).map(type => type.name), possibleTypeNames);
  });

  if (!variant) {
    return {
      message: () =>
        `Expected array to contain variant for:\n` +
        `  ${this.utils.printExpected(possibleTypeNames)}\n` +
        `But only found variants for:\n` +
        received
          .map(
            variant =>
              `  ${this.utils.printReceived(variant.possibleTypes)} -> ${this.utils.printReceived(
                collectAndMergeFields(variant).map(field => field.name)
              )}`
          )
          .join('\n'),
      pass: false
    };
  }

  return toMatchSelectionSet.call(this, variant, possibleTypeNames, expectedResponseKeys);
}

expect.extend({
  toMatchSelectionSet,
  toContainSelectionSetMatching
} as any);
