"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const path_1 = require("path");
const sourceMapSupport = require("source-map-support");
const yn_1 = require("yn");
const make_error_1 = require("make-error");
const util = require("util");
/**
 * @internal
 */
exports.INSPECT_CUSTOM = util.inspect.custom || 'inspect';
/**
 * Debugging `ts-node`.
 */
const shouldDebug = yn_1.default(process.env.TS_NODE_DEBUG);
const debug = shouldDebug ? console.log.bind(console, 'ts-node') : () => undefined;
const debugFn = shouldDebug ?
    (key, fn) => {
        let i = 0;
        return (x) => {
            debug(key, x, ++i);
            return fn(x);
        };
    } :
    (_, fn) => fn;
/**
 * Export the current version.
 */
exports.VERSION = require('../package.json').version;
/**
 * Track the project information.
 */
class MemoryCache {
    constructor(rootFileNames = []) {
        this.fileContents = new Map();
        this.fileVersions = new Map();
        for (const fileName of rootFileNames)
            this.fileVersions.set(fileName, 1);
    }
}
/**
 * Default register options.
 */
exports.DEFAULTS = {
    files: yn_1.default(process.env['TS_NODE_FILES']),
    pretty: yn_1.default(process.env['TS_NODE_PRETTY']),
    compiler: process.env['TS_NODE_COMPILER'],
    compilerOptions: parse(process.env['TS_NODE_COMPILER_OPTIONS']),
    ignore: split(process.env['TS_NODE_IGNORE']),
    project: process.env['TS_NODE_PROJECT'],
    skipIgnore: yn_1.default(process.env['TS_NODE_SKIP_IGNORE']),
    skipProject: yn_1.default(process.env['TS_NODE_SKIP_PROJECT']),
    preferTsExts: yn_1.default(process.env['TS_NODE_PREFER_TS_EXTS']),
    ignoreDiagnostics: split(process.env['TS_NODE_IGNORE_DIAGNOSTICS']),
    typeCheck: yn_1.default(process.env['TS_NODE_TYPE_CHECK']),
    transpileOnly: yn_1.default(process.env['TS_NODE_TRANSPILE_ONLY']),
    logError: yn_1.default(process.env['TS_NODE_LOG_ERROR'])
};
/**
 * Default TypeScript compiler options required by `ts-node`.
 */
const TS_NODE_COMPILER_OPTIONS = {
    sourceMap: true,
    inlineSourceMap: false,
    inlineSources: true,
    declaration: false,
    noEmit: false,
    outDir: '$$ts-node$$'
};
/**
 * Split a string array of values.
 */
function split(value) {
    return typeof value === 'string' ? value.split(/ *, */g) : undefined;
}
exports.split = split;
/**
 * Parse a string as JSON.
 */
function parse(value) {
    return typeof value === 'string' ? JSON.parse(value) : undefined;
}
exports.parse = parse;
/**
 * Replace backslashes with forward slashes.
 */
function normalizeSlashes(value) {
    return value.replace(/\\/g, '/');
}
exports.normalizeSlashes = normalizeSlashes;
/**
 * TypeScript diagnostics error.
 */
class TSError extends make_error_1.BaseError {
    constructor(diagnosticText, diagnosticCodes) {
        super(`⨯ Unable to compile TypeScript:\n${diagnosticText}`);
        this.diagnosticText = diagnosticText;
        this.diagnosticCodes = diagnosticCodes;
        this.name = 'TSError';
    }
    /**
     * @internal
     */
    [exports.INSPECT_CUSTOM]() {
        return this.diagnosticText;
    }
}
exports.TSError = TSError;
/**
 * Cached fs operation wrapper.
 */
function cachedLookup(fn) {
    const cache = new Map();
    return (arg) => {
        if (!cache.has(arg)) {
            cache.set(arg, fn(arg));
        }
        return cache.get(arg);
    };
}
/**
 * Register TypeScript compiler.
 */
