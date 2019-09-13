"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const child_process_1 = require("child_process");
const fs = require("fs-extra");
const path = require("path");
const semver = require("semver");
const debug = require('debug')('update-check');
const hook = async function ({ config }) {
    const file = path.join(config.cacheDir, 'version');
    // Destructure package.json configuration with defaults
    const { timeoutInDays = 60, message = '<%= config.name %> update available from <%= chalk.greenBright(config.version) %> to <%= chalk.greenBright(latest) %>.', registry = 'https://registry.npmjs.org', authorization = '', } = config.pjson.oclif['warn-if-update-available'] || {};
    const checkVersion = async () => {
        try {
            // do not show warning if updating
            if (process.argv[2] === 'update')
                return;
            const distTags = await fs.readJSON(file);
            if (config.version.includes('-')) {
                // TODO: handle channels
                return;
            }
            if (distTags && distTags.latest && semver.gt(distTags.latest.split('-')[0], config.version.split('-')[0])) {
                const chalk = require('chalk');
                const template = require('lodash.template');
                // Default message if the user doesn't provide one
                this.warn(template(message)(Object.assign({ chalk,
                    config }, distTags)));
            }
        }
        catch (err) {
            if (err.code !== 'ENOENT')
                throw err;
        }
    };
    const refreshNeeded = async () => {
        try {
            const { mtime } = await fs.stat(file);
            const staleAt = new Date(mtime.valueOf() + 1000 * 60 * 60 * 24 * timeoutInDays);
            return staleAt < new Date();
        }
        catch (err) {
            debug(err);
            return true;
        }
    };
    const spawnRefresh = async () => {
        debug('spawning version refresh');
        child_process_1.spawn(process.execPath, [path.join(__dirname, '../../../lib/get-version'), config.name, file, config.version, registry, authorization], {
            detached: !config.windows,
            stdio: 'ignore',
        }).unref();
    };
    await checkVersion();
    if (await refreshNeeded())
        await spawnRefresh();
};
exports.default = hook;
