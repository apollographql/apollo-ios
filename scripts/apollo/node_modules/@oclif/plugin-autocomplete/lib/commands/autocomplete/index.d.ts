import { AutocompleteBase } from '../../base';
export default class Index extends AutocompleteBase {
    static description: string;
    static args: {
        name: string;
        description: string;
        required: boolean;
    }[];
    static flags: {
        'refresh-cache': import("../../../node_modules/@oclif/parser/lib/flags").IBooleanFlag<boolean>;
    };
    static examples: string[];
    run(): Promise<void>;
}
