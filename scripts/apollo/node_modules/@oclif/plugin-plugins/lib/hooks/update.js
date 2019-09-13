"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const plugins_1 = require("../plugins");
exports.update = async function () {
    const plugins = new plugins_1.default(this.config);
    await plugins.update();
};