function register(opts = {}) {
    const options = Object.assign({}, exports.DEFAULTS, opts);
    const originalJsHandler = require.extensions['.js']; // tslint:disable-line
    const ignoreDiagnostics = [
        6059,
        18002,
        18003,
        ...(options.ignoreDiagnostics || [])
    ].map(Number);
    const ignore = options.skipIgnore ? [] : (options.ignore || ['/node_modules/']).map(str => new RegExp(str));
    // Require the TypeScript compiler and configuration.
    const cwd = process.cwd();
    const typeCheck = options.typeCheck === true || options.transpileOnly !== true;
    const compiler = require.resolve(options.compiler || 'typescript', { paths: [cwd, __dirname] });
    const ts = require(compiler);
    const transformers = options.transformers || undefined;
    const readFile = options.readFile || ts.sys.readFile;
    const fileExists = options.fileExists || ts.sys.fileExists;
    const config = readConfig(cwd, ts, fileExists, readFile, options);
    const configDiagnosticList = filterDiagnostics(config.errors, ignoreDiagnostics);
    const extensions = ['.ts'];
    const outputCache = new Map();
    const diagnosticHost = {
        getNewLine: () => ts.sys.newLine,
        getCurrentDirectory: () => cwd,
        getCanonicalFileName: (path) => path
    };
    // Install source map support and read from memory cache.
    sourceMapSupport.install({
        environment: 'node',
        retrieveFile(path) {
            return outputCache.get(path) || '';
        }
    });
    const formatDiagnostics = process.stdout.isTTY || options.pretty
        ? ts.formatDiagnosticsWithColorAndContext
        : ts.formatDiagnostics;
    function createTSError(diagnostics) {
        const diagnosticText = formatDiagnostics(diagnostics, diagnosticHost);
        const diagnosticCodes = diagnostics.map(x => x.code);
        return new TSError(diagnosticText, diagnosticCodes);
    }
    function reportTSError(configDiagnosticList) {
        const error = createTSError(configDiagnosticList);
        if (options.logError) {
            // Print error in red color and continue execution.
            console.error('\x1b[31m%s\x1b[0m', error);
        }
        else {
            // Throw error and exit the script.
            throw error;
        }
    }
    // Render the configuration errors.
    if (configDiagnosticList.length)
        reportTSError(configDiagnosticList);
    // Enable additional extensions when JSX or `allowJs` is enabled.
    if (config.options.jsx)
        extensions.push('.tsx');
    if (config.options.allowJs)
        extensions.push('.js');
    if (config.options.jsx && config.options.allowJs)
        extensions.push('.jsx');
    /**
     * Get the extension for a transpiled file.
     */
    const getExtension = config.options.jsx === ts.JsxEmit.Preserve ?
        ((path) => /\.[tj]sx$/.test(path) ? '.jsx' : '.js') :
        ((_) => '.js');
    /**
     * Create the basic required function using transpile mode.
     */
    let getOutput = function (code, fileName, lineOffset = 0) {
        const result = ts.transpileModule(code, {
            fileName,
            transformers,
            compilerOptions: config.options,
            reportDiagnostics: true
        });
        const diagnosticList = result.diagnostics ?
            filterDiagnostics(result.diagnostics, ignoreDiagnostics) :
            [];
        if (diagnosticList.length)
            reportTSError(configDiagnosticList);
        return [result.outputText, result.sourceMapText];
    };
    let getTypeInfo = function (_code, _fileName, _position) {
        throw new TypeError(`Type information is unavailable without "--type-check"`);
    };
    // Use full language services when the fast option is disabled.
    if (typeCheck) {
        const memoryCache = new MemoryCache(config.fileNames);
        const cachedReadFile = cachedLookup(debugFn('readFile', readFile));
        // Create the compiler host for type checking.
        const serviceHost = {
            getScriptFileNames: () => Array.from(memoryCache.fileVersions.keys()),
            getScriptVersion: (fileName) => {
                const version = memoryCache.fileVersions.get(fileName);
                return version === undefined ? '' : version.toString();
            },
            getScriptSnapshot(fileName) {
                let contents = memoryCache.fileContents.get(fileName);
                // Read contents into TypeScript memory cache.
                if (contents === undefined) {
                    contents = cachedReadFile(fileName);
                    if (contents === undefined)
                        return;
                    memoryCache.fileVersions.set(fileName, 1);
                    memoryCache.fileContents.set(fileName, contents);
                }
                return ts.ScriptSnapshot.fromString(contents);
            },
            readFile: cachedReadFile,
            readDirectory: cachedLookup(debugFn('readDirectory', ts.sys.readDirectory)),
            getDirectories: cachedLookup(debugFn('getDirectories', ts.sys.getDirectories)),
            fileExists: cachedLookup(debugFn('fileExists', fileExists)),
            directoryExists: cachedLookup(debugFn('directoryExists', ts.sys.directoryExists)),
            getNewLine: () => ts.sys.newLine,
            useCaseSensitiveFileNames: () => ts.sys.useCaseSensitiveFileNames,
            getCurrentDirectory: () => cwd,
            getCompilationSettings: () => config.options,
            getDefaultLibFileName: () => ts.getDefaultLibFilePath(config.options),
            getCustomTransformers: () => transformers
        };
        const registry = ts.createDocumentRegistry(ts.sys.useCaseSensitiveFileNames, cwd);
        const service = ts.createLanguageService(serviceHost, registry);
        // Set the file contents into cache manually.
        const updateMemoryCache = function (contents, fileName) {
            const fileVersion = memoryCache.fileVersions.get(fileName) || 0;
            // Avoid incrementing cache when nothing has changed.
            if (memoryCache.fileContents.get(fileName) === contents)
                return;
            memoryCache.fileVersions.set(fileName, fileVersion + 1);
            memoryCache.fileContents.set(fileName, contents);
        };
        getOutput = function (code, fileName, lineOffset = 0) {
            updateMemoryCache(code, fileName);
            const output = service.getEmitOutput(fileName);
            // Get the relevant diagnostics - this is 3x faster than `getPreEmitDiagnostics`.
            const diagnostics = service.getSemanticDiagnostics(fileName)
                .concat(service.getSyntacticDiagnostics(fileName));
            const diagnosticList = filterDiagnostics(diagnostics, ignoreDiagnostics);
            if (diagnosticList.length)
                reportTSError(diagnosticList);
            if (output.emitSkipped) {
                throw new TypeError(`${path_1.relative(cwd, fileName)}: Emit skipped`);
            }
            // Throw an error when requiring `.d.ts` files.
            if (output.outputFiles.length === 0) {
                throw new TypeError('Unable to require `.d.ts` file.\n' +
                    'This is usually the result of a faulty configuration or import. ' +
                    'Make sure there is a `.js`, `.json` or another executable extension and ' +
                    'loader (attached before `ts-node`) available alongside ' +
                    `\`${path_1.basename(fileName)}\`.`);
            }
            return [output.outputFiles[1].text, output.outputFiles[0].text];
        };
        getTypeInfo = function (code, fileName, position) {
            updateMemoryCache(code, fileName);
            const info = service.getQuickInfoAtPosition(fileName, position);
            const name = ts.displayPartsToString(info ? info.displayParts : []);
            const comment = ts.displayPartsToString(info ? info.documentation : []);
            return { name, comment };
        };
    }
    // Create a simple TypeScript compiler proxy.
    function compile(code, fileName, lineOffset) {
        const [value, sourceMap] = getOutput(code, fileName, lineOffset);
        const output = updateOutput(value, fileName, sourceMap, getExtension);
        outputCache.set(fileName, output);
        return output;
    }
    const register = { cwd, compile, getTypeInfo, extensions, ts };
    // Register the extensions.
    registerExtensions(opts, extensions, ignore, register, originalJsHandler);
    return register;
}
exports.register = register;
/**
 * Check if the filename should be ignored.
 */
