import typescript from "@rollup/plugin-typescript";
import { nodeResolve } from "@rollup/plugin-node-resolve";
import replace from "@rollup/plugin-replace";
import { terser } from "rollup-plugin-terser";

/** @type {import('rollup').RollupOptions} */
const options = {
  input: "src/index.ts",
  output: {
    file: "dist/ApolloCodegenFrontend.bundle.js",
    format: "iife",
    name: "ApolloCodegenFrontend",
    sourcemap: true,
  },
  plugins: [
    typescript({
      tsconfig: "tsconfig.json",
    }),
    nodeResolve({
      modulesOnly: true,
      dedupe: ["graphql"],
    }),
    replace({
      "process.env.NODE_ENV": JSON.stringify("production"),
    }),
    terser({
      keep_classnames: true,
    }),
  ],
};

export default options;