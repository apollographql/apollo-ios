import Foundation

struct TemplateString: ExpressibleByStringInterpolation, CustomStringConvertible {

  private let value: String
  private let lastLineWasRemoved: Bool

  init(_ string: String) {
    self.value = string
    lastLineWasRemoved = false
  }

  init(stringLiteral: String) {
    self.init(stringLiteral)
  }

  init(stringInterpolation: StringInterpolation) {
    self.value = stringInterpolation.output
    self.lastLineWasRemoved = stringInterpolation.lastLineWasRemoved
  }

  init(_ stringInterpolation: StringInterpolation) {
    self.value = stringInterpolation.output
    self.lastLineWasRemoved = stringInterpolation.lastLineWasRemoved
  }

  var description: String { value }

  var isEmpty: Bool { description.isEmpty }

  struct StringInterpolation: StringInterpolationProtocol {

    fileprivate var lastLineWasRemoved = false
    private var buffer: String

    fileprivate var output: String {
      if lastLineWasRemoved && buffer.hasSuffix("\n") {
        return String(buffer.dropLast())
      }
      return buffer
    }

    init(literalCapacity: Int, interpolationCount: Int) {
      var string = String()
      string.reserveCapacity(literalCapacity)
      self.buffer = string
    }

    mutating func appendLiteral(_ literal: StringLiteralType) {
      guard !literal.isEmpty else { return }
      defer { lastLineWasRemoved = false }

      if lastLineWasRemoved && literal.hasPrefix("\n") {
        buffer.append(contentsOf: literal.dropFirst())
      } else {
        buffer.append(literal)
      }
    }

    mutating func appendInterpolation(_ string: StaticString) {
      appendInterpolation(string.description)
    }

    mutating func appendInterpolation(_ template: TemplateString) {
      if template.isEmpty {
        removeLineIfEmpty()

      } else {
        appendInterpolation(template.description)
      }
    }

    mutating func appendInterpolation(section: TemplateString) {
      appendInterpolation(section)

      if section.isEmpty && buffer.hasSuffix("\n") {
        buffer.removeLast()
      }
    }

    private static let whitespaceNotNewline = Set(" \t")

    mutating func appendInterpolation(_ string: String) {
      let indent = String(buffer.reversed().prefix {
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
      separator: String = ",\n",
      terminator: String? = nil
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
      if let terminator = terminator {
        appendInterpolation(terminator)
      }
    }

    mutating func appendInterpolation<T>(
      list: T,
      separator: String = ",\n",
      terminator: String? = nil
    )
    where T: Collection, T.Element: CustomStringConvertible {
      let shouldWrapInNewlines = list.count > 1
      if shouldWrapInNewlines { appendLiteral("\n  ") }
      appendInterpolation(list, separator: separator, terminator: terminator)
      if shouldWrapInNewlines { appendInterpolation("\n") }
    }

    mutating func appendInterpolation(
      if bool: Bool,
      _ template: @autoclosure () -> TemplateString,
      else: @autoclosure () -> TemplateString? = nil
    ) {
      if bool {
        appendInterpolation(template())
      } else if let elseTemplate = `else`() {
        appendInterpolation(elseTemplate)
      } else {
        removeLineIfEmpty()
      }
    }

    mutating func appendInterpolation<T>(
    ifLet optional: Optional<T>,
    where whereBlock: ((T) -> Bool)? = nil,
    _ includeBlock: (T) -> TemplateString,
    else: @autoclosure () -> TemplateString? = nil
    ) {
      if let element = optional, whereBlock?(element) ?? true {
        appendInterpolation(includeBlock(element))
      } else if let elseTemplate = `else`() {
        appendInterpolation(elseTemplate.description)
      } else {
        removeLineIfEmpty()
      }
    }

    mutating func appendInterpolation<T>(
    ifLet optional: Optional<T>,
    where whereBlock: ((T) -> Bool)? = nil,
    _ includeBlock: @autoclosure () -> TemplateString,
    else: @autoclosure () -> TemplateString? = nil
    ) {
      appendInterpolation(
        ifLet: optional,
        where: whereBlock,
        { _ in includeBlock() },
        else: `else`()
      )
    }

    private mutating func removeLineIfEmpty() {
      let slice = substringToStartOfLine()
      if slice.allSatisfy(\.isWhitespace) {
        buffer.removeLast(slice.count)
        lastLineWasRemoved = true
      }
    }

    private func substringToStartOfLine() -> Slice<ReversedCollection<String>> {
      return buffer.reversed().prefix { !$0.isNewline }
    }

  }

}

/// Can be used to concatenate a `TemplateString` and `String` directly.
/// This bypasses `TemplateString` interpolation logic such as indentation calculation.
func +(lhs: String, rhs: TemplateString) -> TemplateString {
  TemplateString(lhs + rhs.description)
}

// MARK: - Extensions

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
    var firstLowercased: String { prefix(1).lowercased() + dropFirst() }
}