function shouldIgnore(filename, ignore) {
    const relname = normalizeSlashes(filename);
    return ignore.some(x => x.test(relname));
}
/**
 * "Refreshes" an extension on `require.extentions`.
 *
 * @param {string} ext
 */
function reorderRequireExtension(ext) {
    const old = require.extensions[ext]; // tslint:disable-line
    delete require.extensions[ext]; // tslint:disable-line
    require.extensions[ext] = old; // tslint:disable-line
}
/**
 * Register the extensions to support when importing files.
 */
function registerExtensions(opts, extensions, ignore, register, originalJsHandler) {
    // Register new extensions.
    for (const ext of extensions) {
        registerExtension(ext, ignore, register, originalJsHandler);
    }
    if (opts.preferTsExts) {
        // tslint:disable-next-line
        const preferredExtensions = new Set([...extensions, ...Object.keys(require.extensions)]);
        for (const ext of preferredExtensions)
            reorderRequireExtension(ext);
    }
}
/**
 * Register the extension for node.
 */
function registerExtension(ext, ignore, register, originalHandler) {
    const old = require.extensions[ext] || originalHandler; // tslint:disable-line
    require.extensions[ext] = function (m, filename) {
        if (shouldIgnore(filename, ignore)) {
            return old(m, filename);
        }
        const _compile = m._compile;
        m._compile = function (code, fileName) {
            debug('module._compile', fileName);
            return _compile.call(this, register.compile(code, fileName), fileName);
        };
        return old(m, filename);
    };
}
/**
 * Do post-processing on config options to support `ts-node`.
 */
