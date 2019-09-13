"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
class CompactRenderer {
    constructor(tasks, options) {
        this._tasks = tasks;
    }
    static get nonTTY() {
        return true;
    }
    render() {
        this._tasks.forEach(task => {
            task.subscribe(event => {
                if (event.type === "STATE" &&
                    (task.state === "completed" || task.state === "failed")) {
                    console.log(task.title);
                }
            });
        });
    }
    end(err) { }
}
exports.CompactRenderer = CompactRenderer;
//# sourceMappingURL=CompactRenderer.js.map