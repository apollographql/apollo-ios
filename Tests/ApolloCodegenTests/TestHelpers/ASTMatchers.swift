import Foundation
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib

// MARK - Custom Matchers

/// A Matcher that matches that the AST `MergedSelections` are equal, but does not check any nested
/// selection sets of the `fields`, `typeCases`, and `fragments`. This is used for conveniently
/// checking the `MergedSelections` without having to mock out the entire nested selection sets.
public func shallowlyMatch(_ expectedValue: IR.SortedSelections) -> Predicate<IR.SortedSelections> {
  return Predicate { actual in
    if let actualValue = try actual.evaluate() {
//      let matchTypeCases = shallowlyMatch(expectedValue.typeCases).satisfies(actualValue.)
      if expectedValue.fields.count != actualValue.fields.count {
        return PredicateResult(
          status: .fail,
          message: .expectedCustomValueTo("have fields equal to " + expectedValue.fields.debugDescription,
                                          actual: actualValue.fields.debugDescription)
        )
      }

      if expectedValue.typeCases.count != actualValue.typeCases.count {
        return PredicateResult(
          status: .fail,
          message: .expectedCustomValueTo("have typeCases equal to " + expectedValue.typeCases.debugDescription,
                                          actual: actualValue.typeCases.debugDescription)
        )
      }

      if expectedValue.fragments.count != actualValue.fragments.count {
        return PredicateResult(
          status: .fail,
          message: .expectedCustomValueTo("have fragments equal to " + expectedValue.fragments.debugDescription,
                                          actual: actualValue.fragments.debugDescription)
        )
      }

      for field in zip(expectedValue.fields, actualValue.fields) {
        guard field.0.key == field.1.key else {
          return PredicateResult(
            status: .fail,
            message: .expectedCustomValueTo("have fields equal to " + expectedValue.fields.debugDescription,
                                            actual: actualValue.fields.debugDescription)
          )
        }

        guard shallowlyMatch(expected: field.0.value, actual: field.1.value) else {
          return PredicateResult(
            status: .fail,
            message: .fail("Expected fields[\(field.0.key)] to equal \(field.0.value), got \(field.1.value).")
          )
        }
      }

      for typeCase in zip(expectedValue.typeCases, actualValue.typeCases) {
        guard typeCase.0.key == typeCase.1.key else {
          return PredicateResult(
            status: .fail,
            message: .expectedCustomValueTo("have type cases equal to " + expectedValue.typeCases.debugDescription,
                                            actual: actualValue.typeCases.debugDescription)
          )
        }

        guard shallowlyMatch(expected: typeCase.0.value, actual: typeCase.1.value) else {
          return PredicateResult(
            status: .fail,
            message: .fail("Expected typeCases[\(typeCase.0.key)] to equal \(typeCase.0.value), got \(typeCase.1.value).")
          )
        }
      }

      for fragment in zip(expectedValue.fragments, actualValue.fragments) {
        guard fragment.0.key == fragment.1.key else {
          return PredicateResult(
            status: .fail,
            message: .expectedCustomValueTo("have fragments equal to " + expectedValue.fragments.debugDescription,
                                            actual: actualValue.fragments.debugDescription)
          )
        }

        guard shallowlyMatch(expected: fragment.0.value, actual: fragment.1.value) else {
          return PredicateResult(
            status: .fail,
            message: .fail("Expected fragments[\(fragment.0.key)] to equal \(fragment.0.value), got \(fragment.1.value).")
          )
        }
      }

      return PredicateResult(
        status: .matches,
        message: .expectedActualValueTo("equal <\(expectedValue)>")
      )

    } else {
      return PredicateResult(
        status: .fail,
        message: .expectedActualValueTo("equal <\(expectedValue)>").appendedBeNilHint()
      )
    }
  }
}

// MARK: Field Matchers

public func shallowlyMatch(_ expectedValue: [CompilationResult.Selection]) -> Predicate<OrderedDictionary<String, IR.Field>> {
  return Predicate { actual in
    if let actualValue = try actual.evaluate() {
      return shallowlyMatch(expected: expectedValue, actual: actualValue)
    } else {
      return PredicateResult(
        status: .fail,
        message: .expectedActualValueTo("equal <\(expectedValue)>").appendedBeNilHint()
      )
    }
  }
}

public func shallowlyMatch(
  expected: [CompilationResult.Selection],
  actual: OrderedDictionary<String, IR.Field>
) -> PredicateResult {
  if expected.count != actual.count {
    return PredicateResult(
      status: .fail,
      message: .expectedCustomValueTo("have typeCases equal to " + expected.debugDescription,
                                      actual: actual.debugDescription)
    )
  }

  for (index, field) in zip(expected, actual).enumerated() {
    guard shallowlyMatch(expected: field.0, actual: field.1.value) else {
      return PredicateResult(
        status: .fail,
        message: .fail("Expected field[\(index)] to equal \(field.0), got \(field.1.value).")
      )
    }
  }

  return PredicateResult(
    status: .matches,
    message: .expectedActualValueTo("equal <\(expected)>")
  )
}

