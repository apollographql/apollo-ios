"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const localfs_1 = require("apollo-codegen-core/lib/localfs");
const path_1 = __importDefault(require("path"));
const vscode_uri_1 = __importDefault(require("vscode-uri"));
const compiler_1 = require("apollo-codegen-core/lib/compiler");
const legacyIR_1 = require("apollo-codegen-core/lib/compiler/legacyIR");
const serializeToJSON_1 = __importDefault(require("apollo-codegen-core/lib/serializeToJSON"));
const apollo_codegen_swift_1 = require("apollo-codegen-swift");
const apollo_codegen_flow_1 = require("apollo-codegen-flow");
const apollo_codegen_typescript_1 = require("apollo-codegen-typescript");
const apollo_codegen_scala_1 = require("apollo-codegen-scala");
const validation_1 = require("apollo-language-server/lib/errors/validation");
const helpers_1 = require("apollo-codegen-typescript/lib/helpers");
function toPath(uri) {
    return vscode_uri_1.default.parse(uri).fsPath;
}
function generate(document, schema, outputPath, only, target, tagName, nextToSources, options) {
    let writtenFiles = 0;
    validation_1.validateQueryDocument(schema, document);
    const { rootPath = process.cwd() } = options;
    if (outputPath.split(".").length <= 1 && !localfs_1.fs.existsSync(outputPath)) {
        localfs_1.fs.mkdirSync(outputPath);
    }
    if (target === "swift") {
        options.addTypename = true;
        const context = compiler_1.compileToIR(schema, document, options);
        const outputIndividualFiles = localfs_1.fs.existsSync(outputPath) && localfs_1.fs.statSync(outputPath).isDirectory();
        const generator = apollo_codegen_swift_1.generateSource(context, outputIndividualFiles, only);
        if (outputIndividualFiles) {
            writeGeneratedFiles(generator.generatedFiles, outputPath, "\n");
            writtenFiles += Object.keys(generator.generatedFiles).length;
        }
        else {
            localfs_1.fs.writeFileSync(outputPath, generator.output.concat("\n"));
            writtenFiles += 1;
        }
        if (options.generateOperationIds) {
            writeOperationIdsMap(context);
            writtenFiles += 1;
        }
    }
    else if (target === "flow") {
        const context = compiler_1.compileToIR(schema, document, options);
        const { generatedFiles, common } = apollo_codegen_flow_1.generateSource(context);
        const outFiles = {};
        if (nextToSources) {
            generatedFiles.forEach(({ sourcePath, fileName, content }) => {
                const dir = path_1.default.join(path_1.default.dirname(path_1.default.posix.relative(rootPath, toPath(sourcePath))), outputPath);
                if (!localfs_1.fs.existsSync(dir)) {
                    localfs_1.fs.mkdirSync(dir);
                }
                outFiles[path_1.default.join(dir, fileName)] = {
                    output: content.fileContents + common
                };
            });
            writeGeneratedFiles(outFiles, path_1.default.resolve("."));
            writtenFiles += Object.keys(outFiles).length;
        }
        else if (localfs_1.fs.existsSync(outputPath) &&
            localfs_1.fs.statSync(outputPath).isDirectory()) {
            generatedFiles.forEach(({ fileName, content }) => {
                outFiles[fileName] = {
                    output: content.fileContents + common
                };
            });
            writeGeneratedFiles(outFiles, outputPath);
            writtenFiles += Object.keys(outFiles).length;
        }
        else {
            localfs_1.fs.writeFileSync(outputPath, generatedFiles.map(o => o.content.fileContents).join("\n") + common);
            writtenFiles += 1;
        }
    }
    else if (target === "typescript" || target === "ts") {
        const context = compiler_1.compileToIR(schema, document, options);
        const generatedFiles = apollo_codegen_typescript_1.generateLocalSource(context);
        const generatedGlobalFile = apollo_codegen_typescript_1.generateGlobalSource(context);
        const outFiles = {};
        if (nextToSources ||
            (localfs_1.fs.existsSync(outputPath) && localfs_1.fs.statSync(outputPath).isDirectory())) {
            if (options.globalTypesFile) {
                const globalTypesDir = path_1.default.dirname(options.globalTypesFile);
                if (!localfs_1.fs.existsSync(globalTypesDir)) {
                    localfs_1.fs.mkdirSync(globalTypesDir);
                }
            }
            else if (nextToSources && !localfs_1.fs.existsSync(outputPath)) {
                localfs_1.fs.mkdirSync(outputPath);
            }
            const globalSourcePath = options.globalTypesFile ||
                path_1.default.join(outputPath, `globalTypes.${options.tsFileExtension ||
                    helpers_1.DEFAULT_FILE_EXTENSION}`);
            outFiles[globalSourcePath] = {
                output: generatedGlobalFile.fileContents
            };
            generatedFiles.forEach(({ sourcePath, fileName, content }) => {
                let dir = outputPath;
                if (nextToSources) {
                    dir = path_1.default.join(path_1.default.dirname(path_1.default.relative(rootPath, toPath(sourcePath))), dir);
                    if (!localfs_1.fs.existsSync(dir)) {
                        localfs_1.fs.mkdirSync(dir);
                    }
                }
                const outFilePath = path_1.default.join(dir, fileName);
                outFiles[outFilePath] = {
                    output: content({ outputPath: outFilePath, globalSourcePath })
                        .fileContents
                };
            });
            writeGeneratedFiles(outFiles, path_1.default.resolve("."));
            writtenFiles += Object.keys(outFiles).length;
        }
        else {
            localfs_1.fs.writeFileSync(outputPath, generatedFiles.map(o => o.content().fileContents).join("\n") +
                "\n" +
                generatedGlobalFile.fileContents);
            writtenFiles += 1;
        }
    }
    else {
        let output;
        const context = legacyIR_1.compileToLegacyIR(schema, document, options);
        switch (target) {
            case "json":
                output = serializeToJSON_1.default(context);
                break;
            case "scala":
                output = apollo_codegen_scala_1.generateSource(context);
        }
        if (outputPath) {
            localfs_1.fs.writeFileSync(outputPath, output);
            writtenFiles += 1;
        }
        else {
            console.log(output);
        }
    }
    return writtenFiles;
}
exports.default = generate;
function writeGeneratedFiles(generatedFiles, outputDirectory, terminator = "") {
    for (const [fileName, generatedFile] of Object.entries(generatedFiles)) {
        localfs_1.fs.writeFileSync(path_1.default.join(outputDirectory, fileName), generatedFile.output.concat(terminator));
    }
}
function writeOperationIdsMap(context) {
    let operationIdsMap = {};
    Object.keys(context.operations)
        .map(k => context.operations[k])
        .forEach(operation => {
        operationIdsMap[operation.operationId] = {
            name: operation.operationName,
            source: operation.source
        };
    });
    localfs_1.fs.writeFileSync(context.options.operationIdsPath, JSON.stringify(operationIdsMap, null, 2));
}
//# sourceMappingURL=generate.js.map