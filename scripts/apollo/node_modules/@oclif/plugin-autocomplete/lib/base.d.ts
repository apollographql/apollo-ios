import Command from '@oclif/command';
export declare abstract class AutocompleteBase extends Command {
    readonly cliBin: string;
    readonly cliBinEnvVar: string;
    errorIfWindows(): void;
    errorIfNotSupportedShell(shell: string): void;
    readonly autocompleteCacheDir: string;
    readonly acLogfilePath: string;
    writeLogFile(msg: string): void;
}
