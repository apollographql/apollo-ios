export interface BasicGeneratedFile {
  output: string;
}

export class GeneratedFile<Scope = any> implements BasicGeneratedFile {
  scopeStack: Scope[] = [];
  indentWidth = 2;
  indentLevel = 0;
  startOfIndentLevel = false;

  public output = "";

  pushScope(scope: Scope) {
    this.scopeStack.push(scope);
  }

  popScope() {
    return this.scopeStack.pop();
  }

  get scope(): Scope {
    if (this.scopeStack.length < 1) throw new Error("No active scope");

    return this.scopeStack[this.scopeStack.length - 1];
  }

  print(string?: string) {
    if (string) {
      this.output += string;
    }
  }

  printNewline() {
    if (this.output) {
      this.print("\n");
      this.startOfIndentLevel = false;
    }
  }

  printNewlineIfNeeded() {
    if (!this.startOfIndentLevel) {
      this.printNewline();
    }
  }

  printOnNewline(string?: string) {
    if (string) {
      this.printNewline();
      this.printIndent();
      this.print(string);
    }
  }

  printIndent() {
    const indentation = " ".repeat(this.indentLevel * this.indentWidth);
    this.output += indentation;
  }

  withIndent(closure: Function) {
    if (!closure) return;

    this.indentLevel++;
    this.startOfIndentLevel = true;
    closure();
    this.indentLevel--;
  }

  withinBlock(closure: Function, open = " {", close = "}") {
    this.print(open);
    this.withIndent(closure);
    this.printOnNewline(close);
  }
}

export default class CodeGenerator<
  Context = any,
  Scope = any,
  SourceType extends { toString(): string } = string
> {
  generatedFiles: { [fileName: string]: GeneratedFile<Scope> } = {};
  currentFile: GeneratedFile<Scope>;

  constructor(public context: Context) {
    this.currentFile = new GeneratedFile();
  }

  withinFile(fileName: string, closure: Function) {
    let file = this.generatedFiles[fileName];
    if (!file) {
      file = new GeneratedFile();
      this.generatedFiles[fileName] = file;
    }
    const oldCurrentFile = this.currentFile;
    this.currentFile = file;
    closure();
    this.currentFile = oldCurrentFile;
  }

  get output(): string {
    return this.currentFile.output;
  }

  pushScope(scope: Scope) {
    this.currentFile.pushScope(scope);
  }

  popScope() {
    this.currentFile.popScope();
  }

  get scope(): Scope {
    return this.currentFile.scope;
  }

  print(source?: SourceType) {
    this.currentFile.print(source !== undefined ? source.toString() : source);
  }

  printNewline() {
    this.currentFile.printNewline();
  }

  printNewlineIfNeeded() {
    this.currentFile.printNewlineIfNeeded();
  }

  printOnNewline(source?: SourceType) {
    this.currentFile.printOnNewline(
      source !== undefined ? source.toString() : source
    );
  }

  printIndent() {
    this.currentFile.printIndent();
  }

  withIndent(closure: Function) {
    this.currentFile.withIndent(closure);
  }

  withinBlock(closure: Function, open = " {", close = "}") {
    this.currentFile.withinBlock(closure, open, close);
  }
}
