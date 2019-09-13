var compareNumbers = function compareNumbers(numberA, numberB) {
  if (numberA < numberB) {
    return -1;
  }

  if (numberA > numberB) {
    return 1;
  }

  return 0;
};

var RE_NUMBERS = /(^0x[\da-fA-F]+$|^([+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?(?!\.\d+)(?=\D|\s|$))|\d+)/g;
var RE_LEADING_OR_TRAILING_WHITESPACES = /^\s+|\s+$/g; // trim pre-post whitespace

var RE_WHITESPACES = /\s+/g; // normalize all whitespace to single ' ' character

var RE_INT_OR_FLOAT = /^[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?$/; // identify integers and floats

var RE_DATE = /(^([\w ]+,?[\w ]+)?[\w ]+,?[\w ]+\d+:\d+(:\d+)?[\w ]?|^\d{1,4}[/-]\d{1,4}[/-]\d{1,4}|^\w+, \w+ \d+, \d{4})/; // identify date strings

var RE_LEADING_ZERO = /^0+[1-9]{1}[0-9]*$/;
var RE_UNICODE_CHARACTERS = /[^\x00-\x80]/;

var compareUnicode = function compareUnicode(stringA, stringB) {
  var result = stringA.localeCompare(stringB);
  return result ? result / Math.abs(result) : 0;
};

var stringCompare = function stringCompare(stringA, stringB) {
  if (stringA < stringB) {
    return -1;
  }

  if (stringA > stringB) {
    return 1;
  }

  return 0;
};

var compareChunks = function compareChunks(chunksA, chunksB) {
  var lengthA = chunksA.length;
  var lengthB = chunksB.length;
  var size = Math.min(lengthA, lengthB);

  for (var i = 0; i < size; i++) {
    var chunkA = chunksA[i];
    var chunkB = chunksB[i];

    if (chunkA.normalizedString !== chunkB.normalizedString) {
      if (chunkA.normalizedString === '' !== (chunkB.normalizedString === '')) {
        // empty strings have lowest value
        return chunkA.normalizedString === '' ? -1 : 1;
      }

      if (chunkA.parsedNumber !== undefined && chunkB.parsedNumber !== undefined) {
        // compare numbers
        var result = compareNumbers(chunkA.parsedNumber, chunkB.parsedNumber);

        if (result === 0) {
          // compare string value, if parsed numbers are equal
          // Example:
          // chunkA = { parsedNumber: 1, normalizedString: "001" }
          // chunkB = { parsedNumber: 1, normalizedString: "01" }
          // chunkA.parsedNumber === chunkB.parsedNumber
          // chunkA.normalizedString < chunkB.normalizedString
          return stringCompare(chunkA.normalizedString, chunkB.normalizedString);
        }

        return result;
      } else if (chunkA.parsedNumber !== undefined || chunkB.parsedNumber !== undefined) {
        // number < string
        return chunkA.parsedNumber !== undefined ? -1 : 1;
      } else if (RE_UNICODE_CHARACTERS.test(chunkA.normalizedString + chunkB.normalizedString) && chunkA.normalizedString.localeCompare) {
        // use locale comparison only if one of the chunks contains unicode characters
        return compareUnicode(chunkA.normalizedString, chunkB.normalizedString);
      } else {
        // use common string comparison for performance reason
        return stringCompare(chunkA.normalizedString, chunkB.normalizedString);
      }
    }
  } // if the chunks are equal so far, the one which has more chunks is greater than the other one


  if (lengthA > size || lengthB > size) {
    return lengthA <= size ? -1 : 1;
  }

  return 0;
};

var compareOtherTypes = function compareOtherTypes(valueA, valueB) {
  if (!valueA.chunks ? valueB.chunks : !valueB.chunks) {
    return !valueA.chunks ? 1 : -1;
  }

  if (valueA.isNaN ? !valueB.isNaN : valueB.isNaN) {
    return valueA.isNaN ? -1 : 1;
  }

  if (valueA.isSymbol ? !valueB.isSymbol : valueB.isSymbol) {
    return valueA.isSymbol ? -1 : 1;
  }

  if (valueA.isObject ? !valueB.isObject : valueB.isObject) {
    return valueA.isObject ? -1 : 1;
  }

  if (valueA.isArray ? !valueB.isArray : valueB.isArray) {
    return valueA.isArray ? -1 : 1;
  }

  if (valueA.isFunction ? !valueB.isFunction : valueB.isFunction) {
    return valueA.isFunction ? -1 : 1;
  }

  if (valueA.isNull ? !valueB.isNull : valueB.isNull) {
    return valueA.isNull ? -1 : 1;
  }

  return 0;
};

var compareValues = function compareValues(valueA, valueB) {
  if (valueA.value === valueB.value) {
    return 0;
  }

  if (valueA.parsedNumber !== undefined && valueB.parsedNumber !== undefined) {
    return compareNumbers(valueA.parsedNumber, valueB.parsedNumber);
  }

  if (valueA.chunks && valueB.chunks) {
    return compareChunks(valueA.chunks, valueB.chunks);
  }

  return compareOtherTypes(valueA, valueB);
};

var compareMultiple = function compareMultiple(recordA, recordB, orders) {
  var indexA = recordA.index,
      valuesA = recordA.values;
  var indexB = recordB.index,
      valuesB = recordB.values;
  var length = valuesA.length;
  var ordersLength = orders.length;

  for (var i = 0; i < length; i++) {
    var order = i < ordersLength ? orders[i] : null;

    if (order && typeof order === 'function') {
      var result = order(valuesA[i].value, valuesB[i].value);

      if (result) {
        return result;
      }
    } else {
      var _result = compareValues(valuesA[i], valuesB[i]);

      if (_result) {
        return _result * (order === 'desc' ? -1 : 1);
      }
    }
  }

  return indexA - indexB;
};

var createIdentifierFn = function createIdentifierFn(identifier) {
  if (typeof identifier === 'function') {
    // identifier is already a lookup function
    return identifier;
  }

  return function (value) {
    if (Array.isArray(value)) {
      var index = Number(identifier);

      if (Number.isInteger(index)) {
        return value[index];
      }
    } else if (value && typeof value === 'object' && typeof identifier !== 'function') {
      return value[identifier];
    }

    return value;
  };
};

var stringify = function stringify(value) {
  if (typeof value === 'boolean' || value instanceof Boolean) {
    return Number(value).toString();
  }

  if (typeof value === 'number' || value instanceof Number) {
    return value.toString();
  }

  if (value instanceof Date) {
    return value.getTime().toString();
  }

  if (typeof value === 'string' || value instanceof String) {
    return value.toLowerCase().replace(RE_LEADING_OR_TRAILING_WHITESPACES, '');
  }

  return '';
};

var parseNumber = function parseNumber(value) {
  if (value.length !== 0) {
    var parsedNumber = Number(value);

    if (!Number.isNaN(parsedNumber)) {
      return parsedNumber;
    }
  }

  return undefined;
};

var parseDate = function parseDate(value) {
  if (RE_DATE.test(value)) {
    var parsedDate = Date.parse(value);

    if (!Number.isNaN(parsedDate)) {
      return parsedDate;
    }
  }

  return undefined;
};

var numberify = function numberify(value) {
  var parsedNumber = parseNumber(value);

  if (parsedNumber !== undefined) {
    return parsedNumber;
  }

  return parseDate(value);
};

var createChunks = function createChunks(value) {
  return value.replace(RE_NUMBERS, '\0$1\0').replace(/\0$/, '').replace(/^\0/, '').split('\0');
};

var normalizeAlphaChunk = function normalizeAlphaChunk(chunk) {
  return chunk.replace(RE_WHITESPACES, ' ').replace(RE_LEADING_OR_TRAILING_WHITESPACES, '');
};

var normalizeNumericChunk = function normalizeNumericChunk(chunk, index, chunks) {
  if (RE_INT_OR_FLOAT.test(chunk)) {
    // don´t parse a number, if there´s a preceding decimal point
    // to keep significance
    // e.g. 1.0020, 1.020
    if (!RE_LEADING_ZERO.test(chunk) || index === 0 || chunks[index - 1] !== '.') {
      return parseNumber(chunk) || 0;
    }
  }

  return undefined;
};

var createChunkMap = function createChunkMap(chunk, index, chunks) {
  return {
    parsedNumber: normalizeNumericChunk(chunk, index, chunks),
    normalizedString: normalizeAlphaChunk(chunk)
  };
};

var createChunkMaps = function createChunkMaps(value) {
  var chunksMaps = createChunks(value).map(createChunkMap);
  return chunksMaps;
};

var isFunction = function isFunction(value) {
  return typeof value === 'function';
};

var isNaN = function isNaN(value) {
  return Number.isNaN(value) || value instanceof Number && Number.isNaN(value.valueOf());
};

var isNull = function isNull(value) {
  return value === null;
};

var isObject = function isObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value) && !(value instanceof Number) && !(value instanceof String) && !(value instanceof Boolean) && !(value instanceof Date);
};

