import * as t from "@babel/types";
import generate from "@babel/generator";

type Printable = t.Node | string;

export default class Printer {
  private printQueue: Printable[] = [];

  public print(): string {
    return (
      this.printQueue.reduce((document: string, printable) => {
        if (typeof printable === "string") {
          return document + printable;
        } else {
          const documentPart = generate(printable).code;
          return document + this.indentComments(documentPart);
        }
      }, "") + "\n"
    );
  }

  public enqueue(printable: Printable) {
    if (this.printQueue.length > 0) {
      this.printQueue.push("\n");
      this.printQueue.push("\n");
    }
    this.printQueue.push(printable);
  }

  public printAndClear() {
    const output = this.print();
    this.printQueue = [];
    return output;
  }

  private indentComments(documentPart: string) {
    const lines = documentPart.split("\n").filter(Boolean); // filter out lines that have no content

    let currentLine = 0;
    const newDocumentParts = [];
    // Keep track of what column comments should start on
    // to keep things aligned
    let maxCommentColumn = 0;

    while (currentLine !== lines.length) {
      const currentLineContents = lines[currentLine];
      const commentColumn = currentLineContents.indexOf("//");
      if (commentColumn > 0) {
        if (maxCommentColumn < commentColumn) {
          maxCommentColumn = commentColumn;
        }

        const [contents, comment] = currentLineContents.split("//");
        newDocumentParts.push({
          main: contents.replace(/\s+$/g, ""),
          comment: comment ? comment.trim() : null
        });
      } else {
        newDocumentParts.push({
          main: currentLineContents,
          comment: null
        });
      }

      currentLine++;
    }

    return newDocumentParts
      .reduce((memo: string[], part) => {
        const { main, comment } = part;

        let line;
        if (comment !== null) {
          const spacesBetween = maxCommentColumn - main.length;
          line = `${main}${" ".repeat(spacesBetween)} // ${comment.trim()}`;
        } else {
          line = main;
        }

        return [...memo, line];
      }, [])
      .join("\n");
  }
}
