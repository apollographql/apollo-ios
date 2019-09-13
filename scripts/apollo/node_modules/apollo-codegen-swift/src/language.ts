import CodeGenerator from "apollo-codegen-core/lib/utilities/CodeGenerator";

import {
  join as _join,
  wrap as _wrap
} from "apollo-codegen-core/lib/utilities/printing";

export interface Class {
  className: string;
  modifiers: string[];
  superClass?: string;
  adoptedProtocols?: string[];
}

export interface Struct {
  structName: string;
  adoptedProtocols?: string[];
  description?: string;
  namespace?: string;
}

export interface Protocol {
  protocolName: string;
  adoptedProtocols?: string[];
}

export interface Property {
  propertyName: string;
  typeName: string;
  isOptional?: boolean;
  description?: string;
}

/**
 * Swift identifiers that are keywords
 *
 * Some of these are context-dependent and can be used as identifiers outside of the relevant
 * context. As we don't understand context, we will treat them as keywords in all contexts.
 *
 * This list does not include keywords that aren't identifiers, such as `#available`.
 */
// prettier-ignore
const reservedKeywords = new Set([
  // https://docs.swift.org/swift-book/ReferenceManual/LexicalStructure.html#ID413
  // Keywords used in declarations
  'associatedtype', 'class', 'deinit', 'enum', 'extension', 'fileprivate',
  'func', 'import', 'init', 'inout', 'internal', 'let', 'open', 'operator',
  'private', 'protocol', 'public', 'static', 'struct', 'subscript',
  'typealias', 'var',
  // Keywords used in statements
  'break', 'case', 'continue', 'default', 'defer', 'do', 'else', 'fallthrough',
  'for', 'guard', 'if', 'in', 'repeat', 'return', 'switch', 'where', 'while',
  // Keywords used in expressions and types
  'as', 'Any', 'catch', 'false', 'is', 'nil', 'rethrows', 'super', 'self',
  'Self', 'throw', 'throws', 'true', 'try',
  // Keywords used in patterns
  '_',
  // Keywords reserved in particular contexts
  'associativity', 'convenience', 'dynamic', 'didSet', 'final', 'get', 'infix',
  'indirect', 'lazy', 'left', 'mutating', 'none', 'nonmutating', 'optional',
  'override', 'postfix', 'precedence', 'prefix', 'Protocol', 'required',
  'right', 'set', 'Type', 'unowned', 'weak', 'willSet'
]);
/**
 * Swift identifiers that are keywords in member position
 *
 * This is the subset of keywords that are known to still be keywords in member position. The
 * documentation is not explicit about which keywords qualify, but these are the ones that are
 * known to have meaning in member position.
 *
 * We use this to avoid unnecessary escaping with expressions like `.public`.
 */
const reservedMemberKeywords = new Set(["self", "Type", "Protocol"]);

/**
 * A class that represents Swift source.
 *
 * Instances of this type will not undergo escaping when used with the `swift` template tag.
 */
export class SwiftSource {
  source: string;
  constructor(source: string) {
    this.source = source;
  }

  /**
   * Returns the input wrapped in quotes and escaped appropriately.
   * @param string The input string, to be represented as a Swift string.
   * @param trim If true, trim the string of whitespace and join into a single line.
   * @returns A `SwiftSource` containing the Swift string literal.
   */
  static string(string: string, trim: boolean = false): SwiftSource {
    if (trim) {
      string = string
        .split(/\n/g)
        .map(line => line.trim())
        .join(" ");
    }
    return new SwiftSource(
      // String literal grammar:
      // https://docs.swift.org/swift-book/ReferenceManual/LexicalStructure.html#ID417
      // Technically we only need to escape ", \, newline, and carriage return, but as Swift
      // defines escapes for NUL and horizontal tab, it produces nicer output to escape those as
      // well.
      `"${string.replace(/[\0\\\t\n\r"]/g, c => {
        switch (c) {
          case "\0":
            return "\\0";
          case "\t":
            return "\\t";
          case "\n":
            return "\\n";
          case "\r":
            return "\\r";
          default:
            return `\\${c}`;
        }
      })}"`
    );
  }

  /**
   * Escapes the input if it contains a reserved keyword.
   *
   * For example, the input `Self?` requires escaping or it will match the keyword `Self`.
   *
   * @param identifier The input containing identifiers to escape.
   * @returns The input with all identifiers escaped.
   */
  static identifier(input: string): SwiftSource {
    // Swift identifiers use a significantly more complicated definition, but GraphQL names are
    // limited to ASCII, so we only have to worry about ASCII strings here.
    return new SwiftSource(
      input.replace(/[a-zA-Z_][a-zA-Z0-9_]*/g, (match, offset, fullString) => {
        if (reservedKeywords.has(match)) {
          // If this keyword comes after a '.' make sure it's also a reservedMemberKeyword.
          if (
            offset == 0 ||
            fullString[offset - 1] !== "." ||
            reservedMemberKeywords.has(match)
          ) {
            return `\`${match}\``;
          }
        }
        return match;
      })
    );
  }

