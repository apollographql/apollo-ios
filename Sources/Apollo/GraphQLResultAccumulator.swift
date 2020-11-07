import Foundation

protocol GraphQLResultAccumulator: class {
  associatedtype PartialResult
  associatedtype FieldEntry
  associatedtype ObjectResult
  associatedtype FinalResult

  func accept(scalar: JSONValue, firstReceivedAt: Date, info: GraphQLResolveInfo) throws -> PartialResult
  func acceptNullValue(firstReceivedAt: Date, info: GraphQLResolveInfo) throws -> PartialResult
  func accept(list: [PartialResult], info: GraphQLResolveInfo) throws -> PartialResult

  func accept(fieldEntry: PartialResult, info: GraphQLResolveInfo) throws -> FieldEntry
  func accept(fieldEntries: [FieldEntry], info: GraphQLResolveInfo) throws -> ObjectResult

  func finish(rootValue: ObjectResult, info: GraphQLResolveInfo) throws -> FinalResult
}

func zip<Accumulator1: GraphQLResultAccumulator, Accumulator2: GraphQLResultAccumulator>(_ accumulator1: Accumulator1, _ accumulator2: Accumulator2) -> Zip2Accumulator<Accumulator1, Accumulator2> {
  return Zip2Accumulator(accumulator1, accumulator2)
}

func zip<Accumulator1: GraphQLResultAccumulator, Accumulator2: GraphQLResultAccumulator, Accumulator3: GraphQLResultAccumulator>(_ accumulator1: Accumulator1, _ accumulator2: Accumulator2, _ accumulator3: Accumulator3) -> Zip3Accumulator<Accumulator1, Accumulator2, Accumulator3> {
  return Zip3Accumulator(accumulator1, accumulator2, accumulator3)
}

func zip<Accumulator1: GraphQLResultAccumulator, Accumulator2: GraphQLResultAccumulator, Accumulator3: GraphQLResultAccumulator, Accumulator4: GraphQLResultAccumulator>(_ accumulator1: Accumulator1, _ accumulator2: Accumulator2, _ accumulator3: Accumulator3, _ accumulator4: Accumulator4) -> Zip4Accumulator<Accumulator1, Accumulator2, Accumulator3, Accumulator4> {
  return Zip4Accumulator(accumulator1, accumulator2, accumulator3, accumulator4)
}

final class Zip2Accumulator<Accumulator1: GraphQLResultAccumulator, Accumulator2: GraphQLResultAccumulator>: GraphQLResultAccumulator {
  typealias PartialResult = (Accumulator1.PartialResult, Accumulator2.PartialResult)
  typealias FieldEntry = (Accumulator1.FieldEntry, Accumulator2.FieldEntry)
  typealias ObjectResult = (Accumulator1.ObjectResult, Accumulator2.ObjectResult)
  typealias FinalResult = (Accumulator1.FinalResult, Accumulator2.FinalResult)

  private let accumulator1: Accumulator1
  private let accumulator2: Accumulator2

  fileprivate init(_ accumulator1: Accumulator1, _ accumulator2: Accumulator2) {
    self.accumulator1 = accumulator1
    self.accumulator2 = accumulator2
  }

  func accept(scalar: JSONValue, firstReceivedAt: Date, info: GraphQLResolveInfo) throws -> PartialResult {
    return (
      try accumulator1.accept(scalar: scalar, firstReceivedAt: firstReceivedAt, info: info),
      try accumulator2.accept(scalar: scalar, firstReceivedAt: firstReceivedAt, info: info)
    )
  }

  func acceptNullValue(firstReceivedAt: Date, info: GraphQLResolveInfo) throws -> PartialResult {
    return (
      try accumulator1.acceptNullValue(firstReceivedAt: firstReceivedAt, info: info),
      try accumulator2.acceptNullValue(firstReceivedAt: firstReceivedAt, info: info)
    )
  }

  func accept(list: [PartialResult], info: GraphQLResolveInfo) throws -> PartialResult {
    let (list1, list2) = unzip(list)
    return (try accumulator1.accept(list: list1, info: info), try accumulator2.accept(list: list2, info: info))
  }

  func accept(fieldEntry: PartialResult, info: GraphQLResolveInfo) throws -> FieldEntry {
    return (try accumulator1.accept(fieldEntry: fieldEntry.0, info: info), try accumulator2.accept(fieldEntry: fieldEntry.1, info: info))
  }

