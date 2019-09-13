export type Identifier<T> = number | string | ((value: T) => unknown);
export type Order<T> = 'asc' | 'desc' | ((valueA: T, valueB: T) => number);
export function orderBy<T>(collection: T[], identifiers?: Array<Identifier<T>> | Identifier<T>, orders?: Array<Order<T>> | Order<T>): T[];

export interface CompareOptions { order?: 'asc' | 'desc' }
export type CompareFn = ((valueA: unknown, valueB: unknown) => number);
export function compare(options?: CompareOptions): CompareFn;
