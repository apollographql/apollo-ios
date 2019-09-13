import { print, SelectionNode, isSelectionNode } from "graphql";
import { Plugin, Config, Refs, Printer } from "pretty-format";

export = (({
  test(value: any) {
    return (
      Array.isArray(value) && value.length > 0 && value.every(isSelectionNode)
    );
  },

  serialize(
    value: SelectionNode[],
    config: Config,
    indentation: string,
    depth: number,
    refs: Refs,
    printer: Printer
  ): string {
    return String(print(value)).replace(",", "\n");
  }
} as Plugin) as unknown) as jest.SnapshotSerializerPlugin;
