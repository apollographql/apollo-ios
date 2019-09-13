'use strict'

// Adapted from https://blog.jcoglan.com/2016/07/12/mutexes-and-javascript/

let Mutex = function () {
  this._busy = false
  this._queue = []
}

Mutex.prototype.synchronize = function (task) {
  let self = this

  return new Promise(function (resolve, reject) {
    self._queue.push([task, resolve, reject])
    if (!self._busy) {
      self._dequeue()
    }
  })
}

Mutex.prototype._dequeue = function () {
  this._busy = true
  let next = this._queue.shift()

  if (next) {
    this._execute(next)
  } else {
    this._busy = false
  }
}

Mutex.prototype._execute = function (record) {
  let [task, resolve, reject] = record
  let self = this

  task().then(resolve, reject).then(function () {
    self._dequeue()
  })
}

module.exports = Mutex
