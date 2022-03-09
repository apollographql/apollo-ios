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

    enum AnyOf: Hashable {
      case included
      case skipped
      case conditions(OrderedSet<OrderedSet<InclusionCondition>>)

      static func allOf<T: Sequence>(
        _ allOfConditions: T
      ) -> Self where T.Element == InclusionCondition {
        return .init(AllOf(allOfConditions))
      }

      static func allOf<T: Sequence>(
        _ allOfConditions: T
      ) -> Self where T.Element == CompilationResult.InclusionCondition {
        return .init(AllOf(allOfConditions))
      }

      init(_ allOfConditions: AllOf) {
        switch allOfConditions {
        case .included:
          self = .included
        case .skipped:
          self = .skipped
        case .conditions(let conditions):
          self = .conditions([conditions])
        }
      }

      static func ||(_ lhs: Self, rhs: CompilationResult.InclusionCondition) -> Self {
        switch rhs {
        case .included:
          return .included

        case .skipped:
          return lhs

        case let .variable(variable, isInverted):
          let newCondition = InclusionCondition(variable, isInverted: isInverted)
          return lhs || AllOf.conditions([newCondition])
        }
      }

      static func ||(_ lhs: Self, rhs: AllOf) -> Self {
        switch (lhs, rhs) {
        case (.included, _), (_, .included):
          return .included

        case (.skipped, .skipped):
          return .skipped

        case let (.skipped, .conditions(conditions)):
          return .conditions([conditions])

        case (.conditions, .skipped):
          return lhs

        case (.conditions(var conditions), .conditions(let newConditions)):
          conditions.append(newConditions)
          return .conditions(conditions)
        }
      }

      static func +=(_ lhs: inout Self, rhs: Self) {
        switch (lhs, rhs) {
        case (.included, _), (_, .included):
          lhs = .included

        case (.skipped, .skipped):
          lhs = .skipped

        case (.skipped, .conditions):
          lhs = rhs

        case (.conditions, .skipped):
          return

        case (.conditions(var conditions), .conditions(let newConditions)):
          conditions.append(contentsOf: newConditions)
          lhs = .conditions(conditions)
        }
      }
    }

    enum AllOf: Hashable {
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
