import Foundation
import Nimble
@testable import ArgumentParser

public func throwUserValidationError(
  _ expectedError: ValidationError
) -> Predicate<ParsableCommand> {
  return Predicate { actualExpression in
    var actualError: Error?
    do {
      _ = try actualExpression.evaluate()
    } catch {
      actualError = error
    }

    guard let actualError = actualError else {
      return PredicateResult(
        status: .fail,
        message: .fail("No error was thrown!")
      )
    }

    guard
      let commandError = actualError as? CommandError,
      case let ParserError.userValidationError(parserError) = commandError.parserError,
      let validationError = parserError as? ValidationError,
      validationError.message == expectedError.message
    else {
      return PredicateResult(
        status: .fail,
        message: .expectedTo(
          "equal ValidationError(\"\(expectedError.self)\"), got \(actualError)"
        )
      )
    }

    return PredicateResult(
      status: .matches,
      message: .expectedTo("be equal")
    )
  }
}

public func throwUnknownOptionError() -> Predicate<ParsableCommand> {
  return Predicate { actualExpression in
    var actualError: Error?
    do {
      _ = try actualExpression.evaluate()
    } catch {
      actualError = error
    }

    guard let actualError = actualError else {
      return PredicateResult(
        status: .fail,
        message: .fail("No error was thrown!")
      )
    }

    guard
      let commandError = actualError as? CommandError,
      case ParserError.unknownOption = commandError.parserError
    else {
      return PredicateResult(
        status: .fail,
        message: .expectedTo("equal UnknownOption(), got \(actualError)")
      )
    }

    return PredicateResult(
      status: .matches,
      message: .expectedTo("be equal")
    )
  }
}

public func throwError(
  localizedDescription: String,
  ignoringExtraCharacters: Bool = false
) -> Predicate<Any> {
  return Predicate { actualExpression in
    var actualError: Error?
    do {
      _ = try actualExpression.evaluate()
    } catch {
      actualError = error
    }

    guard let actualError = actualError else {
      return PredicateResult(
        status: .fail,
        message: .fail("No error was thrown!")
      )
    }

    if ignoringExtraCharacters {
      if !actualError.localizedDescription.starts(with: localizedDescription) {
        return PredicateResult(
          status: .doesNotMatch,
          message: .expectedTo(
            "start with \"\(localizedDescription)\", got \"\(actualError.localizedDescription)\""
          )
        )
      }
    } else {
      if !(actualError.localizedDescription == localizedDescription) {
        return PredicateResult(
          status: .doesNotMatch,
          message: .expectedTo(
            "equal \"\(localizedDescription)\", got \"\(actualError.localizedDescription)\""
          )
        )
      }
    }

    return PredicateResult(
      status: .matches,
      message: .expectedTo("be equal")
    )
  }
}
