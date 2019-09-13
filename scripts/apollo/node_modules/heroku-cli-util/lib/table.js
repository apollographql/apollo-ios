'use strict'

const stripAnsi = require('strip-ansi')
const cli = require('..')
const {ary, defaults, get, identity, keys, noop, partial, property, result, repeat} = require('lodash')

/**
 * Generates a Unicode table and feeds it into configured printer.
 *
 * Top-level arguments:
 *
 * @arg {Object[]} data - the records to format as a table.
 * @arg {Object} options - configuration for the table.
 *
 * @arg {Object[]} [options.columns] - Options for formatting and finding values for table columns.
 * @arg {function(string)} [options.headerAnsi] - Zero-width formattter for entire header.
 * @arg {string} [options.colSep] - Separator between columns.
 * @arg {function(row, options)} [options.after] - Function called after each row is printed.
 * @arg {function(string)} [options.printLine] - Function responsible for printing to terminal.
 * @arg {function(cells)} [options.printHeader] - Function to print header cells as a row.
 * @arg {function(cells)} [options.printRow] - Function to print cells as a row.
 *
 * @arg {function(row)|string} [options.columns[].key] - Path to the value in the row or function to retrieve the pre-formatted value for the cell.
 * @arg {function(string)} [options.columns[].label] - Header name for column.
 * @arg {function(string, row)} [options.columns[].format] - Formatter function for column value.
 * @arg {function(row)} [options.columns[].get] - Function to return a value to be presented in cell without formatting.
 *
 */
function table (data, options) {
  let _defaults = {
    colSep: '  ',
    after: noop,
    headerAnsi: identity,
    printLine: cli.log,
    printRow: function (cells) {
      this.printLine(cells.join(this.colSep).trimRight())
    },
    printHeader: function (cells) {
      this.printRow(cells.map(ary(this.headerAnsi, 1)))
      this.printRow(cells.map(hdr => hdr.replace(/./g, '─')))
    }
  }

  let colDefaults = {
    format: value => value ? value.toString() : '',
    width: 0,
    label: function () { return this.key.toString() },

    get: function (row) {
      let value
      let path = result(this, 'key')

      if (!path) {
        value = row
      } else {
        value = get(row, path)
      }

      return this.format(value, row)
    }
  }

  function calcWidth (cell) {
    let lines = stripAnsi(cell).split(/[\r\n]+/)
    let lineLengths = lines.map(property('length'))
    return Math.max.apply(Math, lineLengths)
  }

  function pad (string, length) {
    let visibleLength = stripAnsi(string).length
    let diff = length - visibleLength

    return string + repeat(' ', Math.max(0, diff))
  }

  function render () {
    let columns = options.columns || keys(data[0] || {})

    if (typeof columns[0] === 'string') {
      columns = columns.map(key => ({key}))
    }

    let defaultsApplied = false
    for (let row of data) {
      row.height = 1
      for (let col of columns) {
        if (!defaultsApplied) defaults(col, colDefaults)

        let cell = col.get(row)

        col.width = Math.max(
          result(col, 'label').length,
          col.width,
          calcWidth(cell)
        )

        row.height = Math.max(
          row.height,
          cell.split(/[\r\n]+/).length
        )
      }
      defaultsApplied = true
    }

    if (options.printHeader) {
      options.printHeader(columns.map(function (col) {
        let label = result(col, 'label')
        return pad(label, col.width || label.length)
      }))
    }

    function getNthLineOfCell (n, row, col) {
      // TODO memoize this
      let lines = col.get(row).split(/[\r\n]+/)
      return pad(lines[n] || '', col.width)
    }

    for (let row of data) {
      for (let i = 0; i < row.height; i++) {
        let cells = columns.map(partial(getNthLineOfCell, i, row))
        options.printRow(cells)
      }
      options.after(row, options)
    }
  }

  defaults(options, _defaults)
  render()
}

module.exports = table
