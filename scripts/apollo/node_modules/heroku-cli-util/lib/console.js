'use strict'

var cli = require('..')
const stripAnsi = require('strip-ansi')

var mocking

function concatArguments (args) {
  return Array.prototype.map.call(args, function (arg) {
    return arg + ''
  }).join(' ')
}

/**
 * log is a wrapper for console.log() but can be mocked
 *
 * @param {...Object} obj - objects to be printed to stdout
 */
function log () {
  if (mocking) {
    cli.stdout += stripAnsi(concatArguments(arguments) + '\n')
  } else {
    console.log.apply(null, arguments)
  }
}

/**
 * writeLog is a wrapper for process.stdout.write() but can be mocked
 *
 * @param {...Object} obj - objects to be printed to stdout
 */
function writeLog () {
  if (mocking) {
    cli.stdout += stripAnsi(concatArguments(arguments))
  } else {
    process.stdout.write.apply(process.stdout, arguments)
  }
}

function hush () {
  let debug = process.env.HEROKU_DEBUG
  if (debug && (debug === '1' || debug.toUpperCase() === 'TRUE')) {
    console.error.apply(null, arguments)
  }
}

/**
 * error is a wrapper for console.error() but can be mocked
 *
 * @param {...Object} obj - objects to be printed to stderr
 */
function error () {
  if (mocking) {
    cli.stderr += stripAnsi(concatArguments(arguments) + '\n')
  } else {
    console.error.apply(null, arguments)
  }
}

/**
 * writeError is a wrapper for process.stderr.write() but can be mocked
 *
 * @param {...Object} obj - objects to be printed to stderr
 */
function writeError () {
  if (mocking) {
    cli.stderr += stripAnsi(concatArguments(arguments))
  } else {
    process.stderr.write.apply(process.stderr, arguments)
  }
}

/**
 * mock will make {@link log} and {@link error}
 * stop printing to stdout and stderr and start writing to the
 * stdout and stderr strings.
 */
function mock (mock) {
  if (mock === false) {
    mocking = false
  } else {
    mocking = true
    cli.stderr = ''
    cli.stdout = ''
  }
}

/**
 * debug pretty prints an object.
 * It simply calls console.dir with color enabled.
 *
 * @param {Object} obj - object to be printed
 */
function debug (obj) {
  console.dir(obj, {colors: true})
}

exports.hush = hush
exports.log = log
exports.writeLog = writeLog
exports.error = error
exports.writeError = writeError
exports.mock = mock
exports.mocking = () => mocking
exports.debug = debug
