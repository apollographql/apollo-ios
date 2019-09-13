import CodeGenerator from "apollo-codegen-core/lib/utilities/CodeGenerator";
import { LegacyCompilerContext } from "apollo-codegen-core/lib/compiler/legacyIR";

export interface Property {
  propertyName: string;
  typeName: string;
  traitName?: string;
  isOptional?: boolean;
  isList?: boolean;
  description?: string;
}

export function comment(
  generator: CodeGenerator<LegacyCompilerContext, any>,
  comment: string
) {
  const split = comment ? comment.split("\n") : [];
  if (split.length > 0) {
    generator.printOnNewline("/**");
    split.forEach(line => {
      generator.printOnNewline(` * ${line.trim()}`);
    });

    generator.printOnNewline(" */");
  }
}

export function packageDeclaration(
  generator: CodeGenerator<LegacyCompilerContext, any>,
  pkg: string
) {
  generator.printNewlineIfNeeded();
  generator.printOnNewline(`package ${pkg}`);
}

export function objectDeclaration(
  generator: CodeGenerator<LegacyCompilerContext, any>,
  {
    objectName,
    superclass
  }: {
    objectName: string;
    superclass?: string;
  },
  closure?: () => void
) {
  generator.printNewlineIfNeeded();
  generator.printOnNewline(
    `object ${objectName}` + (superclass ? ` extends ${superclass}` : "")
  );
  generator.pushScope({ typeName: objectName });
  if (closure) {
    generator.withinBlock(closure);
  }
  generator.popScope();
}

export function traitDeclaration(
  generator: CodeGenerator<LegacyCompilerContext, any>,
  {
    traitName,
    annotations,
    superclasses,
    description
  }: {
    traitName: string;
    annotations?: string[];
    superclasses?: string[];
    description?: string;
  },
  closure?: () => void
) {
  generator.printNewlineIfNeeded();

  if (description) {
    comment(generator, description);
  }

  generator.printOnNewline(
    `${(annotations || []).map(a => "@" + a).join(" ")} trait ${traitName}` +
      (superclasses ? ` extends ${superclasses.join(" with ")}` : "")
  );
  generator.pushScope({ typeName: traitName });
  if (closure) {
    generator.withinBlock(closure);
  }
  generator.popScope();
}

export function methodDeclaration(
  generator: CodeGenerator<LegacyCompilerContext, any>,
  {
    methodName,
    description,
    params
  }: {
    methodName: string;
    description?: string;
    params?: {
      name: string;
      type: string;
      defaultValue?: string;
    }[];
  },
  closure?: () => void
) {
  generator.printNewlineIfNeeded();

  if (description) {
    comment(generator, description);
  }

  const paramsSection = (params || [])
    .map(v => {
      return (
        v.name + ": " + v.type + (v.defaultValue ? ` = ${v.defaultValue}` : "")
      );
    })
    .join(", ");

  generator.printOnNewline(
    `def ${methodName}(${paramsSection})` + (closure ? " =" : "")
  );

  if (closure) {
    generator.withinBlock(closure);
  }
}

export function propertyDeclaration(
  generator: CodeGenerator<LegacyCompilerContext, any>,
  {
    jsName,
    propertyName,
    typeName,
    description
  }: {
    jsName?: string;
    propertyName: string;
    typeName: string;
    description?: string;
  },
  closure?: () => void
) {
  if (description) {
    comment(generator, description);
  }

  generator.printOnNewline(
    (jsName ? `@scala.scalajs.js.annotation.JSName("${jsName}") ` : "") +
      `val ${propertyName}: ${typeName}` +
      (closure ? ` =` : "")
  );

  if (closure) {
    generator.withinBlock(closure);
  }
}

export function propertyDeclarations(
  generator: CodeGenerator<LegacyCompilerContext, any>,
  declarations: {
    propertyName: string;
    typeName: string;
    description: string;
  }[]
) {
  declarations.forEach(o => {
    propertyDeclaration(generator, o);
  });
}

const reservedKeywords = new Set([
  "case",
  "catch",
  "class",
  "def",
  "do",
  "else",
  "extends",
  "false",
  "final",
  "for",
  "if",
  "match",
  "new",
  "null",
  "throw",
  "trait",
  "true",
  "try",
  "type",
  "until",
  "val",
  "var",
  "while",
  "with"
]);

export function escapeIdentifierIfNeeded(identifier: string) {
  if (reservedKeywords.has(identifier)) {
    return "`" + identifier + "`";
  } else {
    return identifier;
  }
}
