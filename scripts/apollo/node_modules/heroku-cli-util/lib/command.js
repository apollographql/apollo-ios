'use strict'

const Heroku = require('heroku-client')
const cli = require('..')
const auth = require('./auth')
const vars = require('./vars')
const Mutex = require('./mutex')

function twoFactorWrapper (options, preauths, context) {
  return function (res, buffer) {
    let body
    try {
      body = this.parseBody(buffer)
    } catch (e) {
      this._handleFailure(res, buffer)
    }

    // safety check for if we have already seen this request for preauthing
    // this prevents an infinite loop in case some preauth fails silently
    // and we continue to get two_factor failures

    // this might be better done with a timer in case a command takes too long
    // and the preauthorization runs out, but that seemed unlikely
    if (res.statusCode === 403 && body.id === 'two_factor' && !preauths.requests.includes(this)) {
      let self = this
      // default preauth to always happen unless explicitly disabled
      if (options.preauth === false || !body.app) {
        twoFactorPrompt(options, preauths, context)
          .then(function (secondFactor) {
            self.options.headers = Object.assign({}, self.options.headers, {'Heroku-Two-Factor-Code': secondFactor})
            self.request()
          })
          .catch(function (err) {
            self.reject(err)
          })
      } else {
        preauths.requests.push(self)

        // if multiple requests are run in parallel for the same app, we should
        // only preauth for the first so save the fact we already preauthed
        if (!preauths.promises[body.app.name]) {
          preauths.promises[body.app.name] = twoFactorPrompt(options, preauths, context)
            .then(function (secondFactor) {
              return cli.preauth(body.app.name, heroku(context), secondFactor)
            })
        }

        preauths.promises[body.app.name].then(function () {
          self.request()
        })
          .catch(function (err) {
            self.reject(err)
          })
      }
    } else {
      this._handleFailure(res, buffer)
    }
  }
}

function apiMiddleware (options, preauths, context) {
  let twoFactor = twoFactorWrapper(options, preauths, context)
  return function (response, cb) {
    let warning = response.headers['x-heroku-warning'] || response.headers['warning-message']
    if (warning) cli.action.warn(warning)

    // override the _handleFailure for this request
    if (!this._handleFailure) {
      this._handleFailure = this.handleFailure
      this.handleFailure = twoFactor.bind(this)
    }

    cb()
  }
}

function heroku (context, options) {
  let host = context.apiUrl || vars.apiUrl || 'https://api.heroku.com'

  let preauths = {
    promises: {},
    requests: [],
    twoFactorMutex: new Mutex()
  }

  let opts = {
    userAgent: context.version,
    debug: context.debug,
    debugHeaders: context.debugHeaders,
    token: context.auth ? context.auth.password : null,
    host: host,
    headers: {},
    rejectUnauthorized: !(process.env.HEROKU_SSL_VERIFY === 'disable' || host.endsWith('herokudev.com')),
    middleware: apiMiddleware(options, preauths, context)
  }
  if (process.env.HEROKU_HEADERS) {
    Object.assign(opts.headers, JSON.parse(process.env.HEROKU_HEADERS))
  }
  if (context.secondFactor) {
    Object.assign(opts.headers, {'Heroku-Two-Factor-Code': context.secondFactor})
  }
  if (context.reason) {
    Object.assign(opts.headers, {'X-Heroku-Sudo-Reason': context.reason})
  }
  cli.heroku = new Heroku(opts)
  return cli.heroku
}

let httpsProxy = process.env.HTTPS_PROXY || process.env.https_proxy || process.env.HTTP_PROXY || process.env.http_proxy

function setupHttpProxy () {
  const url = require('url')
  cli.hush(`proxy set to ${httpsProxy}`)
  let proxy = url.parse(httpsProxy)
  process.env.HEROKU_HTTP_PROXY_HOST = proxy.hostname
  process.env.HEROKU_HTTP_PROXY_PORT = proxy.port
  process.env.HEROKU_HTTP_PROXY_AUTH = proxy.auth
}

function relogin () {
  if (process.env.HEROKU_LOGIN_REDIRECT === '1') return auth.login({save: true})
  process.env.HEROKU_LOGIN_REDIRECT = '1'
  require('child_process').execSync('heroku login', {stdio: 'inherit'})
  return Promise.resolve()
}

function twoFactorPrompt (options, preauths, context) {
  cli.yubikey.enable()
  return preauths.twoFactorMutex.synchronize(function () {
    return cli.prompt('Two-factor code', {mask: true})
      .catch(function (err) {
        cli.yubikey.disable()
        throw err
      })
      .then(function (secondFactor) {
        cli.yubikey.disable()
        return secondFactor
      })
  })
}

function reasonPrompt (context) {
  return cli.prompt('Reason')
    .then(function (reason) {
      context.reason = reason
    })
}

module.exports = function command (options, fn) {
  return function (context) {
    if (typeof options === 'function') [fn, options] = [options, {}]
    if (httpsProxy) setupHttpProxy()
    cli.color.enabled = context.supportsColor
    let handleErr = cli.errorHandler({debug: context.debug})
    let run = function () {
      context.auth = {password: auth.token()}
      let p = fn(context, heroku(context, options))
      if (!p.catch) return
      return p.catch(function (err) {
        if (err && err.body && err.body.id === 'unauthorized') {
          cli.error(err.body.message || 'Unauthorized')
          return relogin().then(run).catch(handleErr)
        } else if (err && err.body && err.body.id === 'sudo_reason_required') {
          cli.warn(err.body.message)
          return reasonPrompt(context).then(run).catch(handleErr)
        } else throw err
      }).catch(handleErr)
    }
    return run()
  }
}
