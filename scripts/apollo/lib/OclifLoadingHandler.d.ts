import { Command } from "@oclif/command";
import { LoadingHandler } from "apollo-language-server";
export declare class OclifLoadingHandler implements LoadingHandler {
    private command;
    constructor(command: Command);
    handle<T>(message: string, value: Promise<T>): Promise<T>;
    handleSync<T>(message: string, value: () => T): T;
    showError(message: string): void;
}
//# sourceMappingURL=OclifLoadingHandler.d.ts.map