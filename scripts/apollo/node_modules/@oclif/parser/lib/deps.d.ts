declare const _default: () => {
    add<T, K extends string, U>(this: T, name: K, fn: () => U): T & { [P in K]: U; };
};
export default _default;