var isSymbol = function isSymbol(value) {
  return typeof value === 'symbol';
};

var isUndefined = function isUndefined(value) {
  return value === undefined;
};

var getMappedValueRecord = function getMappedValueRecord(value) {
  if (typeof value === 'string' || value instanceof String || (typeof value === 'number' || value instanceof Number) && !isNaN(value) || typeof value === 'boolean' || value instanceof Boolean || value instanceof Date) {
    var stringValue = stringify(value);
    var parsedNumber = numberify(stringValue);
    var chunks = createChunkMaps(parsedNumber ? "" + parsedNumber : stringValue);
    return {
      parsedNumber: parsedNumber,
      chunks: chunks,
      value: value
    };
  }

  return {
    isArray: Array.isArray(value),
    isFunction: isFunction(value),
    isNaN: isNaN(value),
    isNull: isNull(value),
    isObject: isObject(value),
    isSymbol: isSymbol(value),
    isUndefined: isUndefined(value),
    value: value
  };
};

var getValueByIdentifier = function getValueByIdentifier(value, getValue) {
  return getValue(value);
};

var getElementByIndex = function getElementByIndex(collection, index) {
  return collection[index];
};

var baseOrderBy = function baseOrderBy(collection, identifiers, orders) {
  var identifierFns = identifiers.length ? identifiers.map(createIdentifierFn) : [function (value) {
    return value;
  }]; // temporary array holds elements with position and sort-values

  var mappedCollection = collection.map(function (element, index) {
    var values = identifierFns.map(function (identifier) {
      return getValueByIdentifier(element, identifier);
    }).map(getMappedValueRecord);
    return {
      index: index,
      values: values
    };
  }); // iterate over values and compare values until a != b or last value reached

  mappedCollection.sort(function (recordA, recordB) {
    return compareMultiple(recordA, recordB, orders);
  });
  return mappedCollection.map(function (element) {
    return getElementByIndex(collection, element.index);
  });
};

