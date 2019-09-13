'use strict'

const url = require('url')

class Vars {
  constructor (env) {
    this.env = env
  }

  get host () { return this.env.HEROKU_HOST || 'heroku.com' }
  get apiUrl () { return this.host.startsWith('http') ? this.host : `https://api.${this.host}` }
  get apiHost () {
    if (this.host.startsWith('http')) {
      const u = url.parse(this.host)
      if (u.host) return u.host
    }
    return `api.${this.host}`
  }
  get httpGitHost () {
    if (this.env.HEROKU_GIT_HOST) return this.env.HEROKU_GIT_HOST
    if (this.host.startsWith('http')) {
      const u = url.parse(this.host)
      if (u.host) return u.host
    }
    return `git.${this.host}`
  }
}

module.exports = new Vars(process.env)
