export const fs = require("fs");

export function withGlobalFS<T>(thunk: () => T): T {
  return thunk();
}
