import Foundation
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib
import ApolloTestSupport

protocol SelectionShallowMatchable {
  typealias Field = IR.Field
  typealias TypeCase = IR.SelectionSet
  typealias Fragment = IR.FragmentSpread

  var fields: OrderedDictionary<String, Field> { get }
  var typeCases: OrderedDictionary<String, TypeCase> { get }
  var fragments: OrderedDictionary<String, Fragment> { get }

  var isEmpty: Bool { get }
}

extension IR.SortedSelections: SelectionShallowMatchable { }
extension IR.ShallowSelections: SelectionShallowMatchable {
  var typeCases: OrderedDictionary<String, TypeCase> { [:] }
}

// MARK - Custom Matchers

/// A Matcher that matches that the AST `MergedSelections` are equal, but does not check any nested
/// selection sets of the `fields`, `typeCases`, and `fragments`. This is used for conveniently
/// checking the `MergedSelections` without having to mock out the entire nested selection sets.
func shallowlyMatch<T: SelectionShallowMatchable>(
  _ expectedValue: (fields: [CompilationResult.Field],
                    typeCases: [CompilationResult.SelectionSet],
                    fragments: [CompilationResult.FragmentDefinition])
) -> Predicate<T> {
  return satisfyAllOf([
    shallowlyMatch(expectedValue.fields).mappingActualTo { $0?.fields },
    shallowlyMatch(expectedValue.typeCases).mappingActualTo { $0?.typeCases },
    shallowlyMatch(expectedValue.fragments).mappingActualTo { $0?.fragments }
  ])
}

func shallowlyMatch<T: SelectionShallowMatchable>(
  _ expectedValue: [CompilationResult.Selection]
) -> Predicate<T> {
  var expectedFields: [CompilationResult.Field] = []
  var expectedTypeCases: [CompilationResult.SelectionSet] = []
  var expectedFragments: [CompilationResult.FragmentDefinition] = []

  for selection in expectedValue {
    switch selection {
    case let .field(field): expectedFields.append(field)
    case let .inlineFragment(typeCase): expectedTypeCases.append(typeCase)
    case let .fragmentSpread(fragment): expectedFragments.append(fragment)
    }
  }

  return shallowlyMatch((expectedFields, expectedTypeCases, expectedFragments))
}

typealias SelectionMatcher = (
  direct: [CompilationResult.Selection]?,
  merged:[CompilationResult.Selection]
)

func shallowlyMatch(
  _ expectedValue: SelectionMatcher
) -> Predicate<IR.SelectionSet> {
  let directPredicate: Predicate<IR.SortedSelections> = expectedValue.direct == nil
  ? beNil()
  : shallowlyMatch(expectedValue.direct!)

  return satisfyAllOf([
    directPredicate.mappingActualTo { $0?.directSelections },
    shallowlyMatch(expectedValue.merged).mappingActualTo { $0?.mergedSelections }
  ])
}

// MARK: Field Matchers

public func shallowlyMatch(
  _ expectedValue: [CompilationResult.Field]
) -> Predicate<OrderedDictionary<String, IR.Field>> {
  return Predicate.define { actual in
    return shallowlyMatch(expected: expectedValue, actual: try actual.evaluate())
  }
}

public func shallowlyMatch(
  _ expectedValue: [CompilationResult.Selection]
) -> Predicate<OrderedDictionary<String, IR.Field>> {
  return Predicate.define { actual in
    let expectedAsFields: [CompilationResult.Field] = try expectedValue.map {
      guard case let .field(field) = $0 else {
        throw TestError("Selection \($0) is not a field!")
      }
      return field
    }
    return try shallowlyMatch(expectedAsFields).satisfies(actual)
  }
}

