"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const fs = require("fs");
const os = require("os");
const path = require("path");
const debug = require('debug')('netrc-parser');
function parse(body) {
    const lines = body.split('\n');
    let pre = [];
    let machines = [];
    while (lines.length) {
        const line = lines.shift();
        const match = line.match(/machine\s+((?:[^#\s]+[\s]*)+)(#.*)?$/);
        if (!match) {
            pre.push(line);
            continue;
        }
        const [, body, comment] = match;
        const machine = {
            type: 'machine',
            host: body.split(' ')[0],
            pre: pre.join('\n'),
            internalWhitespace: '\n  ',
            props: {},
            comment,
        };
        pre = [];
        // do not read other machines with same host
        if (!machines.find(m => m.type === 'machine' && m.host === machine.host))
            machines.push(machine);
        if (body.trim().includes(' ')) { // inline machine
            const [host, ...propStrings] = body.split(' ');
            for (let a = 0; a < propStrings.length; a += 2) {
                machine.props[propStrings[a]] = { value: propStrings[a + 1] };
            }
            machine.host = host;
            machine.internalWhitespace = ' ';
        }
        else { // multiline machine
            while (lines.length) {
                const line = lines.shift();
                const match = line.match(/^(\s+)([\S]+)\s+([\S]+)(\s+#.*)?$/);
                if (!match) {
                    lines.unshift(line);
                    break;
                }
                const [, ws, key, value, comment] = match;
                machine.props[key] = { value, comment };
                machine.internalWhitespace = `\n${ws}`;
            }
        }
    }
    return proxify([...machines, { type: 'other', content: pre.join('\n') }]);
}
exports.parse = parse;
class Netrc {
    constructor(file) {
        this.file = file || this.defaultFile;
    }
    async load() {
        try {
            debug('load', this.file);
            const decryptFile = async () => {
                const execa = require('execa');
                const { code, stdout } = await execa('gpg', this.gpgDecryptArgs, { stdio: [0, null, 2] });
                if (code !== 0)
                    throw new Error(`gpg exited with code ${code}`);
                return stdout;
            };
            let body = '';
            if (path.extname(this.file) === '.gpg') {
                body = await decryptFile();
            }
            else {
                body = await new Promise((resolve, reject) => {
                    fs.readFile(this.file, { encoding: 'utf8' }, (err, data) => {
                        if (err && err.code !== 'ENOENT')
                            reject(err);
                        debug('ENOENT');
                        resolve(data || '');
                    });
                });
            }
            this.machines = parse(body);
            debug('machines: %o', Object.keys(this.machines));
        }
        catch (err) {
            return this.throw(err);
        }
    }
    loadSync() {
        try {
            debug('loadSync', this.file);
            const decryptFile = () => {
                const execa = require('execa');
                const { stdout, status } = execa.sync('gpg', this.gpgDecryptArgs, { stdio: [0, null, 2] });
                if (status)
                    throw new Error(`gpg exited with code ${status}`);
                return stdout;
            };
            let body = '';
            if (path.extname(this.file) === '.gpg') {
                body = decryptFile();
            }
            else {
                try {
                    body = fs.readFileSync(this.file, 'utf8');
                }
                catch (err) {
                    if (err.code !== 'ENOENT')
                        throw err;
                }
            }
            this.machines = parse(body);
            debug('machines: %o', Object.keys(this.machines));
        }
        catch (err) {
            return this.throw(err);
        }
    }
    async save() {
        debug('save', this.file);
        let body = this.output;
        if (this.file.endsWith('.gpg')) {
            const execa = require('execa');
            const { stdout, code } = await execa('gpg', this.gpgEncryptArgs, { input: body, stdio: [null, null, 2] });
            if (code)
                throw new Error(`gpg exited with code ${code}`);
            body = stdout;
        }
        return new Promise((resolve, reject) => {
            fs.writeFile(this.file, body, { mode: 0o600 }, err => (err ? reject(err) : resolve()));
        });
    }
    saveSync() {
        debug('saveSync', this.file);
        let body = this.output;
        if (this.file.endsWith('.gpg')) {
            const execa = require('execa');
            const { stdout, code } = execa.sync('gpg', this.gpgEncryptArgs, { input: body, stdio: [null, null, 2] });
            if (code)
                throw new Error(`gpg exited with code ${status}`);
            body = stdout;
        }
        fs.writeFileSync(this.file, body, { mode: 0o600 });
    }
    get output() {
        let output = [];
        for (let t of this.machines._tokens) {
            if (t.type === 'other') {
                output.push(t.content);
                continue;
            }
            if (t.pre)
                output.push(t.pre + '\n');
            output.push(`machine ${t.host}`);
            const addProps = (t) => {
                const addProp = (k) => output.push(`${t.internalWhitespace}${k} ${t.props[k].value}${t.props[k].comment || ''}`);
                // do login/password first
                if (t.props.login)
                    addProp('login');
                if (t.props.password)
                    addProp('password');
                for (let k of Object.keys(t.props).filter(k => !['login', 'password'].includes(k))) {
                    addProp(k);
                }
            };
            const addComment = (t) => t.comment && output.push(' ' + t.comment);
            if (t.internalWhitespace.includes('\n')) {
                addComment(t);
                addProps(t);
                output.push('\n');
            }
            else {
                addProps(t);
                addComment(t);
                output.push('\n');
            }
        }
        return output.join('');
    }
    get defaultFile() {
        const home = (os.platform() === 'win32' &&
            (process.env.HOME ||
                (process.env.HOMEDRIVE && process.env.HOMEPATH && path.join(process.env.HOMEDRIVE, process.env.HOMEPATH)) ||
                process.env.USERPROFILE)) ||
            os.homedir() ||
            os.tmpdir();
        let file = path.join(home, os.platform() === 'win32' ? '_netrc' : '.netrc');
        return fs.existsSync(file + '.gpg') ? (file += '.gpg') : file;
    }
    get gpgDecryptArgs() {
        const args = ['--batch', '--quiet', '--decrypt', this.file];
        debug('running gpg with args %o', args);
        return args;
    }
    get gpgEncryptArgs() {
        const args = ['-a', '--batch', '--default-recipient-self', '-e'];
        debug('running gpg with args %o', args);
        return args;
    }
    throw(err) {
        if (err.detail)
            err.detail += '\n';
        else
            err.detail = '';
        err.detail += `Error occurred during reading netrc file: ${this.file}`;
        throw err;
    }
}
exports.Netrc = Netrc;
exports.default = new Netrc();
// this is somewhat complicated but it takes the array of parsed tokens from parse()
// and it creates ES6 proxy objects to allow them to be easily modified by the consumer of this library
function proxify(tokens) {
    const proxifyProps = (t) => new Proxy(t.props, {
        get(_, key) {
            if (key === 'host')
                return t.host;
            // tslint:disable-next-line strict-type-predicates
            if (typeof key !== 'string')
                return t.props[key];
            const prop = t.props[key];
            if (!prop)
                return;
            return prop.value;
        },
        set(_, key, value) {
            if (key === 'host') {
                t.host = value;
            }
            else if (!value) {
                delete t.props[key];
            }
            else {
                t.props[key] = t.props[key] || (t.props[key] = { value: '' });
                t.props[key].value = value;
            }
            return true;
        },
    });
    const machineTokens = tokens.filter((m) => m.type === 'machine');
    const machines = machineTokens.map(proxifyProps);
    const getWhitespace = () => {
        if (!machineTokens.length)
            return ' ';
        return machineTokens[machineTokens.length - 1].internalWhitespace;
    };
    const obj = {};
    obj._tokens = tokens;
    for (let m of machines)
        obj[m.host] = m;
    return new Proxy(obj, {
        set(obj, host, props) {
            if (!props) {
                delete obj[host];
                const idx = tokens.findIndex(m => m.type === 'machine' && m.host === host);
                if (idx === -1)
                    return true;
                tokens.splice(idx, 1);
                return true;
            }
            let machine = machines.find(m => m.host === host);
            if (!machine) {
                const token = { type: 'machine', host, internalWhitespace: getWhitespace(), props: {} };
                tokens.push(token);
                machine = proxifyProps(token);
                machines.push(machine);
                obj[host] = machine;
            }
            for (let [k, v] of Object.entries(props)) {
                machine[k] = v;
            }
            return true;
        },
        deleteProperty(obj, host) {
            delete obj[host];
            const idx = tokens.findIndex(m => m.type === 'machine' && m.host === host);
            if (idx === -1)
                return true;
            tokens.splice(idx, 1);
            return true;
        },
        ownKeys() {
            return machines.map(m => m.host);
        },
    });
}
