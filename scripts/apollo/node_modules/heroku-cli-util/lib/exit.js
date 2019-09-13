'use strict'

var util = require('util')
var cli = require('./errors')

function ErrorExit (code, message) {
  Error.call(this)
  Error.captureStackTrace(this, this.constructor)
  this.name = this.constructor.name

  this.code = code
  this.message = message
}

util.inherits(ErrorExit, Error)

var mocking

function exit (code, message) {
  if (message) {
    cli.error(message)
  }
  if (mocking) {
    throw new ErrorExit(code, message)
  } else {
    process.exit(code)
  }
}

exit.mock = function (mock) {
  if (mock === false) {
    mocking = false
  } else {
    mocking = true
  }
}

exit.ErrorExit = ErrorExit

module.exports = {
  exit
}
