#!/usr/bin/env node
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const path_1 = require("path");
const repl_1 = require("repl");
const util_1 = require("util");
const Module = require("module");
const arg = require("arg");
const diff_1 = require("diff");
const vm_1 = require("vm");
const fs_1 = require("fs");
const index_1 = require("./index");
const args = arg({
    // Node.js-like options.
    '--eval': String,
    '--print': Boolean,
    '--require': [String],
    // CLI options.
    '--files': Boolean,
    '--help': Boolean,
    '--version': arg.COUNT,
    // Project options.
    '--compiler': String,
    '--compiler-options': index_1.parse,
    '--project': String,
    '--ignore-diagnostics': [String],
    '--ignore': [String],
    '--transpile-only': Boolean,
    '--type-check': Boolean,
    '--pretty': Boolean,
    '--skip-project': Boolean,
    '--skip-ignore': Boolean,
    '--prefer-ts-exts': Boolean,
    '--log-error': Boolean,
    // Aliases.
    '-e': '--eval',
    '-p': '--print',
    '-r': '--require',
    '-h': '--help',
    '-v': '--version',
    '-T': '--transpile-only',
    '-I': '--ignore',
    '-P': '--project',
    '-C': '--compiler',
    '-D': '--ignore-diagnostics',
    '-O': '--compiler-options'
}, {
    stopAtPositional: true
});
const { '--help': help = false, '--version': version = 0, '--files': files = index_1.DEFAULTS.files, '--compiler': compiler = index_1.DEFAULTS.compiler, '--compiler-options': compilerOptions = index_1.DEFAULTS.compilerOptions, '--project': project = index_1.DEFAULTS.project, '--ignore-diagnostics': ignoreDiagnostics = index_1.DEFAULTS.ignoreDiagnostics, '--ignore': ignore = index_1.DEFAULTS.ignore, '--transpile-only': transpileOnly = index_1.DEFAULTS.transpileOnly, '--type-check': typeCheck = index_1.DEFAULTS.typeCheck, '--pretty': pretty = index_1.DEFAULTS.pretty, '--skip-project': skipProject = index_1.DEFAULTS.skipProject, '--skip-ignore': skipIgnore = index_1.DEFAULTS.skipIgnore, '--prefer-ts-exts': preferTsExts = index_1.DEFAULTS.preferTsExts, '--log-error': logError = index_1.DEFAULTS.logError } = args;
if (help) {
    console.log(`
Usage: ts-node [options] [ -e script | script.ts ] [arguments]

Options:

  -e, --eval [code]              Evaluate code
  -p, --print                    Print result of \`--eval\`
  -r, --require [path]           Require a node module before execution

  -h, --help                     Print CLI usage
  -v, --version                  Print module version information

  -T, --transpile-only           Use TypeScript's faster \`transpileModule\`
  -I, --ignore [pattern]         Override the path patterns to skip compilation
  -P, --project [path]           Path to TypeScript JSON project file
  -C, --compiler [name]          Specify a custom TypeScript compiler
  -D, --ignore-diagnostics [code] Ignore TypeScript warnings by diagnostic code
  -O, --compiler-options [opts]   JSON object to merge with compiler options

  --files                        Load files from \`tsconfig.json\` on startup
  --pretty                       Use pretty diagnostic formatter
  --skip-project                 Skip reading \`tsconfig.json\`
  --skip-ignore                  Skip \`--ignore\` checks
  --prefer-ts-exts               Prefer importing TypeScript files over JavaScript files
`);
    process.exit(0);
}
// Output project information.
if (version === 1) {
    console.log(`v${index_1.VERSION}`);
    process.exit(0);
}
const cwd = process.cwd();
const code = args['--eval'];
const isPrinted = args['--print'] !== undefined;
/**
 * Eval helpers.
 */
const EVAL_FILENAME = `[eval].ts`;
const EVAL_PATH = path_1.join(cwd, EVAL_FILENAME);
const EVAL_INSTANCE = { input: '', output: '', version: 0, lines: 0 };
// Register the TypeScript compiler instance.
const service = index_1.register({
    files,
    pretty,
    typeCheck,
    transpileOnly,
    ignore,
    project,
    skipIgnore,
    preferTsExts,
    logError,
    skipProject,
    compiler,
    ignoreDiagnostics,
    compilerOptions,
    readFile: code ? readFileEval : undefined,
    fileExists: code ? fileExistsEval : undefined
});
// Output project information.
if (version >= 2) {
    console.log(`ts-node v${index_1.VERSION}`);
    console.log(`node ${process.version}`);
    console.log(`compiler v${service.ts.version}`);
    process.exit(0);
}
// Require specified modules before start-up.
if (args['--require'])
    Module._preloadModules(args['--require']);
// Prepend `ts-node` arguments to CLI for child processes.
process.execArgv.unshift(__filename, ...process.argv.slice(2, process.argv.length - args._.length));
process.argv = [process.argv[1]].concat(args._.length ? path_1.resolve(cwd, args._[0]) : []).concat(args._.slice(1));
// Execute the main contents (either eval, script or piped).
if (code) {
    evalAndExit(code, isPrinted);
}
else {
    if (args._.length) {
        Module.runMain();
    }
    else {
        // Piping of execution _only_ occurs when no other script is specified.
        if (process.stdin.isTTY) {
            startRepl();
        }
        else {
            let code = '';
            process.stdin.on('data', (chunk) => code += chunk);
            process.stdin.on('end', () => evalAndExit(code, isPrinted));
        }
    }
}
/**
 * Evaluate a script.
 */
