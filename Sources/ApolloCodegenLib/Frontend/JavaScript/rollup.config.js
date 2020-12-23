import typescript from "@rollup/plugin-typescript";
import { nodeResolve } from "@rollup/plugin-node-resolve";
import replace from "@rollup/plugin-replace";
import { terser } from "rollup-plugin-terser";

export default {
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
      mainFields: ["module"],
    }),
    replace({
      "process.env.NODE_ENV": JSON.stringify("production"),
    }),
    terser({
      keep_classnames: true,
    }),
  ],
};
