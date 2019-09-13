'use strict'
let util = require('./util')

/**
 * preauth will make an API call to preauth a user for an app
 * this makes it so the user will not have to enter a 2fa code
 * for the next few minutes on the specified app.
 *
 * You need this if your command is going to make multiple API calls
 * since otherwise the secondFactor key would only work one time for
 * yubikeys.
 *
 * @param {String} app the app to preauth against
 * @param {Heroku} heroku a heroku api client
 * @param {String} secondFactor a second factor code
 * @return {Promise} A promise fulfilled when the preauth is complete
 */
function preauth (app, heroku, secondFactor) {
  return heroku.request({
    method: 'PUT',
    path: `/apps/${app}/pre-authorizations`,
    headers: { 'Heroku-Two-Factor-Code': secondFactor }
  })
}

module.exports = util.promiseOrCallback(preauth)
