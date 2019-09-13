export declare namespace open {
    type Options = {
        app?: string | string[];
    };
}
export default function open(target: string, opts?: open.Options): Promise<{}>;
