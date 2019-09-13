import { stripIndent } from "common-tags";

import { SwiftGenerator, SwiftSource, swift } from "../language";
import { valueFromAST } from "graphql";

describe("Swift code generation: Basic language constructs", () => {
  let generator: SwiftGenerator<any>;

  beforeEach(() => {
    generator = new SwiftGenerator({});
  });

  it(`should generate a class declaration`, () => {
    generator.classDeclaration(
      { className: "Hero", modifiers: ["public", "final"] },
      () => {
        generator.propertyDeclaration({
          propertyName: "name",
          typeName: "String"
        });
        generator.propertyDeclaration({
          propertyName: "age",
          typeName: "Int"
        });
      }
    );

    expect(generator.output).toBe(stripIndent`
      public final class Hero {
        public var name: String
        public var age: Int
      }
    `);
  });

  it(`should generate a class declaration matching modifiers`, () => {
    generator.classDeclaration(
      { className: "Hero", modifiers: ["final"] },
      () => {
        generator.propertyDeclaration({
          propertyName: "name",
          typeName: "String"
        });
        generator.propertyDeclaration({
          propertyName: "age",
          typeName: "Int"
        });
      }
    );

    expect(generator.output).toBe(stripIndent`
      final class Hero {
        public var name: String
        public var age: Int
      }
    `);
  });

  it(`should generate a class declaration with proper escaping`, () => {
    generator.classDeclaration(
      { className: "Type", modifiers: ["public", "final"] },
      () => {
        generator.propertyDeclaration({
          propertyName: "name",
          typeName: "String"
        });
        generator.propertyDeclaration({
          propertyName: "age",
          typeName: "Int"
        });
        generator.propertyDeclaration({
          propertyName: "self",
          typeName: "Self"
        });
      }
    );

    expect(generator.output).toBe(stripIndent`
      public final class \`Type\` {
        public var name: String
        public var age: Int
        public var \`self\`: \`Self\`
      }
    `);
  });

  it(`should generate a struct declaration`, () => {
    generator.structDeclaration({ structName: "Hero" }, false, () => {
      generator.propertyDeclaration({
        propertyName: "name",
        typeName: "String"
      });
      generator.propertyDeclaration({
        propertyName: "age",
        typeName: "Int"
      });
    });

    expect(generator.output).toBe(stripIndent`
      public struct Hero {
        public var name: String
        public var age: Int
      }
    `);
  });

  it(`should generate a namespaced fragment`, () => {
    generator.structDeclaration(
      {
        structName: "Hero",
        adoptedProtocols: ["GraphQLFragment"],
        namespace: "StarWars"
      },
      false,
      () => {
        generator.propertyDeclaration({
          propertyName: "name",
          typeName: "String"
        });
        generator.propertyDeclaration({
          propertyName: "age",
          typeName: "Int"
        });
      }
    );

    expect(generator.output).toBe(stripIndent`
      public struct Hero: GraphQLFragment {
        public var name: String
        public var age: Int
      }
    `);
  });

  it(`should generate a namespaced fragment which is not public for individual files`, () => {
    generator.structDeclaration(
      {
        structName: "Hero",
        adoptedProtocols: ["GraphQLFragment"],
        namespace: "StarWars"
      },
      true,
      () => {
        generator.propertyDeclaration({
          propertyName: "name",
          typeName: "String"
        });
        generator.propertyDeclaration({
          propertyName: "age",
          typeName: "Int"
        });
      }
    );

    expect(generator.output).toBe(stripIndent`
      struct Hero: GraphQLFragment {
        public var name: String
        public var age: Int
      }
    `);
  });

  it(`should generate an escaped struct declaration`, () => {
    generator.structDeclaration({ structName: "Type" }, false, () => {
      generator.propertyDeclaration({
        propertyName: "name",
        typeName: "String"
      });
      generator.propertyDeclaration({
        propertyName: "yearOfBirth",
        typeName: "Int"
      });
      generator.propertyDeclaration({
        propertyName: "self",
        typeName: "Self"
      });
    });

    expect(generator.output).toBe(stripIndent`
      public struct \`Type\` {
        public var name: String
        public var yearOfBirth: Int
        public var \`self\`: \`Self\`
      }
    `);
  });

  it(`should generate nested struct declarations`, () => {
    generator.structDeclaration({ structName: "Hero" }, false, () => {
      generator.propertyDeclaration({
        propertyName: "name",
        typeName: "String"
      });
      generator.propertyDeclaration({
        propertyName: "friends",
        typeName: "[Friend]"
      });

      generator.structDeclaration({ structName: "Friend" }, false, () => {
        generator.propertyDeclaration({
          propertyName: "name",
          typeName: "String"
        });
      });
    });

    expect(generator.output).toBe(stripIndent`
      public struct Hero {
        public var name: String
        public var friends: [Friend]

        public struct Friend {
          public var name: String
        }
      }
    `);
  });

  it(`should generate a protocol declaration`, () => {
    generator.protocolDeclaration(
      { protocolName: "HeroDetails", adoptedProtocols: ["HasName"] },
      () => {
        generator.protocolPropertyDeclaration({
          propertyName: "name",
          typeName: "String"
        });
        generator.protocolPropertyDeclaration({
          propertyName: "age",
          typeName: "Int"
        });
        generator.protocolPropertyDeclaration({
          propertyName: "default",
          typeName: "Boolean"
        });
      }
    );

    expect(generator.output).toBe(stripIndent`
      public protocol HeroDetails: HasName {
        var name: String { get }
        var age: Int { get }
        var \`default\`: Boolean { get }
      }
    `);
  });

  it(`should handle multi-line descriptions`, () => {
    generator.structDeclaration(
      { structName: "Hero", description: "A hero" },
      false,
      () => {
        generator.propertyDeclaration({
          propertyName: "name",
          typeName: "String",
          description: `A multiline comment \n on the hero's name.`
        });
        generator.propertyDeclaration({
          propertyName: "age",
          typeName: "String",
          description: `A multiline comment \n on the hero's age.`
        });
      }
    );

    expect(generator.output).toMatchSnapshot();
  });
});