var getIdentifiers = function getIdentifiers(identifiers) {
  if (!identifiers) {
    return [];
  }

  var identifierList = !Array.isArray(identifiers) ? [identifiers] : [].concat(identifiers);

  if (identifierList.some(function (identifier) {
    return typeof identifier !== 'string' && typeof identifier !== 'number' && typeof identifier !== 'function';
  })) {
    return [];
  }

  return identifierList;
};

var getOrders = function getOrders(orders) {
  if (!orders) {
    return [];
  }

  var orderList = !Array.isArray(orders) ? [orders] : [].concat(orders);

  if (orderList.some(function (order) {
    return order !== 'asc' && order !== 'desc' && typeof order !== 'function';
  })) {
    return [];
  }

  return orderList;
};

/**
 * Creates an array of elements, natural sorted by specified identifiers and
 * the corresponding sort orders. This method implements a stable sort
 * algorithm, which means the original sort order of equal elements is
 * preserved.
 *
 * If `collection` is an array of primitives, `identifiers` may be unspecified.
 * Otherwise, you should specify `identifiers` to sort by or `collection` will
 * be returned unsorted. An identifier can expressed by:
 *
 * - an index position, if `collection` is a nested array,
 * - a property name, if `collection` is an array of objects,
 * - a function which returns a particular value from an element of a nested array or an array of objects. This function will be invoked by passing one element of `collection`.
 *
 * If `orders` is unspecified, all values are sorted in ascending order.
 * Otherwise, specify an order of `'desc'` for descending or `'asc'` for
 * ascending sort order of corresponding values. You may also specify a compare
 * function for an order, which will be invoked by two arguments:
 * `(valueA, valueB)`. It must return a number representing the sort order.
 *
 * @example
 *
 * import { orderBy } from 'natural-orderby';
 *
 * const users = [
 *   {
 *     username: 'Bamm-Bamm',
 *     ip: '192.168.5.2',
 *     datetime: 'Fri Jun 15 2018 16:48:00 GMT+0200 (CEST)'
 *   },
 *   {
 *     username: 'Wilma',
 *     ip: '192.168.10.1',
 *     datetime: '14 Jun 2018 00:00:00 PDT'
 *   },
 *   {
 *     username: 'dino',
 *     ip: '192.168.0.2',
 *     datetime: 'June 15, 2018 14:48:00'
 *   },
 *   {
 *     username: 'Barney',
 *     ip: '192.168.1.1',
 *     datetime: 'Thu, 14 Jun 2018 07:00:00 GMT'
 *   },
 *   {
 *     username: 'Pebbles',
 *     ip: '192.168.1.21',
 *     datetime: '15 June 2018 14:48 UTC'
 *   },
 *   {
 *     username: 'Hoppy',
 *     ip: '192.168.5.10',
 *     datetime: '2018-06-15T14:48:00.000Z'
 *   },
 * ];
 *
 * orderBy(
 *   users,
 *   [v => v.datetime, v => v.ip],
 *   ['desc', 'asc']
 * );
 *
 * // => [
 * //      {
 * //        username: 'dino',
 * //        ip: '192.168.0.2',
 * //        datetime: 'June 15, 2018 14:48:00',
 * //      },
 * //      {
 * //        username: 'Pebbles',
 * //        ip: '192.168.1.21',
 * //        datetime: '15 June 2018 14:48 UTC',
 * //      },
 * //      {
 * //        username: 'Bamm-Bamm',
 * //        ip: '192.168.5.2',
 * //        datetime: 'Fri Jun 15 2018 16:48:00 GMT+0200 (CEST)',
 * //      },
 * //      {
 * //        username: 'Hoppy',
 * //        ip: '192.168.5.10',
 * //        datetime: '2018-06-15T14:48:00.000Z',
 * //      },
 * //      {
 * //        username: 'Barney',
 * //        ip: '192.168.1.1',
 * //        datetime: 'Thu, 14 Jun 2018 07:00:00 GMT',
 * //      },
 * //      {
 * //        username: 'Wilma',
 * //        ip: '192.168.10.1',
 * //        datetime: '14 Jun 2018 00:00:00 PDT',
 * //      },
 * //    ]
 */
