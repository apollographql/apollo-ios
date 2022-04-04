import OrderedCollections

extension IR {

  /// A condition representing an `@include` or `@skip` directive to determine if a field
  /// or fragment should be included.
  struct InclusionCondition: Hashable, CustomDebugStringConvertible {

    /// The name of variable used to determine if the inclusion condition is met.
    let variable: String

    /// If isInverted is `true`, this condition represents a `@skip` directive and is included
    /// if the variable resolves to `false`.
    let isInverted: Bool

    init(_ variable: String, isInverted: Bool) {
      self.variable = variable
      self.isInverted = isInverted
    }

    /// Creates an `InclusionCondition` representing an `@include` directive.
    static func include(if variable: String) -> InclusionCondition {
      .init(variable, isInverted: false)
    }

    /// Creates an `InclusionCondition` representing a `@skip` directive.
    static func skip(if variable: String) -> InclusionCondition {
      .init(variable, isInverted: true)
    }

    func inverted() -> InclusionCondition {
      InclusionCondition(variable, isInverted: !isInverted)
    }

    var debugDescription: String {
      TemplateString("""
      @\(if: isInverted, "skip", else: "include")(if: $\(variable))
      """).description
    }

  }

  struct InclusionConditions: Collection, Hashable, CustomDebugStringConvertible {

    typealias Element = InclusionCondition

    private var conditions: OrderedSet<InclusionCondition>

    private init(_ conditions: OrderedSet<InclusionCondition>) {
      self.conditions = conditions
    }

    init(_ condition: InclusionCondition) {
      self.conditions = [condition]
    }

    static func allOf<T: Sequence>(
      _ conditions: T
    ) -> Result where T.Element == InclusionCondition {
      return Result(conditions)
    }

    static func allOf<T: Sequence>(
      _ conditions: T
    ) -> Result where T.Element == CompilationResult.InclusionCondition {
      return Result(conditions)
    }

    var debugDescription: String {
      TemplateString("\(conditions.map(\.debugDescription), separator: " && ")").description
    }

    mutating func append(_ condition: InclusionCondition) {
      conditions.append(condition)
    }

    func appending(_ condition: InclusionCondition) -> InclusionConditions {
      var conditions = self.conditions
      conditions.append(condition)
      return InclusionConditions(conditions)
    }

    mutating func append(_ newConditions: InclusionConditions) {
      conditions.append(contentsOf: newConditions.conditions)
    }

    func appending(_ newConditions: InclusionConditions) -> InclusionConditions {
      var conditions = self.conditions
      conditions.append(contentsOf: newConditions.conditions)
      return InclusionConditions(conditions)
    }

    // MARK: Collection Conformance

    var startIndex: Int { conditions.startIndex }

    var endIndex: Int { conditions.endIndex }

    func index(after i: Int) -> Int { conditions.index(after: i) }

    subscript(position: Int) -> IR.InclusionCondition { conditions[position] }

    func isSubset(of other: InclusionConditions?) -> Bool {
      conditions.isSubset(of: other?.conditions ?? [])
    }

    // MARK: - Joining Operators

    static func &&(_ lhs: Self, rhs: InclusionCondition) -> Result {
      Result.conditional(lhs) && rhs
    }

    // MARK: - InclusionConditions.Result

    enum Result: Hashable {
      case included
      case skipped
      case conditional(InclusionConditions)

      var conditions: InclusionConditions? {
        guard case let .conditional(conditions) = self else { return nil }
        return conditions
      }

      fileprivate init<T: Sequence>(_ conditions: T) where T.Element == InclusionCondition {
        self = .included
        for condition in conditions {
          self = self && condition
        }
      }

      fileprivate init<T: Sequence>(_ conditions: T) where T.Element == CompilationResult.InclusionCondition {
        self = .included
        for condition in conditions {
          self = self && condition
        }
      }

      static func &&(_ lhs: Self, rhs: CompilationResult.InclusionCondition) -> Self {
        switch rhs {
        case .skipped:
          return .skipped

        case .included:
          return lhs

        case let .variable(variable, isInverted):
          let newCondition = InclusionCondition(variable, isInverted: isInverted)
          return lhs && newCondition
        }
      }

      static func &&(_ lhs: Self, rhs: InclusionCondition) -> Self {
        switch lhs {
        case .skipped:
          return .skipped

        case .included:
          return .conditional(.init([rhs]))

        case .conditional(var conditions):
          guard !conditions.contains(rhs.inverted()) else {
            // If both an include & skip exist with the same variable, the result is always skipped.
            return .skipped
          }

          conditions.append(rhs)
          return .conditional(conditions)
        }
      }
    }

  }
}

struct AnyOf<T: Hashable>: Hashable {
  private(set) var elements: OrderedSet<T>

  init(_ element: T) {
    self.elements = [element]
  }

  init?(_ element: T?) {
    guard let element = element else { return nil }
    self.elements = [element]
  }

  init<S: Sequence>(_ elements: S) where S.Element == T {
    self.elements = OrderedSet(elements)
  }

  mutating func append(contentsOf other: AnyOf<T>) {
    elements.append(contentsOf: other.elements)
  }
}

extension AnyOf where T == IR.InclusionConditions {
  init(_ condition: IR.InclusionCondition) {
    self.init(IR.InclusionConditions(condition))
  }
}

extension AnyOf: CustomDebugStringConvertible where T: CustomDebugStringConvertible {
  var debugDescription: String {
    let wrapInParens = elements.count > 1
    var string = ""
    for (index, element) in elements.enumerated() {
      if index > 0 {
        string += " || "
      }

      if wrapInParens {
        string += "(\(element.debugDescription))"
      } else {
        string += element.debugDescription
      }
    }
    return string
  }
}

func ||(_ lhs: AnyOf<IR.InclusionConditions>?, rhs: AnyOf<IR.InclusionConditions>?) -> AnyOf<IR.InclusionConditions>? {
  guard var lhs = lhs, let rhs = rhs else {
    return nil
  }

  lhs.append(contentsOf: rhs)
  return lhs
}