function evalAndExit(code, isPrinted) {
    const module = new Module(EVAL_FILENAME);
    module.filename = EVAL_FILENAME;
    module.paths = Module._nodeModulePaths(cwd);
    global.__filename = EVAL_FILENAME;
    global.__dirname = cwd;
    global.exports = module.exports;
    global.module = module;
    global.require = module.require.bind(module);
    let result;
    try {
        result = _eval(code);
    }
    catch (error) {
        if (error instanceof index_1.TSError) {
            console.error(error.diagnosticText);
            process.exit(1);
        }
        throw error;
    }
    if (isPrinted) {
        console.log(typeof result === 'string' ? result : util_1.inspect(result));
    }
}
/**
 * Evaluate the code snippet.
 */
function _eval(input) {
    const lines = EVAL_INSTANCE.lines;
    const isCompletion = !/\n$/.test(input);
    const undo = appendEval(input);
    let output;
    try {
        output = service.compile(EVAL_INSTANCE.input, EVAL_PATH, -lines);
    }
    catch (err) {
        undo();
        throw err;
    }
    // Use `diff` to check for new JavaScript to execute.
    const changes = diff_1.diffLines(EVAL_INSTANCE.output, output);
    if (isCompletion) {
        undo();
    }
    else {
        EVAL_INSTANCE.output = output;
    }
    return changes.reduce((result, change) => {
        return change.added ? exec(change.value, EVAL_FILENAME) : result;
    }, undefined);
}
/**
 * Execute some code.
 */
function exec(code, filename) {
    const script = new vm_1.Script(code, { filename: filename });
    return script.runInThisContext();
}
/**
 * Start a CLI REPL.
 */
function startRepl() {
    const repl = repl_1.start({
        prompt: '> ',
        input: process.stdin,
        output: process.stdout,
        terminal: process.stdout.isTTY,
        eval: replEval,
        useGlobal: true
    });
    // Bookmark the point where we should reset the REPL state.
    const resetEval = appendEval('');
    function reset() {
        resetEval();
        // Hard fix for TypeScript forcing `Object.defineProperty(exports, ...)`.
        exec('exports = module.exports', EVAL_FILENAME);
    }
    reset();
    repl.on('reset', reset);
    repl.defineCommand('type', {
        help: 'Check the type of a TypeScript identifier',
        action: function (identifier) {
            if (!identifier) {
                repl.displayPrompt();
                return;
            }
            const undo = appendEval(identifier);
            const { name, comment } = service.getTypeInfo(EVAL_INSTANCE.input, EVAL_PATH, EVAL_INSTANCE.input.length);
            undo();
            repl.outputStream.write(`${name}\n${comment ? `${comment}\n` : ''}`);
            repl.displayPrompt();
        }
    });
}
/**
 * Eval code from the REPL.
 */
function replEval(code, _context, _filename, callback) {
    let err = null;
    let result;
    // TODO: Figure out how to handle completion here.
    if (code === '.scope') {
        callback(err);
        return;
    }
    try {
        result = _eval(code);
    }
    catch (error) {
        if (error instanceof index_1.TSError) {
            // Support recoverable compilations using >= node 6.
            if (repl_1.Recoverable && isRecoverable(error)) {
                err = new repl_1.Recoverable(error);
            }
            else {
                console.error(error.diagnosticText);
            }
        }
        else {
            err = error;
        }
    }
    callback(err, result);
}
/**
 * Append to the eval instance and return an undo function.
 */
function appendEval(input) {
    const undoInput = EVAL_INSTANCE.input;
    const undoVersion = EVAL_INSTANCE.version;
    const undoOutput = EVAL_INSTANCE.output;
    const undoLines = EVAL_INSTANCE.lines;
    // Handle ASI issues with TypeScript re-evaluation.
    if (undoInput.charAt(undoInput.length - 1) === '\n' && /^\s*[\[\(\`]/.test(input) && !/;\s*$/.test(undoInput)) {
        EVAL_INSTANCE.input = `${EVAL_INSTANCE.input.slice(0, -1)};\n`;
    }
    EVAL_INSTANCE.input += input;
    EVAL_INSTANCE.lines += lineCount(input);
    EVAL_INSTANCE.version++;
    return function () {
        EVAL_INSTANCE.input = undoInput;
        EVAL_INSTANCE.output = undoOutput;
        EVAL_INSTANCE.version = undoVersion;
        EVAL_INSTANCE.lines = undoLines;
    };
}
/**
 * Count the number of lines.
 */
function lineCount(value) {
    let count = 0;
    for (const char of value) {
        if (char === '\n') {
            count++;
        }
    }
    return count;
}
/**
 * Get the file text, checking for eval first.
 */
function readFileEval(path) {
    if (path === EVAL_PATH)
        return EVAL_INSTANCE.input;
    try {
        return fs_1.readFileSync(path, 'utf8');
    }
    catch (err) { /* Ignore. */ }
}
/**
 * Get whether the file exists.
 */
function fileExistsEval(path) {
    if (path === EVAL_PATH)
        return true;
    try {
        const stats = fs_1.statSync(path);
        return stats.isFile() || stats.isFIFO();
    }
    catch (err) {
        return false;
    }
}
const RECOVERY_CODES = new Set([
    1003,
    1005,
    1109,
    1126,
    1160,
    1161,
    2355 // "A function whose declared type is neither 'void' nor 'any' must return a value."
]);
/**
 * Check if a function can recover gracefully.
 */
function isRecoverable(error) {
    return error.diagnosticCodes.every(code => RECOVERY_CODES.has(code));
}
//# sourceMappingURL=bin.js.map