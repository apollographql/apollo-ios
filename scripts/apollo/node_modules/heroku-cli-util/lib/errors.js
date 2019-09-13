'use strict'

const stripAnsi = require('strip-ansi')
let cli = require('..')
let console = require('./console')
let linewrap = require('./linewrap')
let path = require('path')
let os = require('os')

function errtermwidth () {
  if (global.columns) return global.columns
  if (!process.stderr.isTTY || !process.stderr.getWindowSize) return 80
  let width = process.stderr.getWindowSize()[0]
  return width < 30 ? 30 : width
}

function wrap (msg) {
  return linewrap(6,
    errtermwidth(), {
      skipScheme: 'ansi-color',
      skip: /^\$ .*$/
    })(msg || '')
}

function bangify (msg, c) {
  let lines = msg.split('\n')
  for (let i = 0; i < lines.length; i++) {
    let line = lines[i]
    lines[i] = ' ' + c + line.substr(2, line.length)
  }
  return lines.join('\n')
}

function getErrorMessage (err) {
  if (err.body) {
    // API error
    if (err.body.message) {
      return err.body.message
    } else if (err.body.error) {
      return err.body.error
    }
  }
  // Unhandled error
  if (err.message && err.code) {
    return `${err.code}: ${err.message}`
  } else if (err.message) {
    return err.message
  }
  return err
}

let arrow = process.platform === 'win32' ? '!' : '▸'

function error (err) {
  console.error(bangify(wrap(getErrorMessage(err)), cli.color.red(arrow)))
}

function warn (msg) {
  console.error(renderWarning(msg))
}

function renderWarning (msg) {
  return bangify(wrap(msg), cli.color.yellow(arrow))
}

function logtimestamp () {
  return new Date().toISOString()
    .replace(/T/, ' ')
    .replace(/-/g, '/')
    .replace(/\..+/, '')
}

function cacheHome () {
  let base
  if (process.env.XDG_CACHE_HOME) base = process.env.XDG_CACHE_HOME
  if (!base) {
    if (process.platform === 'darwin') {
      base = path.join(os.homedir(), 'Library', 'Caches')
    } else if (process.platform === 'win32' && process.env.LOCALAPPDATA) {
      base = process.env.LOCALAPPDATA
    } else {
      base = path.join(os.homedir(), '.cache')
    }
  }
  return path.join(base, 'heroku')
}

function log (msg) {
  let fs = require('fs')
  let logPath = path.join(cacheHome(), 'error.log')
  fs.appendFileSync(logPath, logtimestamp() + ' ' + stripAnsi(msg) + '\n')
}

function errorHandler (options) {
  options = options || {}
  function exit () {
    if (options.exit !== false) {
      process.exit(1)
    }
  }
  return function handleErr (err) {
    if (cli.raiseErrors) throw err
    try {
      if (err !== '') error(err)
      if (err.stack) {
        log(err.stack)
        if (options.debug) console.error(err.stack)
      }
      if (err.body) log(JSON.stringify(err.body))
      exit()
    } catch (err) {
      console.error(err.stack)
      process.exit(-1)
    }
  }
}

module.exports.error = error
module.exports.warn = warn
module.exports.errorHandler = errorHandler
module.exports.renderWarning = renderWarning
module.exports.errtermwidth = errtermwidth
