export declare const deps: {
    readonly stripAnsi: (string: string) => string;
    readonly ansiStyles: typeof import("ansi-styles");
    readonly ansiEscapes: any;
    readonly passwordPrompt: any;
    readonly screen: typeof import("@oclif/screen");
    readonly open: typeof import("./open").default;
    readonly prompt: typeof import("./prompt");
    readonly styledObject: typeof import("./styled/object").default;
    readonly styledHeader: typeof import("./styled/header").default;
    readonly styledJSON: typeof import("./styled/json").default;
    readonly table: typeof import("./styled/table").table;
    readonly tree: typeof import("./styled/tree").default;
    readonly wait: (ms?: number) => Promise<unknown>;
};
export default deps;
