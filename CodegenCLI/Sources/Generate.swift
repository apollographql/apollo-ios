import ArgumentParser

struct Generate: ParsableCommand {
  mutating func run() throws {
    print("Generate'd")
  }
}