  func accept(fieldEntries: [FieldEntry], info: GraphQLResolveInfo) throws -> ObjectResult {
    let (fieldEntries1, fieldEntries2) = unzip(fieldEntries)
    return (try accumulator1.accept(fieldEntries: fieldEntries1, info: info), try accumulator2.accept(fieldEntries: fieldEntries2, info: info))
  }

  func finish(rootValue: ObjectResult, info: GraphQLResolveInfo) throws -> FinalResult {
    return (try accumulator1.finish(rootValue: rootValue.0, info: info), try accumulator2.finish(rootValue: rootValue.1, info: info))
  }
}

final class Zip3Accumulator<Accumulator1: GraphQLResultAccumulator, Accumulator2: GraphQLResultAccumulator, Accumulator3: GraphQLResultAccumulator>: GraphQLResultAccumulator {
  typealias PartialResult = (Accumulator1.PartialResult, Accumulator2.PartialResult, Accumulator3.PartialResult)
  typealias FieldEntry = (Accumulator1.FieldEntry, Accumulator2.FieldEntry, Accumulator3.FieldEntry)
  typealias ObjectResult = (Accumulator1.ObjectResult, Accumulator2.ObjectResult, Accumulator3.ObjectResult)
  typealias FinalResult = (Accumulator1.FinalResult, Accumulator2.FinalResult, Accumulator3.FinalResult)

  private let accumulator1: Accumulator1
  private let accumulator2: Accumulator2
  private let accumulator3: Accumulator3


  fileprivate init(_ accumulator1: Accumulator1,
                   _ accumulator2: Accumulator2,
                   _ accumulator3: Accumulator3) {
    self.accumulator1 = accumulator1
    self.accumulator2 = accumulator2
    self.accumulator3 = accumulator3
  }

  func accept(scalar: JSONValue, firstReceivedAt: Date, info: GraphQLResolveInfo) throws -> PartialResult {
    return (
      try accumulator1.accept(scalar: scalar, firstReceivedAt: firstReceivedAt, info: info),
      try accumulator2.accept(scalar: scalar, firstReceivedAt: firstReceivedAt, info: info),
      try accumulator3.accept(scalar: scalar, firstReceivedAt: firstReceivedAt, info: info)
    )
  }

  func acceptNullValue(firstReceivedAt: Date, info: GraphQLResolveInfo) throws -> PartialResult {
    return (
      try accumulator1.acceptNullValue(firstReceivedAt: firstReceivedAt, info: info),
      try accumulator2.acceptNullValue(firstReceivedAt: firstReceivedAt, info: info),
      try accumulator3.acceptNullValue(firstReceivedAt: firstReceivedAt, info: info)
    )
  }

  func accept(list: [PartialResult], info: GraphQLResolveInfo) throws -> PartialResult {
    let (list1, list2, list3) = unzip(list)
    return (try accumulator1.accept(list: list1, info: info), try accumulator2.accept(list: list2, info: info), try accumulator3.accept(list: list3, info: info))
  }

  func accept(fieldEntry: PartialResult, info: GraphQLResolveInfo) throws -> FieldEntry {
    return (try accumulator1.accept(fieldEntry: fieldEntry.0, info: info), try accumulator2.accept(fieldEntry: fieldEntry.1, info: info), try accumulator3.accept(fieldEntry: fieldEntry.2, info: info))
  }

  func accept(fieldEntries: [FieldEntry], info: GraphQLResolveInfo) throws -> ObjectResult {
    let (fieldEntries1, fieldEntries2, fieldEntries3) = unzip(fieldEntries)
    return (try accumulator1.accept(fieldEntries: fieldEntries1, info: info), try accumulator2.accept(fieldEntries: fieldEntries2, info: info), try accumulator3.accept(fieldEntries: fieldEntries3, info: info))
  }

  func finish(rootValue: ObjectResult, info: GraphQLResolveInfo) throws -> FinalResult {
    return (try accumulator1.finish(rootValue: rootValue.0, info: info), try accumulator2.finish(rootValue: rootValue.1, info: info), try accumulator3.finish(rootValue: rootValue.2, info: info))
  }
}