  /**
   * Escapes the input if it begins with a reserved keyword not valid in member position.
   *
   * Most keywords are valid in member position (e.g. after a period), but a few aren't. This
   * method escapes just those keywords not valid in member position, and therefore must only be
   * used on input that is guaranteed to come after a dot.
   * @param input The input containing identifiers to escape.
   * @returns The input with relevant identifiers escaped.
   */
  static memberName(input: string): SwiftSource {
    return new SwiftSource(
      // This behaves nearly identically to `SwiftSource.identifier` except for the logic around
      // offset zero, but it's structured a bit differently to optimize for the fact that most
      // matched identifiers are at offset zero.
      input.replace(/[a-zA-Z_][a-zA-Z0-9_]*/g, (match, offset, fullString) => {
        if (!reservedMemberKeywords.has(match)) {
          // If we're not at offset 0 and not after a period, check the full set.
          if (
            offset == 0 ||
            fullString[offset - 1] === "." ||
            !reservedKeywords.has(match)
          ) {
            return match;
          }
        }
        return `\`${match}\``;
      })
    );
  }

  /**
   * Template tag for producing a `SwiftSource` value without performing escaping.
   *
   * This is identical to evaluating the template without the tag and passing the result to `new
   * SwiftSource(…)`.
   */
  static raw(
    literals: TemplateStringsArray,
    ...placeholders: any[]
  ): SwiftSource {
    // We can't just evaluate the original template directly, but we can replicate its semantics.
    // NB: The semantics of untagged template literals matches String.prototype.concat rather than
    // the + operator. Since String.prototype.concat is documented as slower than the + operator,
    // we'll just use individual template strings to do the concatenation.
    var result = literals[0];
    placeholders.forEach((value, i) => {
      result += `${value}${literals[i + 1]}`;
    });
    return new SwiftSource(result);
  }

  toString(): string {
    return this.source;
  }

  /**
   * Concatenates multiple `SwiftSource`s together.
   */
  concat(...sources: SwiftSource[]): SwiftSource {
    // Documentation says + is faster than String.concat, so let's use that
    return new SwiftSource(
      sources.reduce((accum, value) => accum + value.source, this.source)
    );
  }

  /**
   * Appends one or more `SwiftSource`s to the end of a `SwiftSource`.
   * @param sources The `SwiftSource`s to append to the end.
   */
  append(...sources: SwiftSource[]) {
    for (let value of sources) {
      this.source += value.source;
    }
  }

  /**
   * If maybeSource is not null or empty, then wrap with start and end, otherwise return an empty
   * string.
   *
   * This is just a wrapper for `wrap()` from apollo-codegen-core/lib/utilities/printing.
   */
  static wrap(
    start: SwiftSource,
    maybeSource?: SwiftSource,
    end?: SwiftSource
  ): SwiftSource {
    return new SwiftSource(
      _wrap(
        start.source,
        maybeSource !== undefined ? maybeSource.source : undefined,
        end !== undefined ? end.source : undefined
      )
    );
  }

  /**
   * Given maybeArray, return an empty string if it is null or empty, otherwise return all items
   * together separated by separator if provided.
   *
   * This is just a wrapper for `join()` from apollo-codegen-core/lib/utilities/printing.
   *
   * @param separator The separator to put between elements. This is typed as `string` with the
   * expectation that it's generally something like `', '` but if it contains identifiers it should
   * be escaped.
   */
  static join(
    maybeArray?: (SwiftSource | undefined)[],
    separator?: string
  ): SwiftSource {
    return new SwiftSource(_join(maybeArray, separator));
  }
}

/**
 * Template tag for producing a `SwiftSource` value by escaping expressions.
 *
 * All interpolated expressions will undergo identifier escaping unless the expression value is of
 * type `SwiftSource`. If any interpolated expressions are actually intended as string literals, use
 * the `SwiftSource.string()` function on the expression.
 */
export function swift(
  literals: TemplateStringsArray,
  ...placeholders: any[]
): SwiftSource {
  let result = literals[0];
  placeholders.forEach((value, i) => {
    result += _escape(value);
    result += literals[i + 1];
  });
  return new SwiftSource(result);
}

function _escape(value: any): string {
  if (value instanceof SwiftSource) {
    return value.source;
  } else if (typeof value === "string") {
    return SwiftSource.identifier(value).source;
  } else if (Array.isArray(value)) {
    // I don't know why you'd be interpolating an array, but let's recurse into it.
    return value.map(_escape).join();
  } else if (typeof value === "object") {
    // use `${…}` instead of toString to preserve string conversion semantics from untagged
    // template literals.
    return SwiftSource.identifier(`${value}`).source;
  } else if (value === undefined) {
    return "";
  } else {
    // Other primitives don't need to be escaped.
    return `${value}`;
  }
}

// Convenience accessors for wrap/join
const { wrap, join } = SwiftSource;

export class SwiftGenerator<Context> extends CodeGenerator<
  Context,
  { typeName: string },
  SwiftSource
