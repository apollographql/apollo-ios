'use strict'

let {color} = require('..')

function open (url, browser) {
  let opn = require('opn')
  return new Promise((resolve, reject) => {
    let opts = {wait: false}
    if (browser) { opts.app = browser }
    opn(url, opts, err => {
      if (err) {
        reject(new Error(
          `Error opening web browser.
${err}

Manually visit ${color.cyan(url)} in your browser.`))
      } else resolve(err)
    })
  })
}

module.exports = open
