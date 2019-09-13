"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const fs = require("fs-extra");
const http_call_1 = require("http-call");
async function run(name, file, version, registry, authorization) {
    const url = [
        registry.replace(/\/+$/, ''),
        name.replace('/', '%2f') // scoped packages need escaped separator
    ].join('/');
    const headers = authorization ? { authorization } : {};
    await fs.outputJSON(file, { current: version, headers }); // touch file with current version to prevent multiple updates
    const { body } = await http_call_1.default.get(url, { headers, timeout: 5000 });
    await fs.outputJSON(file, Object.assign({}, body['dist-tags'], { current: version, authorization }));
    process.exit(0);
}
run(process.argv[2], process.argv[3], process.argv[4], process.argv[5], process.argv[6])
    .catch(require('@oclif/errors/handle'));
