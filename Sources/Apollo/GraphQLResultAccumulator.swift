public protocol GraphQLResultAccumulator: class {
  associatedtype PartialResult
  associatedtype FieldEntry
  associatedtype ObjectResult
  associatedtype FinalResult
  
  func accept(scalar: JSONValue, info: GraphQLResolveInfo) throws -> PartialResult
  func acceptNullValue(info: GraphQLResolveInfo) throws -> PartialResult
  func accept(list: [PartialResult], info: GraphQLResolveInfo) throws -> PartialResult
  
  func accept(fieldEntry: PartialResult, info: GraphQLResolveInfo) throws -> FieldEntry
  func accept(fieldEntries: [FieldEntry], info: GraphQLResolveInfo) throws -> ObjectResult
  
  func finish(rootValue: ObjectResult, info: GraphQLResolveInfo) throws -> FinalResult
}

public func zip<Accumulator1: GraphQLResultAccumulator, Accumulator2: GraphQLResultAccumulator>(_ accumulator1: Accumulator1, _ accumulator2: Accumulator2) -> Zip2Accumulator<Accumulator1, Accumulator2> {
  return Zip2Accumulator(accumulator1, accumulator2)
}

public func zip<Accumulator1: GraphQLResultAccumulator, Accumulator2: GraphQLResultAccumulator, Accumulator3: GraphQLResultAccumulator>(_ accumulator1: Accumulator1, _ accumulator2: Accumulator2, _ accumulator3: Accumulator3) -> Zip3Accumulator<Accumulator1, Accumulator2, Accumulator3> {
  return Zip3Accumulator(accumulator1, accumulator2, accumulator3)
}

public final class Zip2Accumulator<Accumulator1: GraphQLResultAccumulator, Accumulator2: GraphQLResultAccumulator>: GraphQLResultAccumulator {
  public typealias PartialResult = (Accumulator1.PartialResult, Accumulator2.PartialResult)
  public typealias FieldEntry = (Accumulator1.FieldEntry, Accumulator2.FieldEntry)
  public typealias ObjectResult = (Accumulator1.ObjectResult, Accumulator2.ObjectResult)
  public typealias FinalResult = (Accumulator1.FinalResult, Accumulator2.FinalResult)
  
  private let accumulator1: Accumulator1
  private let accumulator2: Accumulator2
  
  fileprivate init(_ accumulator1: Accumulator1, _ accumulator2: Accumulator2) {
    self.accumulator1 = accumulator1
    self.accumulator2 = accumulator2
  }
  
  public func accept(scalar: JSONValue, info: GraphQLResolveInfo) throws -> PartialResult {
    return (try accumulator1.accept(scalar: scalar, info: info), try accumulator2.accept(scalar: scalar, info: info))
  }
  
  public func acceptNullValue(info: GraphQLResolveInfo) throws -> PartialResult {
    return (try accumulator1.acceptNullValue(info: info), try accumulator2.acceptNullValue(info: info))
  }
  
  public func accept(list: [PartialResult], info: GraphQLResolveInfo) throws -> PartialResult {
    let (list1, list2) = unzip(list)
    return (try accumulator1.accept(list: list1, info: info), try accumulator2.accept(list: list2, info: info))
  }
  
  public func accept(fieldEntry: PartialResult, info: GraphQLResolveInfo) throws -> FieldEntry {
    return (try accumulator1.accept(fieldEntry: fieldEntry.0, info: info), try accumulator2.accept(fieldEntry: fieldEntry.1, info: info))
  }
  
  public func accept(fieldEntries: [FieldEntry], info: GraphQLResolveInfo) throws -> ObjectResult {
    let (fieldEntries1, fieldEntries2) = unzip(fieldEntries)
    return (try accumulator1.accept(fieldEntries: fieldEntries1, info: info), try accumulator2.accept(fieldEntries: fieldEntries2, info: info))
  }
  
  public func finish(rootValue: ObjectResult, info: GraphQLResolveInfo) throws -> FinalResult {
    return (try accumulator1.finish(rootValue: rootValue.0, info: info), try accumulator2.finish(rootValue: rootValue.1, info: info))
  }
}

public final class Zip3Accumulator<Accumulator1: GraphQLResultAccumulator, Accumulator2: GraphQLResultAccumulator, Accumulator3: GraphQLResultAccumulator>: GraphQLResultAccumulator {
  public typealias PartialResult = (Accumulator1.PartialResult, Accumulator2.PartialResult, Accumulator3.PartialResult)
  public typealias FieldEntry = (Accumulator1.FieldEntry, Accumulator2.FieldEntry, Accumulator3.FieldEntry)
  public typealias ObjectResult = (Accumulator1.ObjectResult, Accumulator2.ObjectResult, Accumulator3.ObjectResult)
  public typealias FinalResult = (Accumulator1.FinalResult, Accumulator2.FinalResult, Accumulator3.FinalResult)
  
  private let accumulator1: Accumulator1
  private let accumulator2: Accumulator2
  private let accumulator3: Accumulator3
  
  
  fileprivate init(_ accumulator1: Accumulator1, _ accumulator2: Accumulator2, _ accumulator3: Accumulator3) {
    self.accumulator1 = accumulator1
    self.accumulator2 = accumulator2
    self.accumulator3 = accumulator3
  }
  
  public func accept(scalar: JSONValue, info: GraphQLResolveInfo) throws -> PartialResult {
    return (try accumulator1.accept(scalar: scalar, info: info), try accumulator2.accept(scalar: scalar, info: info), try accumulator3.accept(scalar: scalar, info: info))
  }
  
  public func acceptNullValue(info: GraphQLResolveInfo) throws -> PartialResult {
    return (try accumulator1.acceptNullValue(info: info), try accumulator2.acceptNullValue(info: info), try accumulator3.acceptNullValue(info: info))
  }
  
  public func accept(list: [PartialResult], info: GraphQLResolveInfo) throws -> PartialResult {
    let (list1, list2, list3) = unzip(list)
    return (try accumulator1.accept(list: list1, info: info), try accumulator2.accept(list: list2, info: info), try accumulator3.accept(list: list3, info: info))
  }
  
  public func accept(fieldEntry: PartialResult, info: GraphQLResolveInfo) throws -> FieldEntry {
    return (try accumulator1.accept(fieldEntry: fieldEntry.0, info: info), try accumulator2.accept(fieldEntry: fieldEntry.1, info: info), try accumulator3.accept(fieldEntry: fieldEntry.2, info: info))
  }
  
  public func accept(fieldEntries: [FieldEntry], info: GraphQLResolveInfo) throws -> ObjectResult {
    let (fieldEntries1, fieldEntries2, fieldEntries3) = unzip(fieldEntries)
    return (try accumulator1.accept(fieldEntries: fieldEntries1, info: info), try accumulator2.accept(fieldEntries: fieldEntries2, info: info), try accumulator3.accept(fieldEntries: fieldEntries3, info: info))
  }
  
  public func finish(rootValue: ObjectResult, info: GraphQLResolveInfo) throws -> FinalResult {
    return (try accumulator1.finish(rootValue: rootValue.0, info: info), try accumulator2.finish(rootValue: rootValue.1, info: info), try accumulator3.finish(rootValue: rootValue.2, info: info))
  }
}