public func shallowlyMatch(
  expected: [CompilationResult.Field],
  actual: OrderedDictionary<String, IR.Field>?
) -> PredicateResult {
  let message: ExpectationMessage = .expectedActualValueTo("have fields equal to \(expected)")

  guard let actual = actual,
        expected.count == actual.count else {
    return PredicateResult(status: .fail, message: message)
  }

  for (index, field) in zip(expected, actual).enumerated() {
    guard shallowlyMatch(expected: field.0, actual: field.1.value) else {
      return PredicateResult(
        status: .fail,
        message: message.appended(
          details: "Expected fields[\(index)] to equal \(field.0), got \(field.1.value)."
        )
      )
    }
  }

  return PredicateResult(status: .matches, message: message)
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

// MARK: TypeCase Matchers

public func shallowlyMatch(
  _ expectedValue: [CompilationResult.SelectionSet]
) -> Predicate<OrderedDictionary<String, IR.SelectionSet>> {
  return Predicate.define { actual in
    return shallowlyMatch(expected: expectedValue, actual: try actual.evaluate())
  }
}

fileprivate func shallowlyMatch(
  expected: [CompilationResult.SelectionSet],
  actual: OrderedDictionary<String, IR.SelectionSet>?
) -> PredicateResult {
  let message: ExpectationMessage = .expectedActualValueTo("have typeCases equal to \(expected)")
  guard let actual = actual,
        expected.count == actual.count else {
    return PredicateResult(status: .fail, message: message)
  }

  for (index, typeCase) in zip(expected, actual).enumerated() {
    guard shallowlyMatch(expected: typeCase.0, actual: typeCase.1.value) else {
      return PredicateResult(
        status: .fail,
        message: message.appended(
          details: "Expected typeCases[\(index)] to equal \(typeCase.0), got \(typeCase.1.value)."
        )
      )
    }
  }

  return PredicateResult(status: .matches, message: message)
}

fileprivate func shallowlyMatch(expected: IR.SelectionSet, actual: IR.SelectionSet) -> Bool {
  return expected.parentType == actual.parentType &&
  expected.typePath == actual.typePath
}

fileprivate func shallowlyMatch(expected: CompilationResult.SelectionSet, actual: IR.SelectionSet) -> Bool {
  return expected.parentType == actual.parentType
}

// MARK: Fragment Matchers

public func shallowlyMatch(
  _ expectedValue: [CompilationResult.FragmentDefinition]
) -> Predicate<OrderedDictionary<String, IR.FragmentSpread>> {
  return Predicate.define { actual in
    return shallowlyMatch(expected: expectedValue, actual: try actual.evaluate())
  }
}

fileprivate func shallowlyMatch(
  expected: [CompilationResult.FragmentDefinition],
  actual: OrderedDictionary<String, IR.FragmentSpread>?
) -> PredicateResult {
  let message: ExpectationMessage = .expectedActualValueTo("have fragments equal to \(expected)")
  guard let actual = actual,
        expected.count == actual.count else {
    return PredicateResult(status: .fail, message: message)
  }

  for (index, fragment) in zip(expected, actual).enumerated() {
    guard shallowlyMatch(expected: fragment.0, actual: fragment.1.value) else {
      return PredicateResult(
        status: .fail,
        message: message.appended(
          details: "Expected fragments[\(index)] to equal \(fragment.0), got \(fragment.1.value)."
        )
      )
    }
  }

  return PredicateResult(status: .matches, message: message)
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

func beEmpty<S: SelectionShallowMatchable>() -> Predicate<S> {
    return Predicate.simple("be empty") { actualExpression in
      guard let actual = try actualExpression.evaluate() else { return .fail }
      return PredicateStatus(bool: actual.isEmpty)
    }
}

// MARK: - Predicate Mapping

extension Nimble.Predicate {
  func mappingActualTo<U>(
    _ actualMapper: @escaping ((U?) throws -> T?)
  ) -> Predicate<U> {
    Predicate<U>.define { (actual: Expression<U>) in
      let newActual = actual.cast(actualMapper)
      return try self.satisfies(newActual)
    }
  }
}