describe("Swift code generation: Escaping", () => {
  describe("using SwiftSource", () => {
    it(`should escape identifiers`, () => {
      expect(SwiftSource.identifier("self").source).toBe("`self`");
      expect(SwiftSource.identifier("public").source).toBe("`public`");
      expect(SwiftSource.identifier("Array<Type>").source).toBe(
        "Array<`Type`>"
      );
      expect(SwiftSource.identifier("[Self?]?").source).toBe("[`Self`?]?");
    });

    it(`should not escape other words`, () => {
      expect(SwiftSource.identifier("me").source).toBe("me");
      expect(SwiftSource.identifier("_Self").source).toBe("_Self");
      expect(SwiftSource.identifier("classes").source).toBe("classes");
    });

    it(`should escape fewer words in member position`, () => {
      expect(SwiftSource.identifier(".self").source).toBe(".`self`");
      expect(SwiftSource.identifier(".public").source).toBe(".public");
      expect(SwiftSource.identifier("Foo.Self.Type.self.class").source).toBe(
        "Foo.Self.`Type`.`self`.class"
      );
    });

    it(`should escape fewer words at offset 0 with member escaping`, () => {
      expect(SwiftSource.memberName("self").source).toBe("`self`");
      expect(SwiftSource.memberName("public").source).toBe("public");
      expect(SwiftSource.memberName(" public").source).toBe(" `public`");
      expect(SwiftSource.memberName("Foo.Self.Type.self.class").source).toBe(
        "Foo.Self.`Type`.`self`.class"
      );
    });

    it(`should escape strings`, () => {
      expect(SwiftSource.string("foobar").source).toBe('"foobar"');
      expect(SwiftSource.string("foo\n  bar  ").source).toBe('"foo\\n  bar  "');
      expect(SwiftSource.string("one'two\"three\\four\tfive").source).toBe(
        '"one\'two\\"three\\\\four\\tfive"'
      );
    });

    it(`should trim strings when asked`, () => {
      expect(SwiftSource.string("foobar", true).source).toBe('"foobar"');
      expect(SwiftSource.string("foo\n  bar  ", true).source).toBe('"foo bar"');
    });

    it(`should support concatenation`, () => {
      expect(swift`one`.concat().source).toBe("one");
      expect(swift`one`.concat(swift`two`).source).toBe("onetwo");
      expect(swift`one`.concat(swift`two`, swift`three`).source).toBe(
        "onetwothree"
      );
    });

    it(`should support appending`, () => {
      let value = swift`one`;
      value.append();
      expect(value.source).toBe("one");
      value.append(swift`foo`);
      expect(value.source).toBe("onefoo");
      value.append(swift`bar`, swift`baz`, swift`qux`);
      expect(value.source).toBe("onefoobarbazqux");
    });
  });
  describe("using SwiftGenerator", () => {
    let generator: SwiftGenerator<any>;

    beforeEach(() => {
      generator = new SwiftGenerator({});
    });

    it(`should trim with multilineString`, () => {
      generator.multilineString("foo\n  bar  ");

      expect(generator.output).toBe('"foo bar"');
    });

    it(`shouldn't trim with multilineString when using """`, () => {
      generator.multilineString('"""\nfoo\n  bar  \n"""');
      expect(generator.output).toBe('"\\"\\"\\"\\nfoo\\n  bar  \\n\\"\\"\\""');
    });
  });
  describe("using template strings", () => {
    it(`should escape interpolated strings but not string literals`, () => {
      expect(swift`self`.source).toBe("self");
      expect(swift`${"self"}`.source).toBe("`self`");
      expect(swift`class ${"Foo.Type.self"}: ${"Protocol?"}`.source).toBe(
        "class Foo.`Type`.`self`: `Protocol`?"
      );
      expect(swift`${["Self", "Foo.Self.self"]}`.source).toBe(
        "`Self`,Foo.Self.`self`"
      );
      expect(swift`${true} ${"true"}`.source).toBe("true `true`");
      expect(swift`${{ toString: () => "self" }}`.source).toBe("`self`");
    });

    it(`should not escape already-escaped interpolated strings`, () => {
      expect(swift`${swift`${"self"}`}`.source).toBe("`self`");
      expect(swift`${"public"} ${new SwiftSource("public")}`.source).toBe(
        "`public` public"
      );
    });

    it(`should not escape with the raw tag`, () => {
      expect(SwiftSource.raw`${"self"}`.source).toBe("self");
    });
  });
});
