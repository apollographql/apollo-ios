import Foundation

struct TemplateString: ExpressibleByStringInterpolation, CustomStringConvertible {

  private let value: String

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

  var isEmpty: Bool { description.isEmpty }

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

    mutating func appendInterpolation(_ template: TemplateString) {
      appendInterpolation(template.description)
    }

    private mutating func appendOrRemoveLineIfEmpty(_ template: TemplateString) {
      if template.isEmpty {
        removeLineIfEmpty()
      } else {
        appendInterpolation(template.description)
      }
    }

    private static let whitespaceNotNewline = Set(" \t")

    mutating func appendInterpolation(_ string: String) {
      let indent = String(output.reversed().prefix {
        TemplateString.StringInterpolation.whitespaceNotNewline.contains($0)
      })

      if indent.isEmpty {
        appendLiteral(string)
      } else {
        let indentedString = string
          .split(separator: "\n", omittingEmptySubsequences: false)
          .joinedAsLines(withIndent: indent)

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

    mutating func appendInterpolation(
      if bool: Bool,
      _ template: @autoclosure () -> TemplateString,
      else: TemplateString? = nil
    ) {
      if bool {
        appendInterpolation(template().value)
      } else if let elseTemplate = `else` {
        appendInterpolation(elseTemplate.value)
      } else {
        removeLineIfEmpty()
      }
    }

    private mutating func removeLineIfEmpty() {
      let slice = substringToStartOfLine()
      if slice.allSatisfy(\.isWhitespace) {
        let charsToRemove = slice.count < output.count ? slice.count + 1 : slice.count
        // + 1 removes the \n character.

        output.removeLast(charsToRemove)
      }
    }

    private func substringToStartOfLine() -> Slice<ReversedCollection<String>> {
      return output.reversed().prefix { !$0.isNewline }
    }

    mutating func appendInterpolation<T>(
    ifLet optional: Optional<T>,
    where whereBlock: ((T) -> Bool)? = nil,
    _ includeBlock: (T) -> TemplateString,
    else: TemplateString? = nil
    ) {
      if let element = optional, whereBlock?(element) ?? true {
        appendOrRemoveLineIfEmpty(includeBlock(element))
      } else if let elseTemplate = `else` {
        appendInterpolation(elseTemplate.value)
      } else {
        removeLineIfEmpty()
      }
    }

  }
}

fileprivate extension Array where Element == Substring {
  func joinedAsLines(withIndent indent: String) -> String {
    var iterator = self.makeIterator()
    var string = iterator.next()?.description ?? ""

    while let nextLine = iterator.next() {
      string += "\n"
      if !nextLine.isEmpty {
        string += indent + nextLine
      }
    }

    return string
  }
}

extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
}
