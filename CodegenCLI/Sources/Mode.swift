import Foundation
import ArgumentParser

enum InputMode: String, ExpressibleByArgument, EnumerableFlag {
  case file, string
}
