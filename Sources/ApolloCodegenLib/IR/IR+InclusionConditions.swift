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

    init(stringLiteral: String) {
      self.variable = stringLiteral
      self.isInverted = false
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

    static prefix func !(value: InclusionCondition) -> InclusionCondition {
      value.inverted()
    }

  }

  struct InclusionConditions: Hashable, CustomDebugStringConvertible {
    typealias ConditionGroups = OrderedSet<OrderedSet<InclusionCondition>>

    fileprivate(set) var value: ConditionGroups

    init(_ conditions: ConditionGroups) {
      self.value = conditions
    }

    enum Result: Hashable {
      case included
      case skipped
      case conditional(InclusionConditions)

      fileprivate init(_ conditions: AllOf) {
        switch conditions {
        case .included:
          self = .included
        case .skipped:
          self = .skipped
        case .conditions(let conditions):
          self = .conditional(.init([conditions]))
        }
      }

      var conditions: InclusionConditions? {
        guard case let .conditional(conditions) = self else {
          return nil
        }
        return conditions
      }
    }

    static func allOf<T: Sequence>(
      _ conditions: T
    ) -> Result where T.Element == InclusionCondition {
      return Result(AllOf(conditions))
    }

    static func allOf<T: Sequence>(
      _ conditions: T
    ) -> Result where T.Element == CompilationResult.InclusionCondition {
      return Result(AllOf(conditions))
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

    var debugDescription: String {
      value.debugDescription
    }

    fileprivate enum AllOf: Hashable {
      case included
      case skipped
      case conditions(OrderedSet<InclusionCondition>)

      init<T: Sequence>(_ conditions: T) where T.Element == InclusionCondition {
        self = .included
        for condition in conditions {
          self = self && condition
        }
      }

      init<T: Sequence>(_ conditions: T) where T.Element == CompilationResult.InclusionCondition {
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
          return .conditions([rhs])

        case .conditions(var conditions):
          guard !conditions.contains(rhs.inverted()) else {
            // If both an include & skip exist with the same variable, the result is always skipped.
            return .skipped
          }

          conditions.append(rhs)
          return .conditions(conditions)
        }
      }
    }
  }
}

func ||(_ lhs: IR.InclusionConditions?, rhs: IR.InclusionConditions?) -> IR.InclusionConditions? {
  guard var lhs = lhs, let rhs = rhs else {
    return nil
  }

  lhs.value.append(contentsOf: rhs.value)
  return lhs
}
