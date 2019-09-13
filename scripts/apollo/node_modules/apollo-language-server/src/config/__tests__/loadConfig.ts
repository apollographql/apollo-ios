import { loadConfig } from "../";
import * as path from "path";
import * as fs from "fs";
import {
  DefaultClientConfig,
  DefaultServiceConfig,
  DefaultEngineConfig
} from "../config";

const makeNestedDir = dir => {
  if (fs.existsSync(dir)) return;

  try {
    fs.mkdirSync(dir);
  } catch (err) {
    if (err.code == "ENOENT") {
      makeNestedDir(path.dirname(dir)); //create parent dir
      makeNestedDir(dir); //create dir
    }
  }
};

const deleteFolderRecursive = path => {
  // don't delete files on azure CI
  if (process.env.AZURE_HTTP_USER_AGENT) return;

  if (fs.existsSync(path)) {
    fs.readdirSync(path).forEach(function(file, index) {
      var curPath = path + "/" + file;
      if (fs.lstatSync(curPath).isDirectory()) {
        // recurse
        deleteFolderRecursive(curPath);
      } else {
        // delete file
        fs.unlinkSync(curPath);
      }
    });
    fs.rmdirSync(path);
  }
};

const writeFilesToDir = (dir: string, files: Record<string, string>) => {
  Object.keys(files).forEach(key => {
    if (key.includes("/")) makeNestedDir(path.dirname(key));
    fs.writeFileSync(`${dir}/${key}`, files[key]);
  });
};

