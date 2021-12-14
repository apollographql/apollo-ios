import Foundation

struct Template: ExpressibleByStringInterpolation, CustomStringConvertible {

  let value: String

  init(stringLiteral: String) {
    self.value = stringLiteral
  }

  init(stringInterpolation: StringInterpolation) {
    self.value = stringInterpolation.output
  }

  init(_ stringInterpolation: StringInterpolation) {
    self.value = stringInterpolation.output
  }

  var description: String { value }

  struct StringInterpolation: StringInterpolationProtocol {
    var output: String

    init(literalCapacity: Int, interpolationCount: Int) {
      var string = String()
      string.reserveCapacity(literalCapacity)
      self.output = string
    }

    mutating func appendLiteral(_ literal: StringLiteralType) {
      output.append(literal)
    }

    mutating func appendInterpolation(_ template: Template) {
      appendInterpolation(template.value)
    }

    private static let whitespaceNotNewline = Set(" \t")

    mutating func appendInterpolation(_ string: String) {
      let indent = output.reversed().prefix {
        Template.StringInterpolation.whitespaceNotNewline.contains($0)
      }

      if indent.isEmpty {
        appendLiteral(string)
      } else {
        let indentedString = string
          .split(separator: "\n", omittingEmptySubsequences: false)
          .joined(separator: "\n" + indent)

        appendLiteral(indentedString)
      }
    }

    mutating func appendInterpolation<T>(
      _ sequence: T,
      separator: String = ",\n"
    )
    where T: Sequence, T.Element: CustomStringConvertible {
      var iterator = sequence.makeIterator()
      guard var elementsString = iterator.next()?.description else {
        removeLineIfEmpty()
        return
      }

      while let element = iterator.next() {
        elementsString.append(separator + element.description)
      }

      appendInterpolation(elementsString)
    }

    mutating func appendInterpolation(if bool: Bool, _ template: Template, else: Template? = nil) {
      if bool {
        appendInterpolation(template.value)
      } else if let elseTemplate = `else` {
        appendInterpolation(elseTemplate.value)
      } else {
        removeLineIfEmpty()
      }
    }

    private mutating func removeLineIfEmpty() {
      let slice = substringToStartOfLine()
      if slice.allSatisfy(\.isWhitespace) {
        output.removeLast(slice.count + 1) // + 1 removes the \n character.
      }
    }

    private func substringToStartOfLine() -> Slice<ReversedCollection<String>> {
      return output.reversed().prefix { !$0.isNewline }
    }
  }
}
