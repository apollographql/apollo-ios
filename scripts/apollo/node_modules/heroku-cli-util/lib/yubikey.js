'use strict'

function toggle (onoff) {
  const cp = require('child_process')
  if (exports.platform !== 'darwin') return
  try {
    cp.execSync(`osascript -e 'if application "yubiswitch" is running then tell application "yubiswitch" to ${onoff}'`, {stdio: 'inherit'})
  } catch (err) {}
}

exports.enable = () => toggle('KeyOn')
exports.disable = () => toggle('KeyOff')

exports.platform = process.platform
