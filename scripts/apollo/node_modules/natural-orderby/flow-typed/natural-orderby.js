type $npm$naturalOrderBy$CompareFn = (valueA: mixed, valueB: mixed) => number;

type $npm$naturalOrderBy$OrderEnum = 'asc' | 'desc';

type $npm$naturalOrderBy$Order =
  | $npm$naturalOrderBy$OrderEnum
  | $npm$naturalOrderBy$CompareFn;

type $npm$naturalOrderBy$CompareOptions = {|
  order?: $npm$naturalOrderBy$OrderEnum,
|};

type $npm$naturalOrderBy$IdentifierFn<T> = (value: T) => mixed;

type $npm$naturalOrderBy$Identifier<T> =
  | $npm$naturalOrderBy$IdentifierFn<T>
  | string;

declare module 'natural-orderby' {
  declare export function compare(
    options?: $npm$naturalOrderBy$CompareOptions
  ): $npm$naturalOrderBy$CompareFn;

  declare export function orderBy<T>(
    collection: $ReadOnlyArray<T>,
    identifiers?:
      | ?$ReadOnlyArray<$npm$naturalOrderBy$Identifier<T>>
      | ?$npm$naturalOrderBy$Identifier<T>,
    orders?:
      | ?$ReadOnlyArray<$npm$naturalOrderBy$Order>
      | ?$npm$naturalOrderBy$Order
  ): Array<T>;
}