describe("loadConfig", () => {
  let dir, dirPath;

  // set up a temp dir
  beforeEach(() => {
    dir = fs.mkdtempSync("__tmp__");
    dirPath = `${process.cwd()}/${dir}`;
  });

  // clean up our temp dir
  afterEach(() => {
    if (dir) deleteFolderRecursive(dir);
    dir = dirPath = undefined;
  });

  describe("finding files", () => {
    it("loads with client defaults from different dir", async () => {
      writeFilesToDir(dir, {
        "my.config.js": `
          module.exports = {
            client: {
              service: 'hello'
            }
          }
        `
      });

      const config = await loadConfig({
        configPath: dirPath,
        configFileName: "my.config.js"
      });
      expect(config.rawConfig).toMatchInlineSnapshot(`
        Object {
          "client": Object {
            "addTypename": true,
            "clientOnlyDirectives": Array [
              "connection",
              "type",
            ],
            "clientSchemaDirectives": Array [
              "client",
              "rest",
            ],
            "excludes": Array [
              "**/node_modules",
              "**/__tests__",
            ],
            "includes": Array [
              "src/**/*.{ts,tsx,js,jsx,graphql,gql}",
            ],
            "service": "hello",
            "statsWindow": Object {
              "from": -86400,
              "to": -0,
            },
            "tagName": "gql",
          },
          "engine": Object {
            "endpoint": "https://engine-graphql.apollographql.com/api/graphql",
            "frontend": "https://engine.apollographql.com",
          },
        }
      `);
    });

    it("loads with service defaults from different dir", async () => {
      writeFilesToDir(dir, {
        "my.config.js": `
          module.exports = {
            service: {
              name: 'hello'
            }
          }
        `
      });

      const config = await loadConfig({
        configPath: dirPath,
        configFileName: "my.config.js"
      });
      expect(config.rawConfig).toMatchInlineSnapshot(`
        Object {
          "engine": Object {
            "endpoint": "https://engine-graphql.apollographql.com/api/graphql",
            "frontend": "https://engine.apollographql.com",
          },
          "service": Object {
            "endpoint": Object {
              "url": "http://localhost:4000/graphql",
            },
            "excludes": Array [
              "**/node_modules",
              "**/__tests__",
            ],
            "includes": Array [
              "src/**/*.{ts,tsx,js,jsx,graphql,gql}",
            ],
            "name": "hello",
          },
        }
      `);
    });

    it("[deprecated] loads config from package.json", async () => {
      writeFilesToDir(dir, {
        "package.json": `{"apollo":{"client": {"service": "hello"}} }`
      });

      // silence the warning
      const spy = jest.spyOn(console, "warn");
      spy.mockImplementationOnce(() => {});

      const config = await loadConfig({ configPath: dirPath });

      spy.mockRestore();
      expect(config.client.service).toEqual("hello");
    });

    it("loads config from a ts file", async () => {
      writeFilesToDir(dir, {
        "apollo.config.ts": `module.exports = {"client": {"service": "hello"}`
      });
      const config = await loadConfig({ configPath: dirPath });

      expect(config.client.service).toEqual("hello");
    });
  });

  describe("errors", () => {
    it("throws when config file is empty", async () => {
      writeFilesToDir(dir, { "my.config.js": `` });

      const spy = jest.spyOn(console, "error");
      // use this to keep the log quiet
      spy.mockImplementation();

      await loadConfig({
        configPath: dirPath,
        configFileName: "my.config.js"
      });

      expect(spy).toHaveBeenCalledWith(
        expect.stringMatching(/config file failed to load/i)
      );

      spy.mockRestore();
    });

    it("throws when explorer.search fails", async () => {
      writeFilesToDir(dir, { "my.config.js": `* 98375^%*&^ its lit` });

      const spy = jest.spyOn(console, "error");
      // use this to keep the log quiet
      spy.mockImplementation();

      await loadConfig({
        configPath: dirPath,
        configFileName: "my.config.js"
      });

      expect(spy).toHaveBeenCalledWith(
        expect.stringMatching(/config file failed to load/i)
      );

      spy.mockRestore();
    });

    it("issues a deprecation warning when loading config from package.json", async () => {
      const spy = jest.spyOn(console, "warn");
      spy.mockImplementation();

      writeFilesToDir(dir, {
        "package.json": `{"apollo":{"client": {"service": "hello"}} }`
      });

      await loadConfig({
        configPath: dirPath,
        configFileName: "package.json"
      });

      expect(spy).toHaveBeenCalledWith(
        expect.stringMatching(/The "apollo" package.json configuration/i)
      );

      spy.mockRestore();
    });

    it("throws if a config file was expected but not found", async () => {
      const spy = jest.spyOn(console, "error");
      spy.mockImplementation();

      writeFilesToDir(dir, { "my.config.js": `module.exports = {}` });

      await loadConfig({
        configFileName: "my.TYPO.js",
        requireConfig: true // this is what we're testing
      });

      expect(spy).toHaveBeenCalledWith(
        expect.stringMatching(/no apollo config/i)
      );
      spy.mockRestore();
    });

    it("throws if project type cant be resolved", async () => {
      const spy = jest.spyOn(console, "error");
      spy.mockImplementation();

      writeFilesToDir(dir, {
        "my.config.js": `module.exports = {}`
      });

      await loadConfig({
        configPath: dirPath,
        configFileName: "my.config.js"
      });

      expect(spy).toHaveBeenCalledWith(
        expect.stringMatching(/unable to resolve/i)
      );
      spy.mockRestore();
    });
  });

  describe("env loading", () => {
    it("finds .env in config path & parses for key", async () => {
      writeFilesToDir(dir, {
        "my.config.js": `module.exports = { client: { name: 'hello' } }`,
        ".env": `ENGINE_API_KEY=service:harambe:54378950jn`
      });

      const config = await loadConfig({
        configPath: dirPath,
        configFileName: "my.config.js"
      });

      expect(config.client.service).toEqual("harambe");
    });

    // this doesn't work right now :)
    xit("finds .env in cwd & parses for key", async () => {
      writeFilesToDir(dir, {
        "dir/my.config.js": `module.exports = { client: { name: 'hello' } }`,
        ".env": `ENGINE_API_KEY=service:harambe:54378950jn`
      });
      process.chdir(dir);
      const config = await loadConfig({
        configPath: "dir/",
        configFileName: "my.config.js"
      });

      process.chdir("../");
      expect(config.client.service).toEqual("harambe");
    });
  });

  describe("project type", () => {
    it("uses passed in type when config doesnt have client/service", async () => {
      writeFilesToDir(dir, {
        "my.config.js": `module.exports = { engine: { endpoint: 'http://a.a' } }`
      });

      const config = await loadConfig({
        configPath: dirPath,
        configFileName: "my.config.js",
        type: "client"
      });

      expect(config.isClient).toEqual(true);
    });

    it("infers client projects from config", async () => {
      writeFilesToDir(dir, {
        "my.config.js": `module.exports = { client: { service: 'hello' } }`
      });

      const config = await loadConfig({
        configPath: dirPath,
        configFileName: "my.config.js"
      });

      expect(config.isClient).toEqual(true);
    });

    it("infers service projects from config", async () => {
      writeFilesToDir(dir, {
        "my.config.js": `module.exports = { service: 'wow' }`
      });

      const config = await loadConfig({
        configPath: dirPath,
        configFileName: "my.config.js"
      });

      expect(config.isService).toEqual(true);
    });
  });

  describe("service name", () => {
    it("lets config service name take precedence for client project", async () => {
      writeFilesToDir(dir, {
        "my.config.js": `module.exports = { client: { service: 'hello' } }`,
        ".env": `ENGINE_API_KEY=service:harambe:54378950jn`
      });

      const config = await loadConfig({
        configPath: dirPath,
        configFileName: "my.config.js",
        name: "not-it"
      });

      expect(config.client.service).toEqual("hello");
    });

    it("lets name passed in take precedence over env var", async () => {
      writeFilesToDir(dir, {
        "my.config.js": `module.exports = { client: {  } }`,
        ".env": `ENGINE_API_KEY=service:harambe:54378950jn`
      });

      const config = await loadConfig({
        configPath: dirPath,
        configFileName: "my.config.js",
        name: "hello"
      });

      expect(config.client.service).toEqual("hello");
    });

    it("uses env var to determine service name when no other options", async () => {
      writeFilesToDir(dir, {
        "my.config.js": `module.exports = { client: {  } }`,
        ".env": `ENGINE_API_KEY=service:harambe:54378950jn`
      });

      const config = await loadConfig({
        configPath: dirPath,
        configFileName: "my.config.js"
      });

      expect(config.client.service).toEqual("harambe");
    });
  });

  describe("default merging", () => {
    it("merges service name and default config for client projects", async () => {
      writeFilesToDir(dir, {
        "my.config.js": `module.exports = { client: { service: 'hello' } }`
      });

      const config = await loadConfig({
        configPath: dirPath,
        configFileName: "my.config.js"
      });

      expect(config.rawConfig.client.includes).toEqual(
        DefaultClientConfig.includes
      );
    });

    it("merges service name and default config for service projects", async () => {
      writeFilesToDir(dir, {
        "my.config.js": `module.exports = { service: { name: 'wow' } }`
      });

      const config = await loadConfig({
        configPath: dirPath,
        configFileName: "my.config.js"
      });

      expect(config.rawConfig.service.includes).toEqual(
        DefaultServiceConfig.includes
      );
    });

    it("merges engine config defaults", async () => {
      writeFilesToDir(dir, {
        "my.config.js": `module.exports = { client: { service: 'wow' } }`
      });

      const config = await loadConfig({
        configPath: dirPath,
        configFileName: "my.config.js"
      });

      expect(config.rawConfig.engine.endpoint).toEqual(
        DefaultEngineConfig.endpoint
      );
    });
  });
});
