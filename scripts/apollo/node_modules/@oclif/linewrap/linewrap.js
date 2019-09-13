// code is originally from https://github.com/AnAppAMonth/linewrap

// Presets
var presetMap = {
  'html': {
    skipScheme: 'html',
    lineBreakScheme: 'html',
    whitespace: 'collapse'
  }
}

// lineBreak Schemes
var brPat = /<\s*br(?:[\s/]*|\s[^>]*)>/gi
var lineBreakSchemeMap = {
  'unix': [/\n/g, '\n'],
  'dos': [/\r\n/g, '\r\n'],
  'mac': [/\r/g, '\r'],
  'html': [brPat, '<br>'],
  'xhtml': [brPat, '<br/>']
}

// skip Schemes
var skipSchemeMap = {
  'ansi-color': /\x1B\[[^m]*m/g,
  'html': /<[^>]*>/g,
  'bbcode': /\[[^]]*\]/g
}

var modeMap = {
  'soft': 1,
  'hard': 1
}

var wsMap = {
  'collapse': 1,
  'default': 1,
  'line': 1,
  'all': 1
}

var rlbMap = {
  'all': 1,
  'multi': 1,
  'none': 1
}
var rlbSMPat = /([sm])(\d+)/

var escapePat = /[-/\\^$*+?.()|[\]{}]/g
function escapeRegExp (s) {
  return s.replace(escapePat, '\\$&')
}