> {
  constructor(context: Context) {
    super(context);
  }

  multilineString(string: string) {
    // Disable trimming if the string contains """ as this means we're probably printing an
    // operation definition where trimming is destructive.
    this.printOnNewline(
      SwiftSource.string(string, /* trim */ !string.includes('"""'))
    );
  }

  comment(comment?: string) {
    comment &&
      comment.split("\n").forEach(line => {
        this.printOnNewline(SwiftSource.raw`/// ${line.trim()}`);
      });
  }

  commentWithoutTrimming(comment?: string) {
    comment &&
      comment.split("\n").forEach(line => {
        this.printOnNewline(SwiftSource.raw`/// ${line}`);
      });
  }

  deprecationAttributes(
    isDeprecated: boolean | undefined,
    deprecationReason: string | undefined
  ) {
    if (isDeprecated !== undefined && isDeprecated) {
      deprecationReason =
        deprecationReason !== undefined && deprecationReason.length > 0
          ? deprecationReason
          : "";
      this.printOnNewline(
        swift`@available(*, deprecated, message: ${SwiftSource.string(
          deprecationReason,
          /* trim */ true
        )})`
      );
    }
  }

  namespaceDeclaration(namespace: string | undefined, closure: Function) {
    if (namespace) {
      this.printNewlineIfNeeded();
      this.printOnNewline(SwiftSource.raw`/// ${namespace} namespace`);
      this.printOnNewline(swift`public enum ${namespace}`);
      this.pushScope({ typeName: namespace });
      this.withinBlock(closure);
      this.popScope();
    } else {
      if (closure) {
        closure();
      }
    }
  }

  namespaceExtensionDeclaration(
    namespace: string | undefined,
    closure: Function
  ) {
    if (namespace) {
      this.printNewlineIfNeeded();
      this.printOnNewline(SwiftSource.raw`/// ${namespace} namespace`);
      this.printOnNewline(swift`public extension ${namespace}`);
      this.pushScope({ typeName: namespace });
      this.withinBlock(closure);
      this.popScope();
    } else {
      if (closure) {
        closure();
      }
    }
  }

  classDeclaration(
    { className, modifiers, superClass, adoptedProtocols = [] }: Class,
    closure: Function
  ) {
    this.printNewlineIfNeeded();
    this.printOnNewline(
      wrap(swift``, new SwiftSource(_join(modifiers, " ")), swift` `).concat(
        swift`class ${className}`
      )
    );
    this.print(
      wrap(
        swift`: `,
        join(
          [
            superClass !== undefined
              ? SwiftSource.identifier(superClass)
              : undefined,
            ...adoptedProtocols.map(SwiftSource.identifier)
          ],
          ", "
        )
      )
    );
    this.pushScope({ typeName: className });
    this.withinBlock(closure);
    this.popScope();
  }

  /**
   * Generates the declaration for a struct
   *
   * @param param0 The struct name, description, adoptedProtocols, and namespace to use to generate the struct
   * @param outputIndividualFiles If this operation is being output as individual files, to help prevent
   *                              redundant usages of the `public` modifier in enum extensions.
   * @param closure The closure to execute which generates the body of the struct.
   */
  structDeclaration(
    {
      structName,
      description,
      adoptedProtocols = [],
      namespace = undefined
    }: Struct,
    outputIndividualFiles: boolean,
    closure: Function
  ) {
    this.printNewlineIfNeeded();
    this.comment(description);

    const isRedundant =
      adoptedProtocols.includes("GraphQLFragment") &&
      !!namespace &&
      outputIndividualFiles;
    const modifier = new SwiftSource(isRedundant ? "" : "public ");

    this.printOnNewline(swift`${modifier}struct ${structName}`);
    this.print(
      wrap(swift`: `, join(adoptedProtocols.map(SwiftSource.identifier), ", "))
    );
    this.pushScope({ typeName: structName });
    this.withinBlock(closure);
    this.popScope();
  }

  propertyDeclaration({ propertyName, typeName, description }: Property) {
    this.comment(description);
    this.printOnNewline(swift`public var ${propertyName}: ${typeName}`);
  }

  propertyDeclarations(properties: Property[]) {
    if (!properties) return;
    properties.forEach(property => this.propertyDeclaration(property));
  }

  protocolDeclaration(
    { protocolName, adoptedProtocols }: Protocol,
    closure: Function
  ) {
    this.printNewlineIfNeeded();
    this.printOnNewline(swift`public protocol ${protocolName}`);
    this.print(
      wrap(
        swift`: `,
        join(
          adoptedProtocols !== undefined
            ? adoptedProtocols.map(SwiftSource.identifier)
            : undefined,
          ", "
        )
      )
    );
    this.pushScope({ typeName: protocolName });
    this.withinBlock(closure);
    this.popScope();
  }

  protocolPropertyDeclaration({ propertyName, typeName }: Property) {
    this.printOnNewline(swift`var ${propertyName}: ${typeName} { get }`);
  }

  protocolPropertyDeclarations(properties: Property[]) {
    if (!properties) return;
    properties.forEach(property => this.protocolPropertyDeclaration(property));
  }
}
