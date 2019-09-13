"use strict";
var __rest = (this && this.__rest) || function (s, e) {
    var t = {};
    for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p) && e.indexOf(p) < 0)
        t[p] = s[p];
    if (s != null && typeof Object.getOwnPropertySymbols === "function")
        for (var i = 0, p = Object.getOwnPropertySymbols(s); i < p.length; i++) {
            if (e.indexOf(p[i]) < 0 && Object.prototype.propertyIsEnumerable.call(s, p[i]))
                t[p[i]] = s[p[i]];
        }
    return t;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const path_1 = __importDefault(require("path"));
const fs_1 = __importDefault(require("fs"));
const env_ci_1 = __importDefault(require("env-ci"));
const git_parse_1 = require("git-parse");
const git_rev_sync_1 = __importDefault(require("git-rev-sync"));
const lodash_pickby_1 = __importDefault(require("lodash.pickby"));
const lodash_identity_1 = __importDefault(require("lodash.identity"));
const findGitRoot = (start) => {
    start = start || process.cwd();
    if (typeof start === "string") {
        if (start[start.length - 1] !== path_1.default.sep)
            start += path_1.default.sep;
        start = start.split(path_1.default.sep);
    }
    if (!start.length)
        return;
    start.pop();
    const dir = start.join(path_1.default.sep);
    if (fs_1.default.existsSync(path_1.default.join(dir, ".git"))) {
        return path_1.default.normalize(dir);
    }
    else {
        return findGitRoot(start);
    }
};
exports.gitInfo = async (log) => {
    const { commit, branch: ciBranch, root, prBranch } = env_ci_1.default();
    const gitLoc = root ? root : findGitRoot();
    if (!commit)
        return;
    let committer;
    let branch = ciBranch || prBranch;
    let remoteUrl = process.env.BUILD_REPOSITORY_ID;
    let message;
    if (gitLoc) {
        const _a = await git_parse_1.gitToJs(gitLoc)
            .then((commits) => commits && commits.length > 0
            ? commits[0]
            : { authorName: null, authorEmail: null, message: null })
            .catch(() => ({ authorEmail: null, authorName: null, message: null })), { authorName, authorEmail } = _a, commit = __rest(_a, ["authorName", "authorEmail"]);
        committer = `${authorName || ""} ${authorEmail ? `<${authorEmail}>` : ""}`.trim();
        message = commit.message;
        try {
            remoteUrl = git_rev_sync_1.default.remoteUrl();
        }
        catch (e) {
            log(["Unable to retrieve remote url, failed with:", e].join("\n\n"));
        }
        if (!branch) {
            branch = git_rev_sync_1.default.branch([gitLoc]);
        }
    }
    return lodash_pickby_1.default({
        committer,
        commit,
        remoteUrl,
        message,
        branch
    }, lodash_identity_1.default);
};
//# sourceMappingURL=git.js.map