final class Zip4Accumulator<Accumulator1: GraphQLResultAccumulator, Accumulator2: GraphQLResultAccumulator, Accumulator3: GraphQLResultAccumulator, Accumulator4: GraphQLResultAccumulator>: GraphQLResultAccumulator {
  typealias PartialResult = (Accumulator1.PartialResult, Accumulator2.PartialResult, Accumulator3.PartialResult, Accumulator4.PartialResult)
  typealias FieldEntry = (Accumulator1.FieldEntry, Accumulator2.FieldEntry, Accumulator3.FieldEntry, Accumulator4.FieldEntry)
  typealias ObjectResult = (Accumulator1.ObjectResult, Accumulator2.ObjectResult, Accumulator3.ObjectResult, Accumulator4.ObjectResult)
  typealias FinalResult = (Accumulator1.FinalResult, Accumulator2.FinalResult, Accumulator3.FinalResult, Accumulator4.FinalResult)

  private let accumulator1: Accumulator1
  private let accumulator2: Accumulator2
  private let accumulator3: Accumulator3
  private let accumulator4: Accumulator4


  fileprivate init(_ accumulator1: Accumulator1,
                   _ accumulator2: Accumulator2,
                   _ accumulator3: Accumulator3,
                   _ accumulator4: Accumulator4) {
    self.accumulator1 = accumulator1
    self.accumulator2 = accumulator2
    self.accumulator3 = accumulator3
    self.accumulator4 = accumulator4
  }

  func accept(scalar: JSONValue, firstReceivedAt: Date, info: GraphQLResolveInfo) throws -> PartialResult {
    return (
      try accumulator1.accept(scalar: scalar, firstReceivedAt: firstReceivedAt, info: info),
      try accumulator2.accept(scalar: scalar, firstReceivedAt: firstReceivedAt, info: info),
      try accumulator3.accept(scalar: scalar, firstReceivedAt: firstReceivedAt, info: info),
      try accumulator4.accept(scalar: scalar, firstReceivedAt: firstReceivedAt, info: info)
    )
  }

  func acceptNullValue(firstReceivedAt: Date, info: GraphQLResolveInfo) throws -> PartialResult {
    return (
      try accumulator1.acceptNullValue(firstReceivedAt: firstReceivedAt, info: info),
      try accumulator2.acceptNullValue(firstReceivedAt: firstReceivedAt, info: info),
      try accumulator3.acceptNullValue(firstReceivedAt: firstReceivedAt, info: info),
      try accumulator4.acceptNullValue(firstReceivedAt: firstReceivedAt, info: info)
    )
  }

  func accept(list: [PartialResult], info: GraphQLResolveInfo) throws -> PartialResult {
    let (list1, list2, list3, list4) = unzip(list)
    return (
      try accumulator1.accept(list: list1, info: info),
      try accumulator2.accept(list: list2, info: info),
      try accumulator3.accept(list: list3, info: info),
      try accumulator4.accept(list: list4, info: info)
    )
  }

  func accept(fieldEntry: PartialResult, info: GraphQLResolveInfo) throws -> FieldEntry {
    return (
      try accumulator1.accept(fieldEntry: fieldEntry.0, info: info),
      try accumulator2.accept(fieldEntry: fieldEntry.1, info: info),
      try accumulator3.accept(fieldEntry: fieldEntry.2, info: info),
      try accumulator4.accept(fieldEntry: fieldEntry.3, info: info)
    )
  }

  func accept(fieldEntries: [FieldEntry], info: GraphQLResolveInfo) throws -> ObjectResult {
    let (fieldEntries1, fieldEntries2, fieldEntries3, fieldEntries4) = unzip(fieldEntries)
    return (
      try accumulator1.accept(fieldEntries: fieldEntries1, info: info),
      try accumulator2.accept(fieldEntries: fieldEntries2, info: info),
      try accumulator3.accept(fieldEntries: fieldEntries3, info: info),
      try accumulator4.accept(fieldEntries: fieldEntries4, info: info)
    )
  }

  func finish(rootValue: ObjectResult, info: GraphQLResolveInfo) throws -> FinalResult {
    return (
      try accumulator1.finish(rootValue: rootValue.0, info: info),
      try accumulator2.finish(rootValue: rootValue.1, info: info),
      try accumulator3.finish(rootValue: rootValue.2, info: info),
      try accumulator4.finish(rootValue: rootValue.3, info: info)
    )
  }
}
