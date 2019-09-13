'use strict'

let cli = require('..')
let errors = require('./errors')

function start (message, options) {
  if (!options) options = {}
  module.exports.task = {
    spinner: new cli.Spinner({spinner: options.spinner, text: `${message}...`}),
    stream: options.stream
  }
  module.exports.task.spinner.start()
}

function action (message, options, promise) {
  if (options.then) [options, promise] = [{}, options]
  start(message, options)
  return promise.then(function (result) {
    if (options.success !== false) done(options.success || 'done', options)
    else done(null, options)
    return result
  }).catch(function (err) {
    if (err.body && err.body.id === 'two_factor') done(cli.color.yellow.bold('!'), options)
    else done(cli.color.red.bold('!'), options)
    throw err
  })
}

function warn (msg) {
  let task = module.exports.task
  if (task) task.spinner.warn(msg)
  else errors.warn(msg)
}

function status (status) {
  let task = module.exports.task
  if (task) task.spinner.status = status
}

function done (msg, options) {
  options = options || {}
  let task = module.exports.task
  if (task) {
    task.spinner.stop(msg)
    module.exports.task = null
    if (options.clear) task.spinner.clear()
  }
}

module.exports = action
module.exports.start = start
module.exports.warn = warn
module.exports.status = status
module.exports.done = done