fileprivate func shallowlyMatch(expected: IR.Field, actual: IR.Field) -> Bool {
  return shallowlyMatch(expected: expected.underlyingField, actual: actual.underlyingField)
}

fileprivate func shallowlyMatch(expected: CompilationResult.Selection, actual: IR.Field) -> Bool {
  guard case let .field(field) = expected else { return false }
  return shallowlyMatch(expected: field, actual: actual.underlyingField)
}

fileprivate func shallowlyMatch(expected: CompilationResult.Field, actual: IR.Field) -> Bool {
  return shallowlyMatch(expected: expected, actual: actual.underlyingField)
}

fileprivate func shallowlyMatch(expected: CompilationResult.Field, actual: CompilationResult.Field) -> Bool {
  return expected.name == actual.name &&
  expected.alias == actual.alias &&
  expected.arguments == actual.arguments &&
  expected.type == actual.type
}

//// MARK: TypeCase Matchers
//
//public func shallowlyMatch(
//  _ expectedValue: [CompilationResult.Selection]
//) -> Predicate<OrderedDictionary<String, IR.SelectionSet>> {
//  return Predicate { actual in
//    if let actualValue = try actual.evaluate() {
//      return shallowlyMatch(expected: expectedValue, actual: actualValue)
//    } else {
//      return PredicateResult(
//        status: .fail,
//        message: .expectedActualValueTo("equal <\(expectedValue)>").appendedBeNilHint()
//      )
//    }
//  }
//}
//
//fileprivate func shallowlyMatch(
//  expected: [CompilationResult.SelectionSet],
//  actual: OrderedDictionary<String, IR.SelectionSet>
//) -> PredicateResult {
//  if expected.count != actual.count {
//    return PredicateResult(
//      status: .fail,
//      message: .expectedCustomValueTo("have typeCases equal to " + expected.debugDescription,
//                                      actual: actual.debugDescription)
//    )
//  }
//
//  for (index, typeCase) in zip(expected, actual).enumerated() {
//    guard shallowlyMatch(expected: typeCase.0, actual: typeCase.1.value) else {
//      return PredicateResult(
//        status: .fail,
//        message: .fail("Expected typeCases[\(index)] to equal \(typeCase.0), got \(typeCase.1.value).")
//      )
//    }
//  }
//
//  return PredicateResult(
//    status: .matches,
//    message: .expectedActualValueTo("equal <\(expected)>")
//  )
//}

fileprivate func shallowlyMatch(expected: IR.SelectionSet, actual: IR.SelectionSet) -> Bool {
  return expected.parentType == actual.parentType &&
  expected.typePath == actual.typePath
}

// MARK: Fragment Matchers

public func shallowlyMatch(
  _ expectedValue: [CompilationResult.FragmentDefinition]
) -> Predicate<OrderedDictionary<String, IR.FragmentSpread>> {
  return Predicate { actual in
    if let actualValue = try actual.evaluate() {
      return shallowlyMatch(expected: expectedValue, actual: actualValue)
    } else {
      return PredicateResult(
        status: .fail,
        message: .expectedActualValueTo("equal <\(expectedValue)>").appendedBeNilHint()
      )
    }
  }
}

fileprivate func shallowlyMatch(
  expected: [CompilationResult.FragmentDefinition],
  actual: OrderedDictionary<String, IR.FragmentSpread>
) -> PredicateResult {
  if expected.count != actual.count {
    return PredicateResult(
      status: .fail,
      message: .expectedCustomValueTo("have typeCases equal to " + expected.debugDescription,
                                      actual: actual.debugDescription)
    )
  }

  for (index, fragment) in zip(expected, actual).enumerated() {
    guard shallowlyMatch(expected: fragment.0, actual: fragment.1.value) else {
      return PredicateResult(
        status: .fail,
        message: .fail("Expected fragments[\(index)] to equal \(fragment.0), got \(fragment.1.value).")
      )
    }
  }

  return PredicateResult(
    status: .matches,
    message: .expectedActualValueTo("equal <\(expected)>")
  )
}

fileprivate func shallowlyMatch(expected: IR.FragmentSpread, actual: IR.FragmentSpread) -> Bool {
  return shallowlyMatch(expected: expected.definition, actual: actual.definition)
}

fileprivate func shallowlyMatch(expected: CompilationResult.FragmentDefinition, actual: IR.FragmentSpread) -> Bool {
  return shallowlyMatch(expected: expected, actual: actual.definition)
}

fileprivate func shallowlyMatch(expected: CompilationResult.FragmentDefinition, actual: CompilationResult.FragmentDefinition) -> Bool {
  return expected.name == actual.name &&
  expected.type == actual.type
}
