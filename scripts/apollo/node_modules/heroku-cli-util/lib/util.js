'use strict'

/**
 * promiseOrCallback will convert a function that returns a promise
 * into one that will either make a node-style callback or return a promise
 * based on whether or not a callback is passed in.
 *
 * @example
 * prompt('input? ').then(function (input) {
 *   // deal with input
 * })
 * var prompt2 = promiseOrCallback(prompt)
 * prompt('input? ', function (err, input) {
 *   // deal with input
 * })
 *
 * @param {Function} fn a promise returning function to wrap
 * @returns {Function} a function that behaves like before unless called with a callback
 */
function promiseOrCallback (fn) {
  return function () {
    if (typeof arguments[arguments.length - 1] === 'function') {
      let args = Array.prototype.slice.call(arguments)
      let callback = args.pop()
      fn.apply(null, args).then(function () {
        let args = Array.prototype.slice.call(arguments)
        args.unshift(null)
        callback.apply(null, args)
      }).catch(function (err) {
        callback(err)
      })
    } else {
      return fn.apply(null, arguments)
    }
  }
}

exports.promiseOrCallback = promiseOrCallback
