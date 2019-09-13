'use strict'

let _debugHeaders
function debugHeaders () {
  try {
    if (!_debugHeaders) _debugHeaders = require('debug')('http')
    _debugHeaders.apply(null, Array.prototype.slice.call(arguments))
  } catch (err) {}
}

let _debug
function debug () {
  try {
    if (!_debug) _debug = require('debug')('http')
    _debug.apply(null, Array.prototype.slice.call(arguments))
  } catch (err) {}
}

/*
 * Object capable of making API calls.
 */
class Request {
  constructor (options) {
    var URL = require('./url')

    this.options = options || {}
    this.debug = options.debug
    this.debugHeaders = options.debugHeaders
    var url = URL(options.host || 'https://api.heroku.com')
    this.host = url.host
    this.port = url.port
    this.secure = url.secure
    this.partial = options.partial
    this.userAgent = options.userAgent
    if (!this.userAgent) {
      var pjson = require('../package.json')
      this.userAgent = 'node-heroku-client/' + pjson.version
    }
    this.parseJSON = options.hasOwnProperty('parseJSON') ? options.parseJSON : true
    this.nextRange = 'id ..; max=1000'
    this.logger = options.logger
    this.middleware = options.middleware || function (_, cb) { cb() }
    this.certs = getCerts(this.debug)
    this.promise = new Promise((resolve, reject) => {
      this.resolve = resolve
      this.reject = reject
    })
    if (process.env.HEROKU_HTTP_PROXY_HOST) {
      var tunnel = require('tunnel-agent')
      var tunnelFunc
      if (this.secure) {
        tunnelFunc = tunnel.httpsOverHttp
      } else {
        tunnelFunc = tunnel.httpOverHttp
      }
      var agentOpts = {
        proxy: {
          host: process.env.HEROKU_HTTP_PROXY_HOST,
          port: process.env.HEROKU_HTTP_PROXY_PORT || 8080,
          proxyAuth: process.env.HEROKU_HTTP_PROXY_AUTH
        },
        rejectUnauthorized: options.rejectUnauthorized
      }
      if (this.certs.length > 0) {
        agentOpts.ca = this.certs
      }
      this.agent = tunnelFunc(agentOpts)
    } else {
      if (this.secure) {
        var https = require('https')
        this.agent = new https.Agent({ maxSockets: Number(process.env.HEROKU_CLIENT_MAX_SOCKETS) || 5000 })
      } else {
        var http = require('http')
        this.agent = new http.Agent({ maxSockets: Number(process.env.HEROKU_CLIENT_MAX_SOCKETS) || 5000 })
      }
    }
  }

  /*
   * Perform the actual API request.
   */
  request () {
    var headers = Object.assign({
      'Accept': 'application/vnd.heroku+json; version=3',
      'Content-type': 'application/json',
      'User-Agent': this.userAgent,
      'Range': this.nextRange
    }, this.options.headers)
    // remove null|undefined headers
    for (var k in Object.keys(headers)) {
      if (headers[k] === null || headers[k] === undefined) {
        delete headers[k]
      }
    }

    var requestOptions = {
      agent: this.agent,
      host: this.host,
      port: this.port,
      path: this.options.path,
      auth: this.options.auth || ':' + this.options.token,
      method: this.options.method || 'GET',
      rejectUnauthorized: this.options.rejectUnauthorized,
      headers: headers
    }
    if (this.certs.length > 0) {
      requestOptions.ca = this.certs
    }

    let req
    if (this.secure) {
      var https = require('https')
      req = https.request(requestOptions, this.handleResponse.bind(this))
    } else {
      var http = require('http')
      req = http.request(requestOptions, this.handleResponse.bind(this))
    }

    this.logRequest(req)
    this.writeBody(req)
    this.setRequestTimeout(req)

    req.on('error', this.handleError.bind(this))

    req.end()

    return this.promise
  }

  /*
   * Handle an API response, returning the API response.
   */
  handleResponse (res) {
    this.middleware(res, () => {
      this.logResponse(res)
      if (res.statusCode === 304) {
        this.updateAggregate(this.cachedResponse.body)
        this.resolve(this.aggregate)
        return
      }
      concat(res).then((data) => {
        debug(`<-- ${this.options.method} ${this.options.path}\n${data}`)
        debugHeaders('\n' + renderHeaders(res.headers))
        if (this.debug) console.error('<-- ' + data)
        if (res.statusCode.toString().match(/^2\d{2}$/)) {
          this.handleSuccess(res, data)
        } else {
          this.handleFailure(res, data)
        }
      }).catch(this.reject)
    })
  }

  isRetryAllowed (error) {
    const isRetryAllowed = require('is-retry-allowed')
    if (!isRetryAllowed(error)) return false
    if (error.statusCode && error.statusCode >= 400 && error.statusCode < 500) return false
    return true
  }

