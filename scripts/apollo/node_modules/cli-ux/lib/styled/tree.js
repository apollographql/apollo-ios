"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const treeify = require('treeify');
class Tree {
    constructor() {
        this.nodes = {};
    }
    insert(child, value = new Tree()) {
        this.nodes[child] = value;
        return this;
    }
    search(key) {
        for (let child of Object.keys(this.nodes)) {
            if (child === key) {
                return this.nodes[child];
            }
            else {
                let c = this.nodes[child].search(key);
                if (c)
                    return c;
            }
        }
    }
    // tslint:disable-next-line:no-console
    display(logger = console.log) {
        const addNodes = function (nodes) {
            let tree = {};
            for (let p of Object.keys(nodes)) {
                tree[p] = addNodes(nodes[p].nodes);
            }
            return tree;
        };
        let tree = addNodes(this.nodes);
        logger(treeify.asTree(tree));
    }
}
exports.Tree = Tree;
function tree() {
    return new Tree();
}
exports.default = tree;
