'use strict'

const cli = require('../')
const errors = require('./errors')
const util = require('./util')
const color = cli.color
const ansi = require('ansi-escapes')
const Spinner = require('./spinner')
const nodeUtil = require('util')

function promptMasked (options) {
  return new Promise(function (resolve, reject) {
    let stdin = process.stdin
    let stderr = process.stderr
    let input = ''
    stdin.setEncoding('utf8')
    stderr.write(ansi.eraseLine)
    stderr.write(ansi.cursorLeft)
    cli.console.writeError(options.prompt)
    stdin.resume()
    stdin.setRawMode(true)

    function stop () {
      if (!options.hide) {
        stderr.write(
          ansi.cursorHide +
            ansi.cursorLeft +
            options.prompt +
            input.replace(/./g, '*') +
            '\n' +
            ansi.cursorShow)
      } else {
        stderr.write('\n')
      }
      stdin.removeListener('data', fn)
      stdin.setRawMode(false)
      stdin.pause()
    }

    function enter () {
      if (input.length === 0) return
      stop()
      resolve(input)
    }

    function ctrlc () {
      reject(new Error(''))
      stop()
    }

    function backspace () {
      if (input.length === 0) return
      input = input.substr(0, input.length - 1)
      stderr.write(ansi.cursorBackward(1))
      stderr.write(ansi.eraseEndLine)
    }

    function newchar (c) {
      input += c
      stderr.write(options.hide ? '*'.repeat(c.length) : c)
    }

    let fn = function (c) {
      switch (c) {
        case '\u0004': // Ctrl-d
        case '\r':
        case '\n':
          return enter()
        case '\u0003': // Ctrl-c
          return ctrlc()
        default:
          // backspace
          if (c.charCodeAt(0) === 127) return backspace()
          else return newchar(c)
      }
    }
    stdin.on('data', fn)
  })
}

function PromptMaskError (message) {
  Error.call(this)
  Error.captureStackTrace(this, this.constructor)
  this.name = this.constructor.name
  this.message = message
}

nodeUtil.inherits(PromptMaskError, Error)

exports.PromptMaskError = PromptMaskError

function prompt (name, options) {
  options = options || {}
  options.name = name
  options.prompt = name ? color.dim(`${name}: `) : color.dim('> ')
  let isTTY = process.env.TERM !== 'dumb' && process.stdin.isTTY
  let spinnerTask
  if (options.mask || options.hide) {
    if (!isTTY) {
      return Promise.reject(new PromptMaskError(`CLI needs to prompt for ${options.name || options.prompt} but stdin is not a tty.`))
    }

    spinnerTask = function () {
      return promptMasked(options)
    }
  } else {
    spinnerTask = function () {
      return new Promise(function (resolve) {
        process.stdin.setEncoding('utf8')
        cli.console.writeError(options.prompt)
        process.stdin.resume()
        process.stdin.once('data', function (data) {
          process.stdin.pause()
          data = data.trim()
          if (data === '') {
            resolve(prompt(name))
          } else {
            resolve(data)
          }
        })
      })
    }
  }
  return Spinner.prompt(spinnerTask)
}

function confirmApp (app, confirm, message) {
  return new Promise(function (resolve, reject) {
    if (confirm) {
      if (confirm === app) return resolve()
      return reject(new Error(`Confirmation ${cli.color.bold.red(confirm)} did not match ${cli.color.bold.red(app)}. Aborted.`))
    }
    if (!message) {
      message = `WARNING: Destructive Action
This command will affect the app ${cli.color.bold.red(app)}`
    }
    errors.warn(message)
    errors.warn(`To proceed, type ${cli.color.bold.red(app)} or re-run this command with ${cli.color.bold.red('--confirm', app)}`)
    console.error()
    prompt().then(function (confirm) {
      if (confirm === app) {
        return resolve()
      }
      return reject(new Error(`Confirmation did not match ${cli.color.bold.red(app)}. Aborted.`))
    })
  })
}

exports.prompt = util.promiseOrCallback(prompt)
exports.confirmApp = util.promiseOrCallback(confirmApp)
