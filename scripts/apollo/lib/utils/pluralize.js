"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const strip_ansi_1 = __importDefault(require("strip-ansi"));
function pluralize(quantity, singular, plural = `${singular}s`) {
    const strippedQuantity = typeof quantity === "string" ? parseInt(strip_ansi_1.default(quantity), 0) : quantity;
    return `${quantity} ${strippedQuantity === 1 ? singular : plural}`;
}
exports.pluralize = pluralize;
//# sourceMappingURL=pluralize.js.map