module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  coveragePathIgnorePatterns: [
    '/node_modules/',
    '/tests/',
    '/__fixtures__/',
  ],
  globals: {
    'ts-jest': {
      tsConfig: "tsconfig.test.json",
    },
  },
  moduleDirectories: [
    'src',
    'node_modules',
  ],
};
