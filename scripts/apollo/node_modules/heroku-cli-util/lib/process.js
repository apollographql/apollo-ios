function Process () {
  this.env = process.env
}
Process.prototype.mock = function () {
  this.mocking = true
}
Process.prototype.exit = function (code) {
  if (this.mocking) {
    this.exitCode = code
  } else {
    process.exit(code)
  }
}
module.exports = new Process()
