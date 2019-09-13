"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const moment_1 = require("moment");
function validateHistoricParams({ validationPeriod, queryCountThreshold, queryCountThresholdPercentage }) {
    if (!validationPeriod &&
        !queryCountThreshold &&
        !queryCountThresholdPercentage) {
        return null;
    }
    let from = null;
    if (validationPeriod) {
        from = isNumeric(validationPeriod)
            ? -1 * moment_1.duration(Number(validationPeriod), "seconds").asSeconds()
            : -1 * moment_1.duration(validationPeriod).asSeconds();
        if (from >= 0) {
            throw new Error("Please provide a valid duration for the --validationPeriod flag. Valid durations are represented in ISO 8601, see: https://bit.ly/2DEJ3UN.");
        }
    }
    if (queryCountThreshold &&
        (!Number.isInteger(queryCountThreshold) || queryCountThreshold < 1)) {
        throw new Error("Please provide a valid number for the --queryCountThreshold flag. Valid numbers are integers in the range x >= 1.");
    }
    let asPercentage = null;
    if (queryCountThresholdPercentage) {
        if (queryCountThresholdPercentage < 0 ||
            queryCountThresholdPercentage > 100) {
            throw new Error("Please provide a valid number for the --queryCountThresholdPercentage flag. Valid numbers are in the range 0 <= x <= 100.");
        }
        asPercentage = queryCountThresholdPercentage / 100;
    }
    return Object.assign({}, (from && { to: -0, from }), (queryCountThreshold && { queryCountThreshold }), (asPercentage && { queryCountThresholdPercentage: asPercentage }));
}
exports.validateHistoricParams = validateHistoricParams;
function isNumeric(maybeNumber) {
    return !Number.isNaN(Number(maybeNumber));
}
//# sourceMappingURL=validateHistoricParams.js.map