function orderBy(collection, identifiers, orders) {
  if (!collection || !Array.isArray(collection)) {
    return [];
  }

  var validatedIdentifiers = getIdentifiers(identifiers);
  var validatedOrders = getOrders(orders);
  return baseOrderBy(collection, validatedIdentifiers, validatedOrders);
}

var baseCompare = function baseCompare(options) {
  return function (valueA, valueB) {
    var a = getMappedValueRecord(valueA);
    var b = getMappedValueRecord(valueB);
    var result = compareValues(a, b);
    return result * (options.order === 'desc' ? -1 : 1);
  };
};

var isValidOrder = function isValidOrder(value) {
  return typeof value === 'string' && (value === 'asc' || value === 'desc');
};

var getOptions = function getOptions(customOptions) {
  var order = 'asc';

  if (typeof customOptions === 'string' && isValidOrder(customOptions)) {
    order = customOptions;
  } else if (customOptions && typeof customOptions === 'object' && customOptions.order && isValidOrder(customOptions.order)) {
    order = customOptions.order;
  }

  return {
    order: order
  };
};

/**
 * Creates a compare function that defines the natural sort order considering
 * the given `options` which may be passed to [`Array.prototype.sort()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort).
 *
 * If `options` or its property `order` is unspecified, values are sorted in
 * ascending sort order. Otherwise, specify an order of `'desc'` for descending
 * or `'asc'` for ascending sort order of values.
 *
 * @example
 *
 * import { compare } from 'natural-orderby';
 *
 * const users = [
 *   {
 *     username: 'Bamm-Bamm',
 *     lastLogin: {
 *       ip: '192.168.5.2',
 *       datetime: 'Fri Jun 15 2018 16:48:00 GMT+0200 (CEST)'
 *     },
 *   },
 *   {
 *     username: 'Wilma',
 *     lastLogin: {
 *       ip: '192.168.10.1',
 *       datetime: '14 Jun 2018 00:00:00 PDT'
 *     },
 *   },
 *   {
 *     username: 'dino',
 *     lastLogin: {
 *       ip: '192.168.0.2',
 *       datetime: 'June 15, 2018 14:48:00'
 *     },
 *   },
 *   {
 *     username: 'Barney',
 *     lastLogin: {
 *       ip: '192.168.1.1',
 *       datetime: 'Thu, 14 Jun 2018 07:00:00 GMT'
 *     },
 *   },
 *   {
 *     username: 'Pebbles',
 *     lastLogin: {
 *       ip: '192.168.1.21',
 *       datetime: '15 June 2018 14:48 UTC'
 *     },
 *   },
 *   {
 *     username: 'Hoppy',
 *     lastLogin: {
 *       ip: '192.168.5.10',
 *       datetime: '2018-06-15T14:48:00.000Z'
 *     },
 *   },
 * ];
 *
 * users.sort((a, b) => compare()(a.ip, b.ip));
 *
 * // => [
 * //      {
 * //        username: 'dino',
 * //        ip: '192.168.0.2',
 * //        datetime: 'June 15, 2018 14:48:00'
 * //      },
 * //      {
 * //        username: 'Barney',
 * //        ip: '192.168.1.1',
 * //        datetime: 'Thu, 14 Jun 2018 07:00:00 GMT'
 * //      },
 * //      {
 * //        username: 'Pebbles',
 * //        ip: '192.168.1.21',
 * //        datetime: '15 June 2018 14:48 UTC'
 * //      },
 * //      {
 * //        username: 'Bamm-Bamm',
 * //        ip: '192.168.5.2',
 * //        datetime: 'Fri Jun 15 2018 16:48:00 GMT+0200 (CEST)'
 * //      },
 * //      {
 * //        username: 'Hoppy',
 * //        ip: '192.168.5.10',
 * //        datetime: '2018-06-15T14:48:00.000Z'
 * //      },
 * //      {
 * //        username: 'Wilma',
 * //        ip: '192.168.10.1',
 * //        datetime: '14 Jun 2018 00:00:00 PDT'
 * //      }
 * //    ]
 */
function compare(options) {
  var validatedOptions = getOptions(options);
  return baseCompare(validatedOptions);
}

/*
* Javascript natural sort algorithm with unicode support
* based on chunking idea by Dave Koelle
*
* https://github.com/yobacca/natural-sort-order
* released under MIT License
*/

export { orderBy, compare };
