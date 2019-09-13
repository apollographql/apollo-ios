"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const nock = require("nock");
const querystring = require("querystring");
const http_1 = require("./http");
nock.disableNetConnect();
let api;
beforeEach(() => {
    api = nock('https://api.jdxcode.com');
});
afterEach(() => {
    api.done();
});
afterEach(() => {
    nock.cleanAll();
});
describe('HTTP.get()', () => {
    test('makes a GET request', async () => {
        api.get('/').reply(200, { message: 'ok' });
        let { body } = await http_1.HTTP.get('https://api.jdxcode.com');
        expect(body).toEqual({ message: 'ok' });
    });
    test('makes a GET request', async () => {
        api.get('/').reply(200, { message: 'ok' }, {
            'content-type': 'application/json; charset=UTF-8',
        });
        let { body } = await http_1.HTTP.get('https://api.jdxcode.com');
        expect(body).toEqual({ message: 'ok' });
    });
    test('gets headers', async () => {
        api.get('/').reply(200, { message: 'ok' }, { myheader: 'ok' });
        let { body, headers } = await http_1.HTTP.get('https://api.jdxcode.com');
        expect(body).toEqual({ message: 'ok' });
        expect(headers).toMatchObject({ myheader: 'ok' });
    });
    test('can build a new HTTP with defaults', async () => {
        const MyHTTP = http_1.HTTP.create({ host: 'api.jdxcode.com' });
        api.get('/').reply(200, { message: 'ok' });
        let { body } = await MyHTTP.get('/');
        expect(body).toEqual({ message: 'ok' });
    });
    test('makes a request to a port', async () => {
        api = nock('https://api.jdxcode.com:3000');
        api.get('/').reply(200, { message: 'ok' });
        let { body } = await http_1.HTTP.get('https://api.jdxcode.com:3000');
        expect(body).toEqual({ message: 'ok' });
    });
    test('allows specifying the port', async () => {
        api = nock('https://api.jdxcode.com:3000');
        api.get('/').reply(200, { message: 'ok' });
        let { body } = await http_1.HTTP.get('https://api.jdxcode.com', { port: 3000 });
        expect(body).toEqual({ message: 'ok' });
    });
    test('makes a http GET request', async () => {
        api = nock('http://api.jdxcode.com');
        api.get('/').reply(200, { message: 'ok' });
        let { body } = await http_1.HTTP.get('http://api.jdxcode.com');
        expect(body).toEqual({ message: 'ok' });
    });
    test('can set default user agent', async () => {
        http_1.HTTP.defaults.headers = { 'user-agent': 'mynewuseragent' };
        api
            .matchHeader('user-agent', `mynewuseragent`)
            .get('/')
            .reply(200, { message: 'ok' });
        let { body } = await http_1.HTTP.get('https://api.jdxcode.com/');
        expect(body).toEqual({ message: 'ok' });
        delete http_1.HTTP.defaults.headers['user-agent'];
    });
    test('can set user agent as a global', async () => {
        global['http-call'] = { userAgent: 'mynewuseragent' };
        api
            .matchHeader('user-agent', `mynewuseragent`)
            .get('/')
            .reply(200, { message: 'ok' });
        let { body } = await http_1.HTTP.get('https://api.jdxcode.com/');
        expect(body).toEqual({ message: 'ok' });
        delete global['http-call'];
    });
    test('sets user-agent header', async () => {
        api
            .matchHeader('user-agent', `http-call/${require('../package.json').version} node-${process.version}`)
            .get('/')
            .reply(200, { message: 'ok' });
        await http_1.HTTP.get('https://api.jdxcode.com');
    });
    test('sets custom headers', async () => {
        api
            .matchHeader('foo', 'bar')
            .get('/')
            .reply(200);
        let headers = { foo: 'bar' };
        await http_1.HTTP.get('https://api.jdxcode.com', { headers });
    });
    test('does not fail on undefined header', async () => {
        api.get('/').reply(200);
        let headers = { foo: undefined };
        await http_1.HTTP.get('https://api.jdxcode.com', { headers });
    });
    describe('wait mocked out', () => {
        let wait = http_1.HTTP.prototype._wait;
        beforeAll(() => {
            http_1.HTTP.prototype._wait = jest.fn();
        });
        afterAll(() => {
            http_1.HTTP.prototype._wait = wait;
        });
        test('retries then succeeds', async () => {
            api.get('/').replyWithError({ message: 'timed out 1', code: 'ETIMEDOUT' });
            api.get('/').replyWithError({ message: 'timed out 2', code: 'ETIMEDOUT' });
            api.get('/').replyWithError({ message: 'timed out 3', code: 'ETIMEDOUT' });
            api.get('/').replyWithError({ message: 'timed out 4', code: 'ETIMEDOUT' });
            api.get('/').reply(200, { message: 'foo' });
            let { body } = await http_1.HTTP.get('https://api.jdxcode.com');
            expect(body).toEqual({ message: 'foo' });
        });
        test('retries 5 times on ETIMEDOUT', async () => {
            expect.assertions(1);
            api.get('/').replyWithError({ message: 'timed out 1', code: 'ETIMEDOUT' });
            api.get('/').replyWithError({ message: 'timed out 2', code: 'ETIMEDOUT' });
            api.get('/').replyWithError({ message: 'timed out 3', code: 'ETIMEDOUT' });
            api.get('/').replyWithError({ message: 'timed out 4', code: 'ETIMEDOUT' });
            api.get('/').replyWithError({ message: 'timed out 5', code: 'ETIMEDOUT' });
            api.get('/').replyWithError({ message: 'timed out 6', code: 'ETIMEDOUT' });
            try {
                await http_1.HTTP.get('https://api.jdxcode.com');
            }
            catch (err) {
                expect(err.message).toEqual('timed out 6');
            }
        });
    });
    test('retries on ENOTFOUND', async () => {
        api.get('/').replyWithError({ message: 'not found', code: 'ENOTFOUND' });
        api.get('/').reply(200, { message: 'foo' });
        let { body } = await http_1.HTTP.get('https://api.jdxcode.com');
        expect(body).toMatchObject({ message: 'foo' });
    });
    test('errors on EFOOBAR', async () => {
        expect.assertions(1);
        api.get('/').replyWithError({ message: 'oom', code: 'OUT_OF_MEM' });
        try {
            await http_1.HTTP.get('https://api.jdxcode.com');
        }
        catch (err) {
            expect(err.message).toEqual('oom');
        }
    });
    test('displays 404 error', async () => {
        expect.assertions(2);
        api.get('/').reply(404, 'oops! not found');
        try {
            await http_1.HTTP.get('https://api.jdxcode.com');
        }
        catch (err) {
            expect(err.statusCode).toEqual(404);
            expect(err.message).toEqual(`HTTP Error 404 for GET https://api.jdxcode.com:443/
oops! not found`);
        }
    });
    test('displays error message', async () => {
        expect.assertions(3);
        api.get('/').reply(404, { message: 'uh oh', otherinfo: [1, 2, 3] });
        try {
            await http_1.HTTP.get('https://api.jdxcode.com');
        }
        catch (err) {
            expect(err.statusCode).toEqual(404);
            expect(err.message).toEqual(`HTTP Error 404 for GET https://api.jdxcode.com:443/
uh oh`);
            expect(err.body).toMatchObject({ otherinfo: [1, 2, 3] });
        }
    });
    test('displays object error', async () => {
        expect.assertions(3);
        api.get('/').reply(404, { otherinfo: [1, 2, 3] });
        try {
            await http_1.HTTP.get('https://api.jdxcode.com');
        }
        catch (err) {
            expect(err.statusCode).toEqual(404);
            expect(err.message).toEqual(`HTTP Error 404 for GET https://api.jdxcode.com:443/
{ otherinfo: [ 1, 2, 3 ] }`);
            expect(err.body).toMatchObject({ otherinfo: [1, 2, 3] });
        }
    });
    test('follows redirect', async () => {
        api.get('/foo1').reply(302, null, { Location: 'https://api.jdxcode.com/foo2' });
        api.get('/foo2').reply(302, null, { Location: 'https://api.jdxcode.com/foo3' });
        api.get('/foo3').reply(200, { success: true });
        await http_1.HTTP.get('https://api.jdxcode.com/foo1');
    });
    test('follows redirect only 10 times', async () => {
        api.get('/foo1').reply(302, null, { Location: 'https://api.jdxcode.com/foo2' });
        api.get('/foo2').reply(302, null, { Location: 'https://api.jdxcode.com/foo3' });
        api.get('/foo3').reply(302, null, { Location: 'https://api.jdxcode.com/foo4' });
        api.get('/foo4').reply(302, null, { Location: 'https://api.jdxcode.com/foo5' });
        api.get('/foo5').reply(302, null, { Location: 'https://api.jdxcode.com/foo6' });
        api.get('/foo6').reply(302, null, { Location: 'https://api.jdxcode.com/foo7' });
        api.get('/foo7').reply(302, null, { Location: 'https://api.jdxcode.com/foo8' });
        api.get('/foo8').reply(302, null, { Location: 'https://api.jdxcode.com/foo9' });
        api.get('/foo9').reply(302, null, { Location: 'https://api.jdxcode.com/foo10' });
        api.get('/foo10').reply(302, null, { Location: 'https://api.jdxcode.com/foo11' });
        api.get('/foo11').reply(302, null, { Location: 'https://api.jdxcode.com/foo12' });
        expect.assertions(1);
        try {
            await http_1.HTTP.get('https://api.jdxcode.com/foo1');
        }
        catch (err) {
            expect(err.message).toEqual('Redirect loop at https://api.jdxcode.com:443/foo11');
        }
    });
});
describe('HTTP.post()', () => {
    test('makes a POST request', async () => {
        api.post('/', { foo: 'bar' }).reply(200, { message: 'ok' });
        let { body } = await http_1.HTTP.post('https://api.jdxcode.com', { body: { foo: 'bar' } });
        expect(body).toEqual({ message: 'ok' });
    });
    test('does not include a body if no body is passed in', async () => {
        api.post('/').reply(200, { message: 'ok' });
        let { body } = await http_1.HTTP.post('https://api.jdxcode.com');
        expect(body).toEqual({ message: 'ok' });
    });
    test('faithfully passes custom-encoded content-types', async () => {
        let apiEncoded = nock('https://api.jdxcode.com', {
            reqheaders: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
        });
        let body = {
            karate: 'chop',
            judo: 'throw',
            taewkondo: 'kick',
            jujitsu: 'strangle',
        };
        let options = {
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: querystring.stringify(body),
        };
        apiEncoded.post('/', querystring.stringify(body)).reply(200, { message: 'ok' });
        let rsp = await http_1.HTTP.post('https://api.jdxcode.com/', options);
        expect(rsp.body).toEqual({ message: 'ok' });
    });
});
describe('HTTP.parseBody()', () => {
    let body;
    let http;
    beforeEach(() => {
        body = {
            karate: 'chop',
            judo: 'throw',
            taewkondo: 'kick',
            jujitsu: 'strangle',
        };
        http = new http_1.HTTP('www.duckduckgo.com', { body });
    });
    it('sets the Content-Length', () => {
        expect(http.options.headers['Content-Length']).toEqual(Buffer.byteLength(JSON.stringify(body)).toString());
    });
    it('sets the Content-Type to JSON when Content-Type is unspecified', () => {
        expect(http.options.headers['content-type']).toEqual('application/json');
    });
    it('does not set the Content Type if it already exists', () => {
        let options = {
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: querystring.stringify(body),
        };
        http = new http_1.HTTP('www.duckduckgo.com', options);
        expect(http.options.headers['content-type']).toEqual('application/x-www-form-urlencoded');
    });
    it('resets the value for http.body object', () => {
        expect(http.body).toBe(undefined);
    });
    it('sets the requestBody to the body contents', () => {
        expect(http.options.body).toBe(JSON.stringify(body));
    });
    describe('with next-range header', () => {
        beforeEach(() => {
            api
                .get('/')
                .reply(206, [1, 2, 3], {
                'next-range': '4',
            })
                .get('/')
                // .matchHeader('range', '4')
                .reply(206, [4, 5, 6], {
                'next-range': '7',
            })
                .get('/')
                // .matchHeader('range', '7')
                .reply(206, [7, 8, 9]);
        });
        test('gets next body when next-range is set', async () => {
            let { body } = await http_1.HTTP.get('https://api.jdxcode.com');
            expect(body).toEqual([1, 2, 3, 4, 5, 6, 7, 8, 9]);
        });
    });
});
describe('HTTP.put()', () => {
    test('makes a PUT request', async () => {
        api.put('/', { foo: 'bar' }).reply(200, { message: 'ok' });
        let { body } = await http_1.HTTP.put('https://api.jdxcode.com', { body: { foo: 'bar' } });
        expect(body).toEqual({ message: 'ok' });
    });
});
describe('HTTP.patch()', () => {
    test('makes a PATCH request', async () => {
        api.patch('/', { foo: 'bar' }).reply(200, { message: 'ok' });
        let { body } = await http_1.HTTP.patch('https://api.jdxcode.com', { body: { foo: 'bar' } });
        expect(body).toEqual({ message: 'ok' });
    });
});
describe('HTTP.delete()', () => {
    test('makes a DELETE request', async () => {
        api.delete('/', { foo: 'bar' }).reply(200, { message: 'ok' });
        let { body } = await http_1.HTTP.delete('https://api.jdxcode.com', { body: { foo: 'bar' } });
        expect(body).toEqual({ message: 'ok' });
    });
});
describe('HTTP.stream()', () => {
    test('streams a response', async (done) => {
        api = nock('http://api.jdxcode.com');
        api.get('/').reply(200, { message: 'ok' });
        let { response } = await http_1.HTTP.stream('http://api.jdxcode.com');
        response.setEncoding('utf8');
        response.on('data', data => expect(data).toEqual('{"message":"ok"}'));
        response.on('end', done);
    });
});
