'use strict'

var url = require('url')

module.exports = function (u) {
  if (u.indexOf('http') !== 0 && u.indexOf('https') !== 0) {
    u = 'https://' + u
  }

  var uu = url.parse(u)
  var port = uu.port
  if (!port) {
    if (uu.protocol === 'https:') {
      port = '443'
    } else {
      port = '80'
    }
  }
  var secure = uu.protocol === 'https:' || uu.port === '443'

  return { host: uu.hostname, port: parseInt(port), secure: secure }
}
