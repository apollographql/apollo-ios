import { stripIndent } from "common-tags";

import CodeGenerator from "apollo-codegen-core/lib/utilities/CodeGenerator";

import { objectDeclaration, propertyDeclaration } from "../language";

describe("Scala code generation: Basic language constructs", function() {
  let generator;

  beforeEach(function() {
    generator = new CodeGenerator();
  });

  test(`should generate a object declaration`, function() {
    objectDeclaration(generator, { objectName: "Hero" }, () => {
      propertyDeclaration(
        generator,
        { propertyName: "name", typeName: "String" },
        () => {}
      );
      propertyDeclaration(
        generator,
        { propertyName: "age", typeName: "Int" },
        () => {}
      );
    });

    expect(generator.output).toBe(stripIndent`
      object Hero {
        val name: String = {
        }
        val age: Int = {
        }
      }
    `);
  });
});
