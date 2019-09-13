"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const proxy_1 = require("./proxy");
beforeEach(() => {
    proxy_1.default.env = {};
});
test('returns nothing', () => {
    expect(proxy_1.default.agent(true)).toBeUndefined();
});
describe('with proxies', () => {
    beforeEach(() => {
        proxy_1.default.env.HTTP_PROXY = 'http://user:pass@foo.com';
        proxy_1.default.env.HTTPS_PROXY = 'https://user:pass@bar.com';
    });
    test('has http properties', () => {
        expect(proxy_1.default.agent(false)).toMatchObject({
            options: {
                proxy: {
                    host: 'foo.com',
                    port: '8080',
                    proxyAuth: 'user:pass',
                },
            },
            proxyOptions: {
                host: 'foo.com',
                port: '8080',
                proxyAuth: 'user:pass',
            },
        });
    });
    test('has https properties', () => {
        expect(proxy_1.default.agent(true)).toMatchObject({
            defaultPort: 443,
            options: {
                proxy: {
                    host: 'bar.com',
                    port: '8080',
                    proxyAuth: 'user:pass',
                },
            },
            proxyOptions: {
                host: 'bar.com',
                port: '8080',
                proxyAuth: 'user:pass',
            },
        });
    });
});
describe('with http proxy only', () => {
    beforeEach(() => {
        proxy_1.default.env.HTTP_PROXY = 'http://user:pass@foo.com';
    });
    test('has agent', () => {
        expect(proxy_1.default.agent(true)).toMatchObject({
            defaultPort: 443,
            options: {
                proxy: {
                    host: 'foo.com',
                    port: '8080',
                    proxyAuth: 'user:pass',
                },
            },
            proxyOptions: {
                host: 'foo.com',
                port: '8080',
                proxyAuth: 'user:pass',
            },
        });
    });
});
