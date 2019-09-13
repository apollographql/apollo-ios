# 🌲 natural-orderby

> Lightweight (< 1.6kB gzipped) and performant natural sorting of arrays and collections by differentiating between unicode characters, numbers, dates, etc.

[![npm](https://img.shields.io/npm/v/natural-orderby.svg)](https://www.npmjs.com/package/natural-orderby)
[![Build Status](https://travis-ci.org/yobacca/natural-orderby.svg?branch=master)](https://travis-ci.org/yobacca/natural-orderby) [![codecov](https://codecov.io/gh/yobacca/natural-orderby/branch/master/graph/badge.svg)](https://codecov.io/gh/yobacca/natural-orderby) [![dependencies](https://david-dm.org/yobacca/natural-orderby.svg)](https://david-dm.org/yobacca/natural-orderby)

People sort strings containing numbers differently than most sorting algorithms, which sort values by comparing strings in Unicode code point order. This produces an ordering that is inconsistent with human logic.

`natural-orderby` sorts the primitive values of [`Boolean`](https://developer.mozilla.org/en-US/docs/Glossary/Boolean), [`Null`](https://developer.mozilla.org/en-US/docs/Glossary/Null), [`Undefined`](https://developer.mozilla.org/en-US/docs/Glossary/Undefined), [`Number`](https://developer.mozilla.org/en-US/docs/Glossary/Number) or [`String`](https://developer.mozilla.org/en-US/docs/Glossary/String) type as well as [`Date`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date) objects. When comparing strings it differentiates between unicode characters, integer, floating as well as hexadecimal numbers, various date formats, etc. You may sort flat or nested arrays or arrays of objects in a natural sorting order using `natural-orderby`.

In addition to the efficient and fast `orderBy()` method `natural-orderby` also provides the method `compare()`, which may be passed to [`Array.prototype.sort()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort).

## Contents

- [Getting Started](#getting-started)
- [Usage](#usage)
- [API Reference](#api-reference)
- [Flow Type Definitions](#flow-type-definitions)
- [Credits](#credits)
- [License](#license)

---

## Getting Started

```bash
# npm
npm install natural-orderby --save

# yarn
yarn add natural-orderby
```

If you´re not using a module bundler or package manager there´s also a global ("IIFE") build hosted on the unpkg CDN. Simply add the following `<script>` tag to the bottom of your HTML file:

```html
<script src="https://unpkg.com/natural-orderby/iife/natural-orderby.min.js"></script>
```

Once you've added `natural-orderby` you will have access to the global `window.naturalOrderBy` variable.

## Usage

<!-- prettier-ignore -->
```javascript
// Using ES modules
import { orderBy } from 'natural-orderby';

// Using CommonJS modules
// const { orderBy } = require('natural-orderby');

const users = [
  {
    username: 'Bamm-Bamm',
    ip: '192.168.5.2',
    datetime: 'Fri Jun 15 2018 16:48:00 GMT+0200 (CEST)'
  },
  {
    username: 'Wilma',
    ip: '192.168.10.1',
    datetime: '14 Jun 2018 00:00:00 PDT'
  },
  {
    username: 'Dino',
    ip: '192.168.0.2',
    datetime: 'June 15, 2018 14:48:00'
  },
  {
    username: 'Barney',
    ip: '192.168.1.1',
    datetime: 'Thu, 14 Jun 2018 07:00:00 GMT'
  },
  {
    username: 'Pebbles',
    ip: '192.168.1.21',
    datetime: '15 June 2018 14:48 UTC'
  },
  {
    username: 'Hoppy',
    ip: '192.168.5.10',
    datetime: '2018-06-15T14:48:00.000Z'
  },
];

const sortedUsers = orderBy(
  users,
  [v => v.datetime, v => v.ip],
  ['desc', 'asc']
);
```

This is the return value of `orderBy()`:

```javascript
[
  {
    username: 'Dino',
    ip: '192.168.0.2',
    datetime: 'June 15, 2018 14:48:00',
  },
  {
    username: 'Pebbles',
    ip: '192.168.1.21',
    datetime: '15 June 2018 14:48 UTC',
  },
  {
    username: 'Bamm-Bamm',
    ip: '192.168.5.2',
    datetime: 'Fri Jun 15 2018 16:48:00 GMT+0200 (CEST)',
  },
  {
    username: 'Hoppy',
    ip: '192.168.5.10',
    datetime: '2018-06-15T14:48:00.000Z',
  },
  {
    username: 'Barney',
    ip: '192.168.1.1',
    datetime: 'Thu, 14 Jun 2018 07:00:00 GMT',
  },
  {
    username: 'Wilma',
    ip: '192.168.10.1',
    datetime: '14 Jun 2018 00:00:00 PDT',
  },
];
```

## API Reference

### `orderBy()`

Creates an array of elements, natural sorted by specified `identifiers` and the corresponding sort `orders`. This method implements a stable sort algorithm, which means the original sort order of equal elements is preserved.
It also avoids the high overhead caused by [`Array.prototype.sort()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort) invoking a compare function multiple times per element within the array.

#### Syntax

<!-- prettier-ignore -->
```javascript
orderBy<T>(
  collection: Array<T>,
  identifiers?: ?Array<Identifier<T>> | ?Identifier<T>,
  orders?: ?Array<Order> | ?Order
): Array<T>
```

| Type            | Value                                                                            |
| :-------------- | :------------------------------------------------------------------------------- |
| `Identifier<T>` | <code>string &#124; (value: T) => mixed)</code>                                  |
| `Order`         | <code>'asc' &#124; 'desc' &#124; (valueA: mixed, valueB: mixed) => number</code> |

#### Description

`orderBy()` sorts the elements of an array by specified identifiers and the corresponding sort orders in a natural order and returns a new array containing the sorted elements.

If `collection` is an array of primitives, `identifiers` may be unspecified. Otherwise, you should specify `identifiers` to sort by or `collection` will be returned unsorted. An identifier can beexpressed by:

- an index position, if `collection` is a nested array,
- a property name, if `collection` is an array of objects,
- a function which returns a particular value from an element of a nested array or an array of objects. This function will be invoked by passing one element of `collection`.

If `orders` is unspecified, all values are sorted in ascending order. Otherwise, specify an order of `'desc'` for descending or `'asc'` for ascending sort order of corresponding values. You may also specify a compare function for an order, which will be invoked by two arguments: `(valueA, valueB)`. It must return a number representing the sort order.

> Note: `orderBy()` always returns a new array, even if the original was already sorted.

#### Examples

<!-- prettier-ignore -->
```javascript
import { orderBy } from 'natural-orderby';

// Simple numerics

orderBy(['10', 9, 2, '1', '4']);
// => ['1', 2, '4', 9, '10']


// Floats

orderBy(['10.0401', 10.022, 10.042, '10.021999']);
// => ['10.021999', 10.022, '10.0401', 10.042]


// Float & decimal notation

orderBy(['10.04f', '10.039F', '10.038d', '10.037D']);
// => ['10.037D', '10.038d', '10.039F', '10.04f']


// Scientific notation

orderBy(['1.528535047e5', '1.528535047e7', '1.528535047e3']);
// => ['1.528535047e3', '1.528535047e5', '1.528535047e7']


// IP addresses

orderBy(['192.168.201.100', '192.168.201.12', '192.168.21.1']);
// => ['192.168.21.1', '192.168.201.12', '192.168.21.100']


// Filenames

orderBy(['01asset_0815.png', 'asset_47103.jpg', 'asset_151.jpg', '001asset_4711.jpg', 'asset_342.mp4']);
// => ['001asset_4711.jpg', '01asset_0815.png', 'asset_151.jpg', 'asset_342.mp4', 'asset_47103.jpg']

// Filenames - ordered by extension and filename

orderBy(
    ['01asset_0815.png', 'asset_47103.jpg', 'asset_151.jpg', '001asset_4711.jpg', 'asset_342.mp4'],[v => v.split('.').pop(), v => v]
);
// => ['001asset_4711.jpg', 'asset_151.jpg', 'asset_47103.jpg', 'asset_342.mp4', '01asset_0815.png']


// Dates

orderBy(['10/12/2018', '10/11/2018', '10/11/2017', '10/12/2017']);
// => ['10/11/2017', '10/12/2017', '10/11/2018', '10/12/2018']

orderBy(['Thu, 15 Jun 2017 20:45:30 GMT', 'Thu, 3 May 2018 17:45:30 GMT', 'Thu, 15 Jun 2017 17:45:30 GMT']);
// => ['Thu, 15 Jun 2017 17:45:30 GMT', 'Thu, 15 Jun 2018 20:45:30 GMT', 'Thu, 3 May 2018 17:45:30 GMT']


// Money

orderBy(['$102.00', '$21.10', '$101.02', '$101.01']);
// => ['$21.10', '$101.01', '$101.02', '$102.00']


// Case-insensitive sort order

orderBy(['A', 'C', 'E', 'b', 'd', 'f']);
// => ['A', 'b', 'C', 'd', 'E', 'f']


// Default ascending sort order

orderBy(['a', 'c', 'f', 'd', 'e', 'b']);
// => ['a', 'b', 'c', 'd', 'e', 'f']


// Descending sort order

orderBy(['a', 'c', 'f', 'd', 'e', 'b'], null, ['desc']);
// => ['f', 'e', 'd', 'c', 'b', 'a']


// Custom compare function

orderBy([2, 1, 5, 8, 6, 9], null, [(valueA, valueB) => valueA - valueB]);
// => [1, 2, 5, 6, 8, 9]


// collections

const users = [
  {
    username: 'Bamm-Bamm',
    ip: '192.168.5.2',
    datetime: 'Fri Jun 15 2018 16:48:00 GMT+0200 (CEST)'
  },
  {
    username: 'Wilma',
    ip: '192.168.10.1',
    datetime: '14 Jun 2018 00:00:00 PDT'
  },
  {
    username: 'Dino',
    ip: '192.168.0.2',
    datetime: 'June 15, 2018 14:48:00'
  },
  {
    username: 'Barney',
    ip: '192.168.1.1',
    datetime: 'Thu, 14 Jun 2018 07:00:00 GMT'
  },
  {
    username: 'Pebbles',
    ip: '192.168.1.21',
    datetime: '15 June 2018 14:48 UTC'
  },
  {
    username: 'Hoppy',
    ip: '192.168.5.10',
    datetime: '2018-06-15T14:48:00.000Z'
  },
];

orderBy(
  users,
  [v => v.datetime, v => v.ip],
  ['desc', 'asc']
);
// => [
//      {
//        username: 'Dino',
//        ip: '192.168.0.2',
//        datetime: 'June 15, 2018 14:48:00',
//      },
//      {
//        username: 'Pebbles',
//        ip: '192.168.1.21',
//        datetime: '15 June 2018 14:48 UTC',
//      },
//      {
//        username: 'Bamm-Bamm',
//        ip: '192.168.5.2',
//        datetime: 'Fri Jun 15 2018 16:48:00 GMT+0200 (CEST)',
//      },
//      {
//        username: 'Hoppy',
//        ip: '192.168.5.10',
//        datetime: '2018-06-15T14:48:00.000Z',
//      },
//      {
//        username: 'Barney',
//        ip: '192.168.1.1',
//        datetime: 'Thu, 14 Jun 2018 07:00:00 GMT',
//      },
//      {
//        username: 'Wilma',
//        ip: '192.168.10.1',
//        datetime: '14 Jun 2018 00:00:00 PDT',
//      },
//    ]
```

### `compare()`

Creates a compare function that defines the natural sort order and which may be passed to [`Array.prototype.sort()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort).

#### Syntax

<!-- prettier-ignore -->
```javascript
compare(options?: CompareOptions): CompareFn
```

| Type             | Value                                                 |
| :--------------- | :---------------------------------------------------- |
| `CompareOptions` | <code>{ order?: 'asc' &#124; 'desc' }</code>          |
| `CompareFn`      | <code>(valueA: mixed, valueB: mixed) => number</code> |

#### Description

`compare()` returns a compare function that defines the natural sort order and which may be passed to [`Array.prototype.sort()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort).

If `options` or its property `order` is unspecified, values are sorted in ascending sort order. Otherwise, specify an order of `'desc'` for descending or `'asc'` for ascending sort order of values.

#### Examples

<!-- prettier-ignore -->
```javascript
import { compare } from 'natural-orderby';

// Simple numerics

['10', 9, 2, '1', '4'].sort(compare());
// => ['1', 2, '4', 9, '10']


// Floats

['10.0401', 10.022, 10.042, '10.021999'].sort(compare());
// => ['10.021999', 10.022, '10.0401', 10.042]


// Float & decimal notation

['10.04f', '10.039F', '10.038d', '10.037D'].sort(compare());
// => ['10.037D', '10.038d', '10.039F', '10.04f']


// Scientific notation

['1.528535047e5', '1.528535047e7', '1.528535047e3'].sort(compare());
// => ['1.528535047e3', '1.528535047e5', '1.528535047e7']


// IP addresses

['192.168.201.100', '192.168.201.12', '192.168.21.1'].sort(compare());
// => ['192.168.21.1', '192.168.201.12', '192.168.21.100']


// Filenames

['01asset_0815.jpg', 'asset_47103.jpg', 'asset_151.jpg', '001asset_4711.jpg', 'asset_342.mp4'].sort(compare());
// => ['001asset_4711.jpg', '01asset_0815.jpg', 'asset_151.jpg', 'asset_342.mp4', 'asset_47103.jpg']


// Dates

['10/12/2018', '10/11/2018', '10/11/2017', '10/12/2017'].sort(compare());
// => ['10/11/2017', '10/12/2017', '10/11/2018', '10/12/2018']

['Thu, 15 Jun 2017 20:45:30 GMT', 'Thu, 3 May 2018 17:45:30 GMT', 'Thu, 15 Jun 2017 17:45:30 GMT'].sort(compare());
// => ['Thu, 15 Jun 2017 17:45:30 GMT', 'Thu, 15 Jun 2018 20:45:30 GMT', 'Thu, 3 May 2018 17:45:30 GMT']


// Money

['$102.00', '$21.10', '$101.02', '$101.01'].sort(compare());
// => ['$21.10', '$101.01', '$101.02', '$102.00']


// Case-insensitive sort order

['A', 'C', 'E', 'b', 'd', 'f'].sort(compare());
// => ['A', 'b', 'C', 'd', 'E', 'f']


// Default ascending sort order

['a', 'c', 'f', 'd', 'e', 'b'].sort(compare());
// => ['a', 'b', 'c', 'd', 'e', 'f']


// Descending sort order

['a', 'c', 'f', 'd', 'e', 'b'].sort(compare({ order: 'desc' }));
// => ['f', 'e', 'd', 'c', 'b', 'a']


// collections

const users = [
  {
    username: 'Bamm-Bamm',
    lastLogin: {
      ip: '192.168.5.2',
      datetime: 'Fri Jun 15 2018 16:48:00 GMT+0200 (CEST)'
    },
  },
  {
    username: 'Wilma',
    lastLogin: {
      ip: '192.168.10.1',
      datetime: '14 Jun 2018 00:00:00 PDT'
    },
  },
  {
    username: 'Dino',
    lastLogin: {
      ip: '192.168.0.2',
      datetime: 'June 15, 2018 14:48:00'
    },
  },
  {
    username: 'Barney',
    lastLogin: {
      ip: '192.168.1.1',
      datetime: 'Thu, 14 Jun 2018 07:00:00 GMT'
    },
  },
  {
    username: 'Pebbles',
    lastLogin: {
      ip: '192.168.1.21',
      datetime: '15 June 2018 14:48 UTC'
    },
  },
  {
    username: 'Hoppy',
    lastLogin: {
      ip: '192.168.5.10',
      datetime: '2018-06-15T14:48:00.000Z'
    },
  },
];

users.sort((a, b) => compare()(a.lastLogin.ip, b.lastLogin.ip));
// => [
//      {
//        username: 'Dino',
//        lastLogin: {
//          ip: '192.168.0.2',
//          datetime: 'June 15, 2018 14:48:00'
//        },
//      },
//      {
//        username: 'Barney',
//        lastLogin: {
//          ip: '192.168.1.1',
//          datetime: 'Thu, 14 Jun 2018 07:00:00 GMT'
//        },
//      },
//      {
//        username: 'Pebbles',
//        lastLogin: {
//          ip: '192.168.1.21',
//          datetime: '15 June 2018 14:48 UTC'
//        },
//      },
//      {
//        username: 'Bamm-Bamm',
//        lastLogin: {
//          ip: '192.168.5.2',
//          datetime: 'Fri Jun 15 2018 16:48:00 GMT+0200 (CEST)'
//        },
//      },
//      {
//        username: 'Hoppy',
//        lastLogin: {
//          ip: '192.168.5.10',
//          datetime: '2018-06-15T14:48:00.000Z'
//        },
//      },
//      {
//        username: 'Wilma',
//        lastLogin: {
//          ip: '192.168.10.1',
//          datetime: '14 Jun 2018 00:00:00 PDT'
//        },
//      },
//    ]
```

## Flow Type Definitions

`natural-orderby` has first-class [Flow](https://flow.org/) support with zero configuration to assist you in finding type errors while using our modules.

## TypeScript Declarations

`natural-orderby` has also [TypeScript](https://www.typescriptlang.org/) support and provides TypeScript declarations.

## Credits

Inspired by [The Alphanum Algorithm](http://www.davekoelle.com/alphanum.html) from Dave Koelle.

## License

Licensed under the MIT License, Copyright © 2018 - present Olaf Ennen.

See [LICENSE](./LICENSE) for more information.