function fixConfig(ts, config) {
    // Delete options that *should not* be passed through.
    delete config.options.out;
    delete config.options.outFile;
    delete config.options.composite;
    delete config.options.declarationDir;
    delete config.options.declarationMap;
    delete config.options.emitDeclarationOnly;
    delete config.options.tsBuildInfoFile;
    delete config.options.incremental;
    // Target ES5 output by default (instead of ES3).
    if (config.options.target === undefined) {
        config.options.target = ts.ScriptTarget.ES5;
    }
    // Target CommonJS modules by default (instead of magically switching to ES6 when the target is ES6).
    if (config.options.module === undefined) {
        config.options.module = ts.ModuleKind.CommonJS;
    }
    return config;
}
/**
 * Load TypeScript configuration.
 */
function readConfig(cwd, ts, fileExists, readFile, options) {
    let config = { compilerOptions: {} };
    let basePath = normalizeSlashes(cwd);
    let configFileName = undefined;
    // Read project configuration when available.
    if (!options.skipProject) {
        configFileName = options.project
            ? normalizeSlashes(path_1.resolve(cwd, options.project))
            : ts.findConfigFile(normalizeSlashes(cwd), fileExists);
        if (configFileName) {
            const result = ts.readConfigFile(configFileName, readFile);
            // Return diagnostics.
            if (result.error) {
                return { errors: [result.error], fileNames: [], options: {} };
            }
            config = result.config;
            basePath = normalizeSlashes(path_1.dirname(configFileName));
        }
    }
    // Remove resolution of "files".
    if (!options.files) {
        config.files = [];
        config.include = [];
    }
    // Override default configuration options `ts-node` requires.
    config.compilerOptions = Object.assign({}, config.compilerOptions, options.compilerOptions, TS_NODE_COMPILER_OPTIONS);
    return fixConfig(ts, ts.parseJsonConfigFileContent(config, ts.sys, basePath, undefined, configFileName));
}
/**
 * Update the output remapping the source map.
 */
function updateOutput(outputText, fileName, sourceMap, getExtension) {
    const base64Map = Buffer.from(updateSourceMap(sourceMap, fileName), 'utf8').toString('base64');
    const sourceMapContent = `data:application/json;charset=utf-8;base64,${base64Map}`;
    const sourceMapLength = `${path_1.basename(fileName)}.map`.length + (getExtension(fileName).length - path_1.extname(fileName).length);
    return outputText.slice(0, -sourceMapLength) + sourceMapContent;
}
/**
 * Update the source map contents for improved output.
 */
function updateSourceMap(sourceMapText, fileName) {
    const sourceMap = JSON.parse(sourceMapText);
    sourceMap.file = fileName;
    sourceMap.sources = [fileName];
    delete sourceMap.sourceRoot;
    return JSON.stringify(sourceMap);
}
/**
 * Filter diagnostics.
 */
function filterDiagnostics(diagnostics, ignore) {
    return diagnostics.filter(x => ignore.indexOf(x.code) === -1);
}
//# sourceMappingURL=index.js.map