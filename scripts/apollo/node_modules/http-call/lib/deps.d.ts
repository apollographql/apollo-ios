/// <reference types="node" />
import contentType = require('content-type');
import http = require('http');
import https = require('https');
import proxy = require('./proxy');
export declare const deps: {
    readonly proxy: typeof proxy.default;
    readonly isStream: {
        (stream: unknown): stream is import("stream").Stream;
        writable(stream: unknown): stream is import("stream").Writable;
        readable(stream: unknown): stream is import("stream").Readable;
        duplex(stream: unknown): stream is import("stream").Duplex;
        transform(input: unknown): input is import("stream").Transform;
    };
    readonly contentType: typeof contentType;
    readonly http: typeof http;
    readonly https: typeof https;
};
