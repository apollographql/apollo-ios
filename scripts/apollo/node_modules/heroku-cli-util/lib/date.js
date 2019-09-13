'use strict'

/**
 * formatDate will format a date in a standard Heroku format
 *
 * @example
 * let cli = require('heroku-cli-util')
 * var d = new Date()
 * cli.formatDate(d); // '2015-05-14T18:03:10.034Z'
 *
 * @param {Date} date the date to format
 * @return {String} string representing the date
 */
function formatDate (date) {
  return date.toISOString()
}

exports.formatDate = formatDate
