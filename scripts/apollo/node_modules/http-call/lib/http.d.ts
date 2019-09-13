/// <reference types="node" />
import http = require('http');
export declare type Protocol = 'https:' | 'http:';
/**
 * @typedef {Object} HTTPRequestOptions
 * @property {Object.<string, string>} headers - request headers
 * @property {string} method - request method (GET/POST/etc)
 * @property {(string)} body - request body. Sets content-type to application/json and stringifies when object
 * @property {(boolean)} partial - do not make continuous requests while receiving a Next-Range header for GET requests
 * @property {(number)} port - port to use
 */
export declare type FullHTTPRequestOptions = http.ClientRequestArgs & {
    raw?: boolean;
    body?: any;
    partial?: boolean;
    headers: http.OutgoingHttpHeaders;
};
export declare type HTTPRequestOptions = Partial<FullHTTPRequestOptions>;
/**
 * Utility for simple HTTP calls
 * @class
 */
export declare class HTTP<T> {
    static defaults: HTTPRequestOptions;
    static create(options?: HTTPRequestOptions): typeof HTTP;
    /**
     * make an http GET request
     * @param {string} url - url or path to call
     * @param {HTTPRequestOptions} options
     * @returns {Promise}
     * @example
     * ```js
     * const http = require('http-call')
     * await http.get('https://google.com')
     * ```
     */
    static get<T>(url: string, options?: HTTPRequestOptions): Promise<HTTP<T>>;
    /**
     * make an http POST request
     * @param {string} url - url or path to call
     * @param {HTTPRequestOptions} options
     * @returns {Promise}
     * @example
     * ```js
     * const http = require('http-call')
     * await http.post('https://google.com')
     * ```
     */
    static post<T>(url: string, options?: HTTPRequestOptions): Promise<HTTP<T>>;
    /**
     * make an http PUT request
     * @param {string} url - url or path to call
     * @param {HTTPRequestOptions} options
     * @returns {Promise}
     * @example
     * ```js
     * const http = require('http-call')
     * await http.put('https://google.com')
     * ```
     */
    static put<T>(url: string, options?: HTTPRequestOptions): Promise<HTTP<T>>;
    /**
     * make an http PATCH request
     * @param {string} url - url or path to call
     * @param {HTTPRequestOptions} options
     * @returns {Promise}
     * @example
     * ```js
     * const http = require('http-call')
     * await http.patch('https://google.com')
     * ```
     */
    static patch<T>(url: string, options?: HTTPRequestOptions): Promise<HTTP<T>>;
    /**
     * make an http DELETE request
     * @param {string} url - url or path to call
     * @param {HTTPRequestOptions} options
     * @returns {Promise}
     * @example
     * ```js
     * const http = require('http-call')
     * await http.delete('https://google.com')
     * ```
     */
    static delete<T>(url: string, options?: HTTPRequestOptions): Promise<HTTP<T>>;
    /**
     * make a streaming request
     * @param {string} url - url or path to call
     * @param {HTTPRequestOptions} options
     * @returns {Promise}
     * @example
     * ```js
     * const http = require('http-call')
     * let {response} = await http.get('https://google.com')
     * response.on('data', console.log)
     * ```
     */
    static stream(url: string, options?: HTTPRequestOptions): Promise<HTTP<unknown>>;
    static request<T>(url: string, options?: HTTPRequestOptions): Promise<HTTP<T>>;
    response: http.IncomingMessage;
    request: http.ClientRequest;
    body: T;
    options: FullHTTPRequestOptions;
    private _redirectRetries;
    private _errorRetries;
    readonly method: string;
    readonly statusCode: number;
    readonly secure: boolean;
    url: string;
    readonly headers: http.IncomingMessage['headers'];
    readonly partial: boolean;
    readonly ctor: typeof HTTP;
    constructor(url: string, options?: HTTPRequestOptions);
    _request(): Promise<void>;
    _redirect(): Promise<void>;
    _maybeRetry(err: Error): Promise<void>;
    private readonly _chalk;
    private _renderStatus;
    private _debugRequest;
    private _debugResponse;
    private _renderHeaders;
    private _performRequest;
    private _parse;
    private _parseBody;
    private _getNextRange;
    private readonly _responseOK;
    private readonly _responseRedirect;
    private readonly _shouldParseResponseBody;
    private _wait;
}
export default HTTP;
export declare class HTTPError extends Error {
    statusCode: number;
    http: HTTP<any>;
    body: any;
    __httpcall: any;
    constructor(http: HTTP<any>);
}
