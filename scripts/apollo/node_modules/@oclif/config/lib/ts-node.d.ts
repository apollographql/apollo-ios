export interface TSConfig {
    compilerOptions: {
        rootDir?: string;
        rootDirs?: string[];
        outDir?: string;
        target?: string;
        esModuleInterop?: boolean;
    };
}
/**
 * convert a path from the compiled ./lib files to the ./src typescript source
 * this is for developing typescript plugins/CLIs
 * if there is a tsconfig and the original sources exist, it attempts to require ts-
 */
export declare function tsPath(root: string, orig: string): string;
export declare function tsPath(root: string, orig: string | undefined): string | undefined;
