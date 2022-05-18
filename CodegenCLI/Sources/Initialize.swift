import ArgumentParser

struct Initialize: ParsableCommand {
  mutating func run() throws {
    print("Initialize'd")
  }
}
