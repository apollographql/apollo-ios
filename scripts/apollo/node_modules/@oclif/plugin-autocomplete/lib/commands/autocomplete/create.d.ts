import { AutocompleteBase } from '../../base';
export default class Create extends AutocompleteBase {
    static hidden: boolean;
    static description: string;
    private _commands?;
    run(): Promise<void>;
    private ensureDirs;
    private createFiles;
    private readonly bashSetupScriptPath;
    private readonly zshSetupScriptPath;
    private readonly bashFunctionsDir;
    private readonly zshFunctionsDir;
    private readonly bashCompletionFunctionPath;
    private readonly zshCompletionFunctionPath;
    private readonly bashSetupScript;
    private readonly zshSetupScript;
    private readonly commands;
    private genZshFlagSpecs;
    private readonly genAllCommandsMetaString;
    private readonly genCaseStatementForFlagsMetaString;
    private genCmdPublicFlags;
    private readonly bashCommandsWithFlagsList;
    private readonly bashCompletionFunction;
    private readonly zshCompletionFunction;
}
