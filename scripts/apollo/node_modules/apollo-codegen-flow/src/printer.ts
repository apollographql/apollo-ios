import * as t from "@babel/types";
import generate from "@babel/generator";

import { stripIndent } from "common-tags";

type Printable = t.Node | string;

export default class Printer {
  private printQueue: Printable[] = [];

  public print(): string {
    return (this.printQueue.reduce((document: string, printable) => {
      if (typeof printable === "string") {
        return document + printable;
      } else {
        const documentPart = generate(printable).code;
        return document + this.fixCommas(documentPart);
      }
    }, "") as string).trim();
  }

  public enqueue(printable: Printable) {
    this.printQueue = [...this.printQueue, "\n", "\n", printable];
  }

  public printAndClear() {
    const output = this.print();
    this.printQueue = [];
    return output;
  }

  /**
   * When using trailing commas on ObjectTypeProperties within
   * ObjectTypeAnnotations, we get weird behavior:
   * ```
   * {
   *   homePlanet: ?string // description
   *   ,
   *   friends: any  // description
   * }
   * ```
   * when we want
   * ```
   * {
   *   homePlanet: ?string, // description
   *   friends: any         // description
   * }
   * ```
   */
  private fixCommas(documentPart: string) {
    const lines = documentPart.split("\n").filter(Boolean); // filter out lines that have no content

    let currentLine = 0;
    let nextLine;
    const newDocumentParts = [];
    // Keep track of what column comments should start on
    // to keep things aligned
    let maxCommentColumn = 0;

    while (currentLine !== lines.length) {
      nextLine = currentLine + 1;
      const strippedNextLine = stripIndent`${lines[nextLine]}`;
      if (strippedNextLine.length === 1 && strippedNextLine[0] === ",") {
        const currentLineContents = lines[currentLine];
        const commentColumn = currentLineContents.indexOf("//");
        if (maxCommentColumn < commentColumn) {
          maxCommentColumn = commentColumn;
        }

        const [contents, comment] = currentLineContents.split("//");
        newDocumentParts.push({
          main: contents.replace(/\s+$/g, "") + ",",
          comment: comment ? comment.trim() : null
        });
        currentLine++;
      } else {
        newDocumentParts.push({
          main: lines[currentLine],
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
          line = `${main}${" ".repeat(spacesBetween)} // ${comment}`;
        } else {
          line = main;
        }

        return [...memo, line];
      }, [])
      .join("\n");
  }
}