var linewrap = module.exports = function (start, stop, params) {
  if (typeof start === 'object') {
    params = start
    start = params.start
    stop = params.stop
  }

  if (typeof stop === 'object') {
    params = stop
    start = start || params.start
    stop = undefined
  }

  if (!stop) {
    stop = start
    start = 0
  }

  if (!params) { params = {}; }
  // Supported options and default values.
  var preset,
    mode = 'soft',
    whitespace = 'default',
    tabWidth = 4,
    skip, skipScheme, lineBreak, lineBreakScheme,
    respectLineBreaks = 'all',
    respectNum,
    preservedLineIndent,
    wrapLineIndent, wrapLineIndentBase

  var skipPat
  var lineBreakPat, lineBreakStr
  var multiLineBreakPat
  var preservedLinePrefix = ''
  var wrapLineIndentPat, wrapLineInitPrefix = ''
  var tabRepl
  var item, flags
  var i

  // First process presets, because these settings can be overwritten later.
  preset = params.preset
  if (preset) {
    if (!(preset instanceof Array)) {
      preset = [preset]
    }
    for (i = 0; i < preset.length; i++) {
      item = presetMap[preset[i]]
      if (item) {
        if (item.mode) {
          mode = item.mode
        }
        if (item.whitespace) {
          whitespace = item.whitespace
        }
        if (item.tabWidth !== undefined) {
          tabWidth = item.tabWidth
        }
        if (item.skip) {
          skip = item.skip
        }
        if (item.skipScheme) {
          skipScheme = item.skipScheme
        }
        if (item.lineBreak) {
          lineBreak = item.lineBreak
        }
        if (item.lineBreakScheme) {
          lineBreakScheme = item.lineBreakScheme
        }
        if (item.respectLineBreaks) {
          respectLineBreaks = item.respectLineBreaks
        }
        if (item.preservedLineIndent !== undefined) {
          preservedLineIndent = item.preservedLineIndent
        }
        if (item.wrapLineIndent !== undefined) {
          wrapLineIndent = item.wrapLineIndent
        }
        if (item.wrapLineIndentBase) {
          wrapLineIndentBase = item.wrapLineIndentBase
        }
      } else {
        throw new TypeError('preset must be one of "' + Object.keys(presetMap).join('", "') + '"')
      }
    }
  }

  if (params.mode) {
    if (modeMap[params.mode]) {
      mode = params.mode
    } else {
      throw new TypeError('mode must be one of "' + Object.keys(modeMap).join('", "') + '"')
    }
  }
  // Available options: 'collapse', 'default', 'line', and 'all'
  if (params.whitespace) {
    if (wsMap[params.whitespace]) {
      whitespace = params.whitespace
    } else {
      throw new TypeError('whitespace must be one of "' + Object.keys(wsMap).join('", "') + '"')
    }
  }

  if (params.tabWidth !== undefined) {
    if (parseInt(params.tabWidth, 10) >= 0) {
      tabWidth = parseInt(params.tabWidth, 10)
    } else {
      throw new TypeError('tabWidth must be a non-negative integer')
    }
  }
  tabRepl = new Array(tabWidth + 1).join(' ')

  // Available options: 'all', 'multi', 'm\d+', 's\d+', 'none'
  if (params.respectLineBreaks) {
    if (rlbMap[params.respectLineBreaks] || rlbSMPat.test(params.respectLineBreaks)) {
      respectLineBreaks = params.respectLineBreaks
    } else {
      throw new TypeError('respectLineBreaks must be one of "' + Object.keys(rlbMap).join('", "') +
        '", "m<num>", "s<num>"')
    }
  }
  // After these conversions, now we have 4 options in `respectLineBreaks`:
  // 'all', 'none', 'm' and 's'.
  // `respectNum` is applicable iff `respectLineBreaks` is either 'm' or 's'.
  if (respectLineBreaks === 'multi') {
    respectLineBreaks = 'm'
    respectNum = 2
  } else if (!rlbMap[respectLineBreaks]) {
    var match = rlbSMPat.exec(respectLineBreaks)
    respectLineBreaks = match[1]
    respectNum = parseInt(match[2], 10)
  }

  if (params.preservedLineIndent !== undefined) {
    if (parseInt(params.preservedLineIndent, 10) >= 0) {
      preservedLineIndent = parseInt(params.preservedLineIndent, 10)
    } else {
      throw new TypeError('preservedLineIndent must be a non-negative integer')
    }
  }

  if (preservedLineIndent > 0) {
    preservedLinePrefix = new Array(preservedLineIndent + 1).join(' ')
  }

  if (params.wrapLineIndent !== undefined) {
    if (!isNaN(parseInt(params.wrapLineIndent, 10))) {
      wrapLineIndent = parseInt(params.wrapLineIndent, 10)
    } else {
      throw new TypeError('wrapLineIndent must be an integer')
    }
  }
  if (params.wrapLineIndentBase) {
    wrapLineIndentBase = params.wrapLineIndentBase
  }

  if (wrapLineIndentBase) {
    if (wrapLineIndent === undefined) {
      throw new TypeError('wrapLineIndent must be specified when wrapLineIndentBase is specified')
    }
    if (wrapLineIndentBase instanceof RegExp) {
      wrapLineIndentPat = wrapLineIndentBase
    } else if (typeof wrapLineIndentBase === 'string') {
      wrapLineIndentPat = new RegExp(escapeRegExp(wrapLineIndentBase))
    } else {
      throw new TypeError('wrapLineIndentBase must be either a RegExp object or a string')
    }
  } else if (wrapLineIndent > 0) {
    wrapLineInitPrefix = new Array(wrapLineIndent + 1).join(' ')
  } else if (wrapLineIndent < 0) {
    throw new TypeError('wrapLineIndent must be non-negative when a base is not specified')
  }

  // NOTE: For the two RegExps `skipPat` and `lineBreakPat` that can be specified
  //       by the user:
  //       1. We require them to be "global", so we have to convert them to global
  //          if the user specifies a non-global regex.
  //       2. We cannot call `split()` on them, because they may or may not contain
  //          capturing parentheses which affect the output of `split()`.

  // Precedence: Regex = Str > Scheme
  if (params.skipScheme) {
    if (skipSchemeMap[params.skipScheme]) {
      skipScheme = params.skipScheme
    } else {
      throw new TypeError('skipScheme must be one of "' + Object.keys(skipSchemeMap).join('", "') + '"')
    }
  }
  if (params.skip) {
    skip = params.skip
  }

  if (skip) {
    if (skip instanceof RegExp) {
      skipPat = skip
      if (!skipPat.global) {
        flags = 'g'
        if (skipPat.ignoreCase) { flags += 'i'; }
        if (skipPat.multiline) { flags += 'm'; }
        skipPat = new RegExp(skipPat.source, flags)
      }
    } else if (typeof skip === 'string') {
      skipPat = new RegExp(escapeRegExp(skip), 'g')
    } else {
      throw new TypeError('skip must be either a RegExp object or a string')
    }
  }
  if (!skipPat && skipScheme) {
    skipPat = skipSchemeMap[skipScheme]
  }

  // Precedence:
  // - for lineBreakPat: Regex > Scheme > Str
  // - for lineBreakStr: Str > Scheme > Regex
  if (params.lineBreakScheme) {
    if (lineBreakSchemeMap[params.lineBreakScheme]) {
      lineBreakScheme = params.lineBreakScheme
    } else {
      throw new TypeError('lineBreakScheme must be one of "' + Object.keys(lineBreakSchemeMap).join('", "') + '"')
    }
  }
  if (params.lineBreak) {
    lineBreak = params.lineBreak
  }

  if (lineBreakScheme) {
    // Supported schemes: 'unix', 'dos', 'mac', 'html', 'xhtml'
    item = lineBreakSchemeMap[lineBreakScheme]
    if (item) {
      lineBreakPat = item[0]
      lineBreakStr = item[1]
    }
  }
  if (lineBreak) {
    if (lineBreak instanceof Array) {
      if (lineBreak.length === 1) {
        lineBreak = lineBreak[0]
      } else if (lineBreak.length >= 2) {
        if (lineBreak[0] instanceof RegExp) {
          lineBreakPat = lineBreak[0]
          if (typeof lineBreak[1] === 'string') {
            lineBreakStr = lineBreak[1]
          }
        } else if (lineBreak[1] instanceof RegExp) {
          lineBreakPat = lineBreak[1]
          if (typeof lineBreak[0] === 'string') {
            lineBreakStr = lineBreak[0]
          }
        } else if (typeof lineBreak[0] === 'string' && typeof lineBreak[1] === 'string') {
          lineBreakPat = new RegExp(escapeRegExp(lineBreak[0]), 'g')
          lineBreakStr = lineBreak[1]
        } else {
          lineBreak = lineBreak[0]
        }
      }
    }
    if (typeof lineBreak === 'string') {
      lineBreakStr = lineBreak
      if (!lineBreakPat) {
        lineBreakPat = new RegExp(escapeRegExp(lineBreak), 'g')
      }
    } else if (lineBreak instanceof RegExp) {
      lineBreakPat = lineBreak
    } else if (!(lineBreak instanceof Array)) {
      throw new TypeError('lineBreak must be a RegExp object, a string, or an array consisted of a RegExp object and a string')
    }
  }
  // Only assign defaults when `lineBreakPat` is not assigned.
  // So if `params.lineBreak` is a RegExp, we don't have a value in `lineBreakStr`
  // yet. We will try to get the value from the input string, and if failed, we
  // will throw an exception.
  if (!lineBreakPat) {
    lineBreakPat = /\n/g
    lineBreakStr = '\n'
  }

  // Create `multiLineBreakPat` based on `lineBreakPat`, that matches strings
  // consisted of one or more line breaks and zero or more whitespaces.
  // Also convert `lineBreakPat` to global if not already so.
  flags = 'g'
  if (lineBreakPat.ignoreCase) { flags += 'i'; }
  if (lineBreakPat.multiline) { flags += 'm'; }
  multiLineBreakPat = new RegExp('\\s*(?:' + lineBreakPat.source + ')(?:' +
    lineBreakPat.source + '|\\s)*', flags)
  if (!lineBreakPat.global) {
    lineBreakPat = new RegExp(lineBreakPat.source, flags)
  }

  // Initialize other useful variables.
  var re = mode === 'hard' ? /\b/ : /(\S+\s+)/
  var prefix = new Array(start + 1).join(' ')
  var wsStrip = (whitespace === 'default' || whitespace === 'collapse'),
    wsCollapse = (whitespace === 'collapse'),
    wsLine = (whitespace === 'line'),
    wsAll = (whitespace === 'all')
  var tabPat = /\t/g,
    collapsePat = /  +/g,
    pPat = /^\s+/,
    tPat = /\s+$/,
    nonWsPat = /\S/,
    wsPat = /\s/
  var wrapLen = stop - start

  return function (text) {
    text = text.toString().replace(tabPat, tabRepl)

    var match
    if (!lineBreakStr) {
      // Try to get lineBreakStr from `text`
      lineBreakPat.lastIndex = 0
      match = lineBreakPat.exec(text)
      if (match) {
        lineBreakStr = match[0]
      } else {
        throw new TypeError('Line break string for the output not specified')
      }
    }

    // text -> blocks; each bloc -> segments; each segment -> chunks
    var blocks, base = 0
    var mo, arr, b, res
    // Split `text` by line breaks.
    blocks = []
    multiLineBreakPat.lastIndex = 0
    match = multiLineBreakPat.exec(text)
    while(match) {
      blocks.push(text.substring(base, match.index))

      if (respectLineBreaks !== 'none') {
        arr = []
        b = 0
        lineBreakPat.lastIndex = 0
        mo = lineBreakPat.exec(match[0])
        while(mo) {
          arr.push(match[0].substring(b, mo.index))
          b = mo.index + mo[0].length
          mo = lineBreakPat.exec(match[0])
        }
        arr.push(match[0].substring(b))
        blocks.push({type: 'break', breaks: arr})
      } else {
        // Strip line breaks and insert spaces when necessary.
        if (wsCollapse) {
          res = ' '
        } else {
          res = match[0].replace(lineBreakPat, '')
        }
        blocks.push({type: 'break', remaining: res})
      }

      base = match.index + match[0].length
      match = multiLineBreakPat.exec(text)
    }
    blocks.push(text.substring(base))

    var i, j, k
    var segments
    if (skipPat) {
      segments = []
      for (i = 0; i < blocks.length; i++) {
        var bloc = blocks[i]
        if (typeof bloc !== 'string') {
          // This is an object.
          segments.push(bloc)
        } else {
          base = 0
          skipPat.lastIndex = 0
          match = skipPat.exec(bloc)
          while(match) {
            segments.push(bloc.substring(base, match.index))
            segments.push({type: 'skip', value: match[0]})
            base = match.index + match[0].length
            match = skipPat.exec(bloc)
          }
          segments.push(bloc.substring(base))
        }
      }
    } else {
      segments = blocks
    }

    var chunks = []
    for (i = 0; i < segments.length; i++) {
      var segment = segments[i]
      if (typeof segment !== 'string') {
        // This is an object.
        chunks.push(segment)
      } else {
        if (wsCollapse) {
          segment = segment.replace(collapsePat, ' ')
        }

        var parts = segment.split(re),
          acc = []

        for (j = 0; j < parts.length; j++) {
          var x = parts[j]
          if (mode === 'hard') {
            for (k = 0; k < x.length; k += wrapLen) {
              acc.push(x.slice(k, k + wrapLen))
            }
          } else { acc.push(x); }
        }
        chunks = chunks.concat(acc)
      }
    }

    var curLine = 0,
      curLineLength = start + preservedLinePrefix.length,
      lines = [ prefix + preservedLinePrefix ],
      // Holds the "real length" (excluding trailing whitespaces) of the
      // current line if it exceeds `stop`, otherwise 0.
      // ONLY USED when `wsAll` is true, in `finishOffCurLine()`.
      bulge = 0,
      // `cleanLine` is true iff we are at the beginning of an output line. By
      // "beginning" we mean it doesn't contain any non-whitespace char yet.
      // But its `curLineLength` can be greater than `start`, or even possibly
      // be greater than `stop`, if `wsStrip` is false.
      //
      // Note that a "clean" line can still contain skip strings, in addition
      // to whitespaces.
      //
      // This variable is used to allow us strip preceding whitespaces when
      // `wsStrip` is true, or `wsLine` is true and `preservedLine` is false.
      cleanLine = true,
      // `preservedLine` is true iff we are in a preserved input line.
      //
      // It's used when `wsLine` is true to (combined with `cleanLine`) decide
      // whether a whitespace is at the beginning of a preserved input line and
      // should not be stripped.
      preservedLine = true,
      // The current indent prefix for wrapped lines.
      wrapLinePrefix = wrapLineInitPrefix,
      remnant

    // Always returns '' if `beforeHardBreak` is true.
    //
    // Assumption: Each call of this function is always followed by a `lines.push()` call.
    //
    // This function can change the status of `cleanLine`, but we don't modify the value of
    // `cleanLine` in this function. It's fine because `cleanLine` will be set to the correct
    // value after the `lines.push()` call following this function call. We also don't update
    // `curLineLength` when pushing a new line and it's safe for the same reason.
    function finishOffCurLine (beforeHardBreak) {
      var str = lines[curLine],
        idx, ln, rBase

      if (!wsAll) {
        // Strip all trailing whitespaces past `start`.
        idx = str.length - 1
        while (idx >= start && str[idx] === ' ') { idx--; }
        while (idx >= start && wsPat.test(str[idx])) { idx--; }
        idx++

        if (idx !== str.length) {
          lines[curLine] = str.substring(0, idx)
        }

        if (preservedLine && cleanLine && wsLine && curLineLength > stop) {
          // Add the remnants to the next line, just like when `wsAll` is true.
          rBase = str.length - (curLineLength - stop)
          if (rBase < idx) {
            // We didn't reach `stop` when stripping due to a bulge.
            rBase = idx
          }
        }
      } else {
        // Strip trailing whitespaces exceeding stop.
        if (curLineLength > stop) {
          bulge = bulge || stop
          rBase = str.length - (curLineLength - bulge)
          lines[curLine] = str.substring(0, rBase)
        }
        bulge = 0
      }

      // Bug: the current implementation of `wrapLineIndent` is buggy: we are not
      // taking the extra space occupied by the additional indentation into account
      // when wrapping the line. For example, in "hard" mode, we should hard-wrap
      // long words at `wrapLen - wrapLinePrefix.length` instead of `wrapLen`
      // and remnants should also be wrapped at `wrapLen - wrapLinePrefix.length`.
      if (preservedLine) {
        // This is a preserved line, and the next output line isn't a
        // preserved line.
        preservedLine = false
        if (wrapLineIndentPat) {
          idx = lines[curLine].substring(start).search(wrapLineIndentPat)
          if (idx >= 0 && idx + wrapLineIndent > 0) {
            wrapLinePrefix = new Array(idx + wrapLineIndent + 1).join(' ')
          } else {
            wrapLinePrefix = ''
          }
        }
      }

      // Some remnants are left to the next line.
      if (rBase) {
        while (rBase + wrapLen < str.length) {
          if (wsAll) {
            ln = str.substring(rBase, rBase + wrapLen)
            lines.push(prefix + wrapLinePrefix + ln)
          } else {
            lines.push(prefix + wrapLinePrefix)
          }
          rBase += wrapLen
          curLine++
        }
        if (beforeHardBreak) {
          if (wsAll) {
            ln = str.substring(rBase)
            lines.push(prefix + wrapLinePrefix + ln)
          } else {
            lines.push(prefix + wrapLinePrefix)
          }
          curLine++
        } else {
          ln = str.substring(rBase)
          return wrapLinePrefix + ln
        }
      }

      return ''
    }

    for (i = 0; i < chunks.length; i++) {
      var chunk = chunks[i]

      if (chunk === '') { continue; }

      if (typeof chunk !== 'string') {
        if (chunk.type === 'break') {
          // This is one or more line breaks.
          // Each entry in `breaks` is just zero or more whitespaces.
          if (respectLineBreaks !== 'none') {
            // Note that if `whitespace` is "collapse", we still need
            // to collapse whitespaces in entries of `breaks`.
            var breaks = chunk.breaks
            var num = breaks.length - 1

            if (respectLineBreaks === 's') {
              // This is the most complex scenario. We have to check
              // the line breaks one by one.
              for (j = 0; j < num; j++) {
                if (breaks[j + 1].length < respectNum) {
                  // This line break should be stripped.
                  if (wsCollapse) {
                    breaks[j + 1] = ' '
                  } else {
                    breaks[j + 1] = breaks[j] + breaks[j + 1]
                  }
                } else {
                  // This line break should be preserved.
                  // First finish off the current line.
                  if (wsAll) {
                    lines[curLine] += breaks[j]
                    curLineLength += breaks[j].length
                  }
                  finishOffCurLine(true)

                  lines.push(prefix + preservedLinePrefix)
                  curLine++
                  curLineLength = start + preservedLinePrefix.length

                  preservedLine = cleanLine = true
                }
              }
              // We are adding to either the existing line (if no line break
              // is qualified for preservance) or a "new" line.
              if (!cleanLine || wsAll || (wsLine && preservedLine)) {
                if (wsCollapse || (!cleanLine && breaks[num] === '')) {
                  breaks[num] = ' '
                }
                lines[curLine] += breaks[num]
                curLineLength += breaks[num].length
              }
            } else if (respectLineBreaks === 'm' && num < respectNum) {
              // These line breaks should be stripped.
              if (!cleanLine || wsAll || (wsLine && preservedLine)) {
                if (wsCollapse) {
                  chunk = ' '
                } else {
                  chunk = breaks.join('')
                  if (!cleanLine && chunk === '') {
                    chunk = ' '
                  }
                }
                lines[curLine] += chunk
                curLineLength += chunk.length
              }
            } else { // 'all' || ('m' && num >= respectNum)
              // These line breaks should be preserved.
              if (wsStrip) {
                // Finish off the current line.
                finishOffCurLine(true)

                for (j = 0; j < num; j++) {
                  lines.push(prefix + preservedLinePrefix)
                  curLine++
                }

                curLineLength = start + preservedLinePrefix.length
                preservedLine = cleanLine = true
              } else {
                if (wsAll || (preservedLine && cleanLine)) {
                  lines[curLine] += breaks[0]
                  curLineLength += breaks[0].length
                }

                for (j = 0; j < num; j++) {
                  // Finish off the current line.
                  finishOffCurLine(true)

                  lines.push(prefix + preservedLinePrefix + breaks[j + 1])
                  curLine++
                  curLineLength = start + preservedLinePrefix.length + breaks[j + 1].length

                  preservedLine = cleanLine = true
                }
              }
            }
          } else {
            // These line breaks should be stripped.
            if (!cleanLine || wsAll || (wsLine && preservedLine)) {
              chunk = chunk.remaining

              // Bug: If `wsAll` is true, `cleanLine` is false, and `chunk`
              // is '', we insert a space to replace the line break. This
              // space will be preserved even if we are at the end of an
              // output line, which is wrong behavior. However, I'm not
              // sure it's worth it to fix this edge case.
              if (wsCollapse || (!cleanLine && chunk === '')) {
                chunk = ' '
              }
              lines[curLine] += chunk
              curLineLength += chunk.length
            }
          }
        } else if (chunk.type === 'skip') {
          // This is a skip string.
          // Assumption: skip strings don't end with whitespaces.
          if (curLineLength > stop) {
            remnant = finishOffCurLine(false)

            lines.push(prefix + wrapLinePrefix)
            curLine++
            curLineLength = start + wrapLinePrefix.length

            if (remnant) {
              lines[curLine] += remnant
              curLineLength += remnant.length
            }

            cleanLine = true
          }
          lines[curLine] += chunk.value
        }
        continue
      }

      var chunk2
      while (1) {
        chunk2 = undefined
        if (curLineLength + chunk.length > stop &&
          curLineLength + (chunk2 = chunk.replace(tPat, '')).length > stop &&
          chunk2 !== '' &&
          curLineLength > start) {
          // This line is full, add `chunk` to the next line
          remnant = finishOffCurLine(false)

          lines.push(prefix + wrapLinePrefix)
          curLine++
          curLineLength = start + wrapLinePrefix.length

          if (remnant) {
            lines[curLine] += remnant
            curLineLength += remnant.length
            cleanLine = true
            continue
          }

          if (wsStrip || (wsLine && !(preservedLine && cleanLine))) {
            chunk = chunk.replace(pPat, '')
          }
          cleanLine = false
        } else {
          // Add `chunk` to this line
          if (cleanLine) {
            if (wsStrip || (wsLine && !(preservedLine && cleanLine))) {
              chunk = chunk.replace(pPat, '')
              if (chunk !== '') {
                cleanLine = false
              }
            } else {
              if (nonWsPat.test(chunk)) {
                cleanLine = false
              }
            }
          }
        }
        break
      }
      if (wsAll && chunk2 && curLineLength + chunk2.length > stop) {
        bulge = curLineLength + chunk2.length
      }
      lines[curLine] += chunk
      curLineLength += chunk.length
    }
    // Finally, finish off the last line.
    finishOffCurLine(true)
    return lines.join(lineBreakStr)
  }
}

linewrap.soft = linewrap

linewrap.hard = function ( /*start, stop, params*/) {
  var args = [].slice.call(arguments)
  var last = args.length - 1
  if (typeof args[last] === 'object') {
    args[last].mode = 'hard'
  } else {
    args.push({ mode: 'hard' })
  }
  return linewrap.apply(null, args)
}

linewrap.wrap = function (text /*, start, stop, params*/) {
  var args = [].slice.call(arguments)
  args.shift()
  return linewrap.apply(null, args)(text)
}

