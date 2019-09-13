export interface PJSON {
    [k: string]: any;
    dependencies?: {
        [name: string]: string;
    };
    oclif: {
        schema?: number;
    };
}
export declare namespace PJSON {
    interface Plugin extends PJSON {
        name: string;
        version: string;
        oclif: PJSON['oclif'] & {
            schema?: number;
            title?: string;
            description?: string;
            hooks?: {
                [name: string]: (string | string[]);
            };
            commands?: string;
            plugins?: string[];
            devPlugins?: string[];
            aliases?: {
                [name: string]: string | null;
            };
            repositoryPrefix?: string;
            update: {
                s3: S3;
                autoupdate?: {
                    rollout?: number;
                    debounce?: number;
                };
                node: {
                    version?: string;
                    targets?: string[];
                };
            };
            topics?: {
                [k: string]: {
                    description?: string;
                    subtopics?: Plugin['oclif']['topics'];
                    hidden?: boolean;
                };
            };
        };
    }
    interface S3 {
        acl?: string;
        bucket?: string;
        host?: string;
        xz?: boolean;
        gz?: boolean;
        templates: {
            target: S3.Templates;
            vanilla: S3.Templates;
        };
    }
    namespace S3 {
        interface Templates {
            baseDir: string;
            versioned: string;
            unversioned: string;
            manifest: string;
        }
    }
    interface CLI extends Plugin {
        oclif: Plugin['oclif'] & {
            schema?: number;
            bin?: string;
            npmRegistry?: string;
            scope?: string;
            dirname?: string;
        };
    }
    interface User extends PJSON {
        private?: boolean;
        oclif: PJSON['oclif'] & {
            plugins?: (string | PluginTypes.User | PluginTypes.Link)[];
        };
    }
    type PluginTypes = PluginTypes.User | PluginTypes.Link | {
        root: string;
    };
    namespace PluginTypes {
        interface User {
            type: 'user';
            name: string;
            url?: string;
            tag?: string;
        }
        interface Link {
            type: 'link';
            name: string;
            root: string;
        }
    }
}
