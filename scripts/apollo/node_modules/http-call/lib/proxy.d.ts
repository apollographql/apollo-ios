/// <reference types="node" />
export default class ProxyUtil {
    static env: NodeJS.ProcessEnv;
    static readonly httpProxy: string | undefined;
    static readonly httpsProxy: string | undefined;
    static readonly usingProxy: boolean;
    static readonly sslCertDir: Array<string>;
    static readonly sslCertFile: Array<string>;
    static readonly certs: Array<Buffer>;
    static agent(https: boolean): any;
}
