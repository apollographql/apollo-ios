"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
class OclifLoadingHandler {
    constructor(command) {
        this.command = command;
    }
    async handle(message, value) {
        try {
            const ret = await value;
            return ret;
        }
        catch (e) {
            this.showError(`Error in "${message}": ${e}`);
            throw e;
        }
    }
    handleSync(message, value) {
        try {
            const ret = value();
            return ret;
        }
        catch (e) {
            this.showError(`Error in "${message}": ${e}`);
            throw e;
        }
    }
    showError(message) {
        this.command.error(message);
    }
}
exports.OclifLoadingHandler = OclifLoadingHandler;
//# sourceMappingURL=OclifLoadingHandler.js.map