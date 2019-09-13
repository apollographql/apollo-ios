import { AutocompleteBase } from '../../base';
export default class Script extends AutocompleteBase {
    static description: string;
    static hidden: boolean;
    static args: {
        name: string;
        description: string;
        required: boolean;
    }[];
    run(): Promise<void>;
    private readonly prefix;
}
