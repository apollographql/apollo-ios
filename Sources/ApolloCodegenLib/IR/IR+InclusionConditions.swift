import OrderedCollections

extension IR {

  /// A condition representing an `@include` or `@skip` directive to determine if a field
  /// or fragment should be included.
  struct InclusionCondition: Hashable {

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
      conditions.debugDescription
    }

    mutating func append(_ condition: InclusionCondition) {
      conditions.append(condition)
    }

    // MARK: Collection Conformance

    var startIndex: Int { conditions.startIndex }

    var endIndex: Int { conditions.endIndex }

    func index(after i: Int) -> Int { conditions.index(after: i) }

    subscript(position: Int) -> IR.InclusionCondition { conditions[position] }

    // MARK: - Joining Operators

    static func &&(_ lhs: Self, rhs: InclusionCondition) -> Result {
      Result.conditional(lhs) && rhs
    }

#warning("TODO: Use or remove")
//    static func ||(_ lhs: Self, rhs: CompilationResult.InclusionCondition) -> Self {
//      switch rhs {
//      case .included:
//        return .included
//
//      case .skipped:
//        return lhs
//
//      case let .variable(variable, isInverted):
//        let newCondition = InclusionCondition(variable, isInverted: isInverted)
//        return lhs || AllOf.conditions([newCondition])
//      }
//    }
//
//    fileprivate static func ||(_ lhs: Self, rhs: AllOf) -> Self {
//      switch (lhs, rhs) {
//      case (.included, _), (_, .included):
//        return .included
//
//      case (.skipped, .skipped):
//        return .skipped
//
//      case let (.skipped, .conditions(conditions)):
//        return .conditions([conditions])
//
//      case (.conditions, .skipped):
//        return lhs
//
//      case (.conditions(var conditions), .conditions(let newConditions)):
//        conditions.append(newConditions)
//        return .conditions(conditions)
//      }
//    }
//

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

func ||(_ lhs: AnyOf<IR.InclusionConditions>?, rhs: AnyOf<IR.InclusionConditions>?) -> AnyOf<IR.InclusionConditions>? {
  guard var lhs = lhs, let rhs = rhs else {
    return nil
  }

  lhs.append(contentsOf: rhs)
  return lhs
}