  handleError (error) {
    if (!this.retries) this.retries = 0
    if (this.retries >= 4 || !this.isRetryAllowed(error)) return this.reject(error)
    let noise = Math.random() * 100
    setTimeout(() => this.request(), (1 << this.retries) * 1000 + noise)
    this.retries++
  }

  logRequest (req) {
    debug(`--> ${req.method} ${this.options.path}`)
    if (this.debug) console.error('--> ' + req.method + ' ' + req.path)
    if (!req._headers) return
    let headers = renderHeaders(req._headers)
    debugHeaders('\n' + headers)
    if (this.debugHeaders) console.error(headers)
  }

  /*
   * Log the API response.
   */
  logResponse (res) {
    if (this.logger) {
      this.logger.log({
        status: res.statusCode,
        content_length: res.headers['content-length'],
        request_id: res.headers['request-id']
      })
    }
    let headers = renderHeaders(res.headers)
    if (this.debug) console.error('<-- ' + res.statusCode + ' ' + res.statusMessage)
    if (this.debugHeaders) console.error(headers)
  }

  /*
   * If the request options include a body,
   * write the body to the request and set
   * an appropriate 'Content-length' header.
   */
  writeBody (req) {
    if (this.options.body) {
      var body = this.options.body
      if (this.options.json !== false) { body = JSON.stringify(body) }
      if (this.debug) {
        console.error('--> ' + body)
      }

      req.setHeader('Content-length', Buffer.byteLength(body, 'utf8'))
      req.write(body)
    } else {
      req.setHeader('Content-length', 0)
    }
  }

  /*
   * If the request options include a timeout,
   * set the timeout and provide a callback
   * function in case the request exceeds the
   * timeout period.
   */
  setRequestTimeout (req) {
    if (!this.options.timeout) return

    req.setTimeout(this.options.timeout, () => {
      var err = new Error('Request took longer than ' + this.options.timeout + 'ms to complete.')

      req.abort()

      this.reject(err)
    })
  }

  /*
   * Get the request body, and parse it (or not) as appropriate.
   * - Parse JSON by default.
   * - If parseJSON is `false`, it will not parse.
   */
  parseBody (body) {
    if (this.parseJSON) {
      return JSON.parse(body || '{}')
    } else {
      return body
    }
  }

  /*
   * In the event of a non-successful API request,
   * fail with an appropriate error message and
   * status code.
   */
  handleFailure (res, buffer) {
    var message = 'Expected response to be successful, got ' + res.statusCode
    var err

    err = new Error(message)
    err.statusCode = res.statusCode
    try {
      err.body = this.parseBody(buffer)
    } catch (e) {
      err.body = buffer
    }

    this.reject(err)
  }

  /*
   * In the event of a successful API response,
   * respond with the response body.
   */
  handleSuccess (res, buffer) {
    var body = this.parseBody(buffer)

    if (!this.partial && res.headers['next-range']) {
      this.nextRequest(res.headers['next-range'], body)
    } else {
      this.updateAggregate(body)
      this.resolve(this.aggregate)
    }
  }

  /*
   * Since this request isn't the full response (206 or
   * 304 with a cached Next-Range), perform the next
   * request for more data.
   */
  nextRequest (nextRange, body) {
    this.updateAggregate(body)
    this.nextRange = nextRange
    // The initial range header passed in (if there was one), is no longer valid, and should no longer take precedence
    delete (this.options.headers.Range)
    this.request()
  }

  /*
   * If given an object, sets aggregate to object,
   * otherwise concats array onto aggregate.
   */
  updateAggregate (aggregate) {
    if (aggregate instanceof Array) {
      this.aggregate = this.aggregate || []
      this.aggregate = this.aggregate.concat(aggregate)
    } else {
      this.aggregate = aggregate
    }
  }
}

function sslCertFile () {
  return process.env.SSL_CERT_FILE ? [process.env.SSL_CERT_FILE] : []
}

function sslCertDir () {
  var certDir = process.env.SSL_CERT_DIR
  if (certDir) {
    var path = require('path')
    var fs = require('fs')
    return fs.readdirSync(certDir)
      .map((f) => path.join(certDir, f))
      .filter((f) => fs.statSync(f).isFile())
  } else {
    return []
  }
}

function getCerts (debug) {
  var filenames = sslCertFile().concat(sslCertDir())

  if (filenames.length > 0 && debug) {
    console.error('Adding the following trusted certificate authorities')
  }

  return filenames.map(function (filename) {
    var fs = require('fs')
    if (debug) {
      console.error('  ' + filename)
    }
    return fs.readFileSync(filename)
  })
}

function renderHeaders (headers) {
  return Object.keys(headers).map(key => {
    let value = key.toUpperCase() === 'AUTHORIZATION' ? 'REDACTED' : headers[key]
    return '    ' + key + '=' + value
  }).join('\n')
}

function concat (stream) {
  return new Promise((resolve) => {
    var strings = []
    stream.on('data', (data) => strings.push(data))
    stream.on('end', () => resolve(strings.join('')))
  })
}

module.exports = Request
