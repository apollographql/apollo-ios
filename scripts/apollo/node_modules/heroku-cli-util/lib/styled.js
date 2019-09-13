'use strict'

let cli = require('..')
let util = require('util')

/**
 * styledJSON prints out colored, indented JSON
 *
 * @example
 * styledHeader({foo: 'bar'}) # Outputs === {
 *                                            "foo": "bar"
 *                                          }
 *
 * @param {obj} object data to display
 * @returns {null}
 */
function styledJSON (obj) {
  let json = JSON.stringify(obj, null, 2)
  if (cli.color.enabled) {
    let cardinal = require('cardinal')
    let theme = require('cardinal/themes/jq')
    cli.log(cardinal.highlight(json, {json: true, theme: theme}))
  } else {
    cli.log(json)
  }
}

/**
 * styledHeader logs in a consistent header style
 *
 * @example
 * styledHeader('MyApp') # Outputs === MyApp
 *
 * @param {header} header text
 * @returns {null}
 */
function styledHeader (header) {
  cli.log(cli.color.dim('=== ') + cli.color.bold(header))
}

/**
 * styledObject logs an object in a consistent columnar style
 *
 * @example
 * styledObject({name: "myapp", collaborators: ["user1@example.com", "user2@example.com"]})
 * Collaborators: user1@example.com
 *                user2@example.com
 * Name:          myapp
 *
 * @param {obj} object data to print
 * @param {keys} optional array of keys to sort/filter output
 * @returns {null}
 */
function styledObject (obj, keys) {
  let keyLengths = Object.keys(obj).map(key => key.toString().length)
  let maxKeyLength = Math.max.apply(Math, keyLengths) + 2
  function pp (obj) {
    if (typeof obj === 'string' || typeof obj === 'number') {
      return obj
    } else if (typeof obj === 'object') {
      return Object.keys(obj).map(k => k + ': ' + util.inspect(obj[k])).join(', ')
    } else {
      return util.inspect(obj)
    }
  }
  function logKeyValue (key, value) {
    cli.log(`${key}:` + ' '.repeat(maxKeyLength - key.length - 1) + pp(value))
  }
  for (var key of (keys || Object.keys(obj).sort())) {
    let value = obj[key]
    if (Array.isArray(value)) {
      if (value.length > 0) {
        logKeyValue(key, value[0])
        for (var e of value.slice(1)) {
          cli.log(' '.repeat(maxKeyLength) + pp(e))
        }
      }
    } else if (value !== null && value !== undefined) {
      logKeyValue(key, value)
    }
  }
}

/**
 * styledNameValues logs an array of {name: '', values: ['']} objects in a consistent style
 *
 * @example
 * styledNameValues([{name: "Collaborators", values: ["user1@example.com", "user2@example.com"]},
 *               {name: "Name", values: ["myapp"]}])
 * Collaborators: user1@example.com
 *                user2@example.com
 * Name:          myapp
 *
 * @param {nameValues} nameValues
 * @returns {null}
 */
function styledNameValues (nameValues) {
  let keys = nameValues.map(nameValue => nameValue.name)
  let keyLengths = keys.map(name => name.toString().length)
  let maxKeyLength = Math.max.apply(Math, keyLengths) + 2
  function pp (obj) {
    if (typeof obj === 'string' || typeof obj === 'number') {
      return obj
    } else if (typeof obj === 'object') {
      return Object.keys(obj).map(k => k + ': ' + cli.inspect(obj[k])).join(', ')
    } else {
      return cli.inspect(obj)
    }
  }
  function logKeyValue (key, value) {
    cli.log(`${key}:` + ' '.repeat(maxKeyLength - key.length - 1) + pp(value))
  }
  for (var nameValue of nameValues) {
    let value = nameValue.values
    if (Array.isArray(value)) {
      if (value.length > 0) {
        logKeyValue(nameValue.name, value[0])
        for (var e of value.slice(1)) {
          cli.log(' '.repeat(maxKeyLength) + pp(e))
        }
      }
    } else if (value !== null && value !== undefined) {
      logKeyValue(nameValue.name, value)
    }
  }
}

module.exports.styledJSON = styledJSON
module.exports.styledHeader = styledHeader
module.exports.styledObject = styledObject
module.exports.styledNameValues = styledNameValues
