"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const cli_ux_1 = require("cli-ux");
const path = require("path");
const debug = require('debug')('cli:yarn');
class Yarn {
    constructor({ config }) {
        this.config = config;
    }
    get bin() {
        return require.resolve('yarn/bin/yarn.js');
    }
    fork(modulePath, args = [], options = {}) {
        return new Promise((resolve, reject) => {
            const { fork } = require('child_process');
            let forked = fork(modulePath, args, options);
            forked.stderr.on('data', (d) => process.stderr.write(d));
            forked.stdout.setEncoding('utf8');
            forked.stdout.on('data', (d) => {
                if (options.verbose)
                    process.stdout.write(d);
                else
                    cli_ux_1.default.action.status = d.replace(/\n$/, '').split('\n').pop();
            });
            forked.on('error', reject);
            forked.on('exit', (code) => {
                if (code === 0) {
                    resolve();
                }
                else {
                    reject(new Error(`yarn ${args.join(' ')} exited with code ${code}`));
                }
            });
            // Fix windows bug with node-gyp hanging for input forever
            // if (this.config.windows) {
            //   forked.stdin.write('\n')
            // }
        });
    }
    async exec(args = [], opts) {
        const cwd = opts.cwd;
        if (args[0] !== 'run') {
            const cacheDir = path.join(this.config.cacheDir, 'yarn');
            args = [
                ...args,
                '--non-interactive',
                `--mutex=file:${path.join(cwd, 'yarn.lock')}`,
                `--preferred-cache-folder=${cacheDir}`,
                '--check-files',
            ];
            if (opts.verbose) {
                args.push('--verbose');
            }
            if (this.config.npmRegistry) {
                args.push(`--registry=${this.config.npmRegistry}`);
            }
        }
        const npmRunPath = require('npm-run-path');
        let options = Object.assign({}, opts, { cwd, stdio: [0, null, null, 'ipc'], env: npmRunPath.env({ cwd, env: process.env }) });
        if (opts.verbose) {
            process.stderr.write(`${cwd}: ${this.bin} ${args.join(' ')}`);
        }
        debug(`${cwd}: ${this.bin} ${args.join(' ')}`);
        try {
            await this.fork(this.bin, args, options);
            debug('done');
        }
        catch (err) {
            // TODO: https://github.com/yarnpkg/yarn/issues/2191
            let networkConcurrency = '--network-concurrency=1';
            if (err.message.includes('EAI_AGAIN') && !args.includes(networkConcurrency)) {
                debug('EAI_AGAIN');
                return this.exec([...args, networkConcurrency], opts);
            }
            throw err;
        }
    }
}
exports.default = Yarn;
