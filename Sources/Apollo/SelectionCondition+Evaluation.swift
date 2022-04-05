#if !COCOAPODS
import ApolloAPI
#endif
import Foundation

// MARK: Conditions - Or Group
extension Selection.Conditions {
  func evaluate(with variables: GraphQLOperation.Variables?) throws -> Bool {
    for andGroup in value {
      if try andGroup.evaluate(with: variables) {
        return true
      }
    }
    return false
  }
}

// MARK: Conditions - And Group
fileprivate extension Array where Element == Selection.Condition {
  func evaluate(with variables: GraphQLOperation.Variables?) throws -> Bool {
    for condition in self {
      if try !condition.evaluate(with: variables) {
        return false
      }
    }
    return true
  }
}

// MARK: Conditions - Individual
fileprivate extension Selection.Condition {
  func evaluate(with variables: GraphQLOperation.Variables?) throws -> Bool {
    guard let boolValue = variables?[variableName] as? Bool else {
      throw GraphQLError("Variable \"\(variableName)\" was not provided.")
    }
    return inverted ? !boolValue : boolValue
  }
  
}
