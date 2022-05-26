import Foundation
import ArgumentParser

enum OutputMode: String, ExpressibleByArgument, EnumerableFlag {
  case file, print
}

enum InputMode: String, ExpressibleByArgument, EnumerableFlag {
  case file, string
